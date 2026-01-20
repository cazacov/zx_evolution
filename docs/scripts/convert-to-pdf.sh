#!/bin/bash

# Exit on any error
set -e

# Set UTF-8 encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

cd "$WORK_DIR"

# File paths
MD_FILE="Описание сервис-прошивки ''EVO Reset Service''.md"
CSS_FILE="templates/github-markdown.min.css"
OVERRIDE_CSS="templates/github-markdown-overrides.css"
TEMPLATE_FILE="templates/github-template.html"
HTML_FILE="Описание сервис-прошивки ''EVO Reset Service''.html"
PDF_FILE="Описание сервис-прошивки ''EVO Reset Service''.pdf"
HTML_TEMP="__print-source.html"
PDF_TEMP="__print-output.pdf"

echo "Converting markdown to PDF..."

# Check if required files exist
if [ ! -f "$MD_FILE" ]; then
    echo "Error: Markdown file not found: $MD_FILE"
    exit 1
fi

if [ ! -f "$CSS_FILE" ]; then
    echo "Error: CSS file not found: $CSS_FILE"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

# Convert markdown to HTML using pandoc
echo "Converting markdown to HTML..."
pandoc -f gfm -t html5 --standalone --template="$TEMPLATE_FILE" \
    --metadata title="Описание сервис прошивки EVO Reset Service" \
    --css="$CSS_FILE" --embed-resources \
    "$MD_FILE" -o "$HTML_FILE"

# Clean up any existing temporary files
rm -f "$HTML_TEMP" "$PDF_TEMP"

# Copy HTML to temporary file for Chrome processing
cp "$HTML_FILE" "$HTML_TEMP"

# Get absolute path for file:// URL
HTML_ABSOLUTE_PATH="$(realpath "$HTML_TEMP")"
FILE_URL="file://$HTML_ABSOLUTE_PATH"

echo "Converting HTML to PDF using Chrome..."

# Use Chrome headless to convert HTML to PDF
google-chrome --headless=new \
    --disable-gpu \
    --disable-extensions \
    --no-first-run \
    --no-default-browser-check \
    --disable-background-networking \
    --allow-file-access-from-files \
    --no-sandbox \
    --disable-dev-shm-usage \
    --disable-dbus \
    --disable-features=VizDisplayCompositor \
    --disable-background-timer-throttling \
    --disable-backgrounding-occluded-windows \
    --disable-renderer-backgrounding \
    --disable-ipc-flooding-protection \
    --print-to-pdf="$PDF_TEMP" \
    --print-to-pdf-no-header \
    --run-all-compositor-stages-before-draw \
    --virtual-time-budget=10000 \
    "$FILE_URL" 2>/dev/null

# Check if PDF was created
if [ ! -f "$PDF_TEMP" ]; then
    echo "Error: PDF was not created"
    exit 1
fi

# Replace the existing PDF with the new one
if [ -f "$PDF_FILE" ]; then
    rm -f "$PDF_FILE"
fi

mv "$PDF_TEMP" "$PDF_FILE"

# Clean up temporary HTML file
rm -f "$HTML_TEMP"

# Delete the HTML file as requested
if [ -f "$HTML_FILE" ]; then
    rm -f "$HTML_FILE"
    echo "Deleted intermediate HTML file: $HTML_FILE"
fi

echo "Successfully created PDF: $PDF_FILE"