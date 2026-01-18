$ErrorActionPreference = "Stop"

$utf8 = [System.Text.Encoding]::UTF8
$OutputEncoding = $utf8
[Console]::OutputEncoding = $utf8

$workdir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $workdir

$md = "Описание сервис-прошивки ''EVO Reset Service''.md"
$css = "templates\\github-markdown.min.css"
$template = "templates\\github-template.html"
$html = "Описание сервис-прошивки ''EVO Reset Service''.html"
$pdf = "Описание сервис-прошивки ''EVO Reset Service''.pdf"
$chrome = "C:\Program Files\Google\Chrome\Application\chrome.exe"
$userDataDir = Join-Path $env:TEMP "mdpdf-chrome-profile"
$htmlTemp = Join-Path $workdir "__print-source.html"
$pdfTemp = Join-Path $workdir "__print-output.pdf"

if (-not (Test-Path -LiteralPath $md)) {
  throw "Markdown file not found: $md"
}
if (-not (Test-Path -LiteralPath $css)) {
  throw "CSS file not found: $css"
}
if (-not (Test-Path -LiteralPath $template)) {
  throw "Template file not found: $template"
}
if (-not (Test-Path -LiteralPath $chrome)) {
  throw "Chrome not found at: $chrome"
}
if (-not (Test-Path -LiteralPath $userDataDir)) {
  New-Item -ItemType Directory -Path $userDataDir | Out-Null
}

pandoc -f gfm -t html5 --standalone --template $template `
  --metadata title="Описание сервис прошивки EVO Reset Service" `
  --css $css --embed-resources `
  $md -o $html

Remove-Item -LiteralPath $pdf -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $htmlTemp -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $pdfTemp -ErrorAction SilentlyContinue

Copy-Item -LiteralPath $html -Destination $htmlTemp

$htmlPath = $htmlTemp
$uri = "file:///" + ($htmlPath -replace "\\", "/")

$proc = Start-Process -FilePath $chrome -ArgumentList @(
  "--headless=new",
  "--disable-gpu",
  "--disable-extensions",
  "--no-first-run",
  "--no-default-browser-check",
  "--disable-background-networking",
  "--allow-file-access-from-files",
  "--user-data-dir=$userDataDir",
  "--print-to-pdf=$pdfTemp",
  "--print-to-pdf-no-header",
  $uri
) -Wait -PassThru -NoNewWindow

if (-not (Test-Path -LiteralPath $pdfTemp)) {
  throw "PDF was not created. Chrome exit code: $($proc.ExitCode)"
}

if (Test-Path -LiteralPath $pdf) {
  try {
    Remove-Item -LiteralPath $pdf -Force -ErrorAction Stop
  } catch {
    throw "Destination PDF is in use or cannot be removed. Close it and retry: $pdf"
  }
}
Move-Item -LiteralPath $pdfTemp -Destination $pdf -Force
Remove-Item -LiteralPath $htmlTemp -ErrorAction SilentlyContinue

Write-Host "HTML: $html"
Write-Host "PDF:  $pdf"
