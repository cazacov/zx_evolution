#!/bin/bash
set -euo pipefail
export LANG=C.UTF-8
export LC_ALL=C.UTF-8

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
CONFIG_FILE="${WORK_DIR}/documents.json"

mode="changed"
output_list=""
declare -a changed_markdown=()

usage() {
    echo "Usage: $0 [--all | --changed-markdown <path> ...] [--output-list <file>]"
}

while [ "$#" -gt 0 ]; do
    case "$1" in
        --all)
            mode="all"
            ;;
        --changed-markdown)
            [ "$#" -ge 2 ] || { usage; exit 2; }
            changed_markdown+=("$2")
            shift
            ;;
        --output-list)
            [ "$#" -ge 2 ] || { usage; exit 2; }
            output_list="$2"
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            usage
            exit 2
            ;;
    esac
    shift
done

cd "$WORK_DIR"
for command in pandoc google-chrome python3; do
    command -v "$command" >/dev/null 2>&1 || { echo "Error: command not found: $command"; exit 1; }
done
[ -f "$CONFIG_FILE" ] || { echo "Error: manifest not found: $CONFIG_FILE"; exit 1; }
[ -f "templates/github-markdown.min.css" ] || { echo "Error: CSS file not found"; exit 1; }
[ -f "templates/github-template.html" ] || { echo "Error: HTML template not found"; exit 1; }
if [ -n "$output_list" ]; then : > "$output_list"; fi

convert_document() {
    local id="$1" markdown="$2" pdf="$3" title="$4"
    local html="${pdf%.pdf}.html" html_temp="__print-${id}.html" pdf_temp="__print-${id}.pdf"
    [ -f "$markdown" ] || { echo "Error: Markdown file not found: $markdown"; exit 1; }

    mkdir -p "$(dirname "$pdf")"

    echo "Converting $markdown -> $pdf"
    pandoc -f gfm -t html5 --standalone --template="templates/github-template.html" \
        --metadata title="$title" --css="templates/github-markdown.min.css" --embed-resources \
        "$markdown" -o "$html"
    rm -f "$html_temp" "$pdf_temp"
    cp "$html" "$html_temp"
    google-chrome --headless=new --disable-gpu --disable-extensions --no-first-run \
        --no-default-browser-check --disable-background-networking --allow-file-access-from-files \
        --no-sandbox --disable-dev-shm-usage --disable-dbus --print-to-pdf="$pdf_temp" \
        --print-to-pdf-no-header --virtual-time-budget=10000 "file://$(realpath "$html_temp")" 2>/dev/null
    [ -f "$pdf_temp" ] || { echo "Error: PDF was not created for $markdown"; exit 1; }
    mv -f "$pdf_temp" "$pdf"
    rm -f "$html_temp" "$html"
    [ -z "$output_list" ] || printf '%s\n' "$pdf" >> "$output_list"
}

should_convert() {
    local markdown="$1" changed
    [ "$mode" = "all" ] && return 0
    for changed in "${changed_markdown[@]}"; do
        [ "$markdown" = "$changed" ] && return 0
    done
    return 1
}

generated=0
while IFS=$'\t' read -r id markdown pdf title; do
    if should_convert "$markdown"; then
        convert_document "$id" "$markdown" "$pdf" "$title"
        generated=$((generated + 1))
    fi
done < <(python3 - "$CONFIG_FILE" <<'PY'
import json, sys
with open(sys.argv[1], encoding='utf-8') as file:
    for document in json.load(file)['documents']:
        if document.get('pdfEnabled'):
            print('\t'.join(str(document[key]) for key in ('id', 'markdown', 'pdf', 'title')))
PY
)

if [ "$generated" -eq 0 ]; then
    echo "No registered Markdown source changed; no PDF generated."
fi