[CmdletBinding()]
param(
    # Identifier from ../documents.json. Without it, an interactive menu is shown.
    [string]$DocumentId,

    # Revision to start from. By default this is read from documents.json.
    [Nullable[int]]$FromRevision,

    # Revision to finish at. By default this is the newest ODT revision in SVN.
    [Nullable[int]]$ToRevision,

    # Show a separate Markdown diff for every intervening SVN revision.
    [switch]$EachRevision,

    # Advance lastProcessedRevision in documents.json after you have manually merged the shown changes.
    [switch]$MarkProcessed,

    # Keep downloaded ODTs, generated Markdown, and extracted pictures for inspection.
    [switch]$KeepFiles
)

$ErrorActionPreference = 'Stop'
$docsDirectory = Split-Path -Parent $PSScriptRoot
$configFile = Join-Path $docsDirectory 'documents.json'

foreach ($command in 'svn', 'pandoc', 'git') {
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        throw "Не найдена команда '$command'. Установите её и откройте новое окно PowerShell."
    }
}
if (-not (Test-Path -LiteralPath $configFile)) { throw "Не найден реестр документов: $configFile" }

$config = Get-Content -LiteralPath $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
$documents = @($config.documents)
if ($documents.Count -eq 0) { throw 'В реестре нет документов.' }

if ([string]::IsNullOrWhiteSpace($DocumentId)) {
    Write-Host 'Выберите документ:'
    for ($index = 0; $index -lt $documents.Count; $index++) {
        Write-Host ('  {0}. {1} ({2})' -f ($index + 1), $documents[$index].title, $documents[$index].id)
    }
    $choice = Read-Host 'Номер'
    [int]$choiceNumber = 0
    if (-not [int]::TryParse($choice, [ref]$choiceNumber) -or $choiceNumber -lt 1 -or $choiceNumber -gt $documents.Count) {
        throw 'Нужно указать номер документа из списка.'
    }
    $document = $documents[$choiceNumber - 1]
}
else {
    $document = @($documents | Where-Object { $_.id -eq $DocumentId }) | Select-Object -First 1
    if ($null -eq $document) {
        $available = ($documents.id -join ', ')
        throw "Неизвестный DocumentId '$DocumentId'. Доступны: $available"
    }
}

$pathSegments = @(([string]$document.svnPath).Trim('/') -split '/' | ForEach-Object { [Uri]::EscapeDataString($_) })
$sourceUrl = ([string]$config.svnRepositoryUrl).TrimEnd('/') + '/' + ($pathSegments -join '/')
$mediaReference = ([string]$document.mediaDirectory).TrimEnd('/') + '/'

function Get-LatestRevision {
    [xml]$history = & svn log --xml --limit 1 $sourceUrl
    $entry = @($history.log.logentry)[0]
    if ($null -eq $entry) { throw 'SVN не вернул историю ODT.' }
    return [int]$entry.revision
}

function Get-ProcessedRevision {
    [int]$revision = 0
    $value = $document.lastProcessedRevision
    if ($null -eq $value -or -not [int]::TryParse([string]$value, [ref]$revision) -or $revision -lt 0) {
        throw "Некорректная lastProcessedRevision для '$($document.id)' в $configFile."
    }
    return $revision
}

function Convert-OdtToMarkdown([string]$odtFile, [string]$markdownFile, [string]$mediaDirectory) {
    & pandoc $odtFile --from=odt --to=gfm --wrap=none --extract-media=$mediaDirectory --output=$markdownFile
    if ($LASTEXITCODE -ne 0) { throw "Pandoc завершился с кодом $LASTEXITCODE." }

    # Normalize temporary old-media/new-media paths to a stable document-specific path.
    $markdown = [IO.File]::ReadAllText($markdownFile)
    $markdown = $markdown -replace '(?<=src=")[^"]*?[\\/](?:old|new)-media[\\/]', $mediaReference
    [IO.File]::WriteAllText($markdownFile, $markdown, [Text.UTF8Encoding]::new($false))
}

function Show-RevisionDiff([int]$from, [int]$to, [string]$directory) {
    $oldOdt = Join-Path $directory 'old.odt'; $newOdt = Join-Path $directory 'new.odt'
    $oldMd = Join-Path $directory 'old.md'; $newMd = Join-Path $directory 'new.md'
    New-Item -ItemType Directory -Path $directory -Force | Out-Null

    Write-Host "`nПолучаю SVN-ревизии $from и $to для $($document.title)..."
    & svn export --force -r $from $sourceUrl $oldOdt | Out-Host
    & svn export --force -r $to $sourceUrl $newOdt | Out-Host
    if ($LASTEXITCODE -ne 0) { throw "svn export завершился с кодом $LASTEXITCODE." }

    Convert-OdtToMarkdown $oldOdt $oldMd (Join-Path $directory 'old-media')
    Convert-OdtToMarkdown $newOdt $newMd (Join-Path $directory 'new-media')
    Write-Host "`nИзменения ODT: r${from} -> r${to}`n"
    & git diff --no-index --word-diff=plain -- $oldMd $newMd
    if ($LASTEXITCODE -gt 1) { throw "git diff завершился с кодом $LASTEXITCODE." }
}

$storedRevision = Get-ProcessedRevision
if ($null -eq $FromRevision) { $FromRevision = $storedRevision }
if ($null -eq $ToRevision) { $ToRevision = Get-LatestRevision }
if ($FromRevision -ge $ToRevision) { throw 'FromRevision должна быть меньше ToRevision.' }

$workDir = Join-Path ([IO.Path]::GetTempPath()) ("odt-diff-{0}-{1}-{2}" -f $document.id, $FromRevision, $ToRevision)
New-Item -ItemType Directory -Path $workDir -Force | Out-Null
try {
    if ($EachRevision) {
        [xml]$history = & svn log --xml -r "$(($FromRevision + 1)):$ToRevision" $sourceUrl
        $revisions = @($history.log.logentry | ForEach-Object { [int]$_.revision } | Sort-Object -Unique)
        $previous = [int]$FromRevision
        foreach ($revision in $revisions) {
            Show-RevisionDiff $previous $revision (Join-Path $workDir ("r{0}-r{1}" -f $previous, $revision))
            $previous = $revision
        }
    } else {
        Show-RevisionDiff $FromRevision $ToRevision $workDir
    }

    if ($MarkProcessed) {
        $document.lastProcessedRevision = [int]$ToRevision
        $json = $config | ConvertTo-Json -Depth 20
        [IO.File]::WriteAllText($configFile, "$json$([Environment]::NewLine)", [Text.UTF8Encoding]::new($false))
        Write-Host "`nКонтрольная точка в documents.json обновлена: r$ToRevision"
    } else {
        Write-Host "`ndocuments.json не изменён; текущая контрольная точка: r$storedRevision. После ручного переноса правок повторите команду с -MarkProcessed."
    }
} finally {
    if ($KeepFiles) { Write-Host "Промежуточные файлы оставлены в: ${workDir}" }
    elseif (Test-Path -LiteralPath $workDir) { Remove-Item -LiteralPath $workDir -Recurse -Force }
}