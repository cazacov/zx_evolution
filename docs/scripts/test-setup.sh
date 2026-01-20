#!/bin/bash

# Test script to validate the markdown to PDF conversion
# This script checks if all required dependencies and files are present

echo "=== Testing Markdown to PDF Conversion Setup ==="

# Check if we're in the right directory
if [ ! -d "templates" ] || [ ! -f "scripts/convert-to-pdf.sh" ]; then
    echo "❌ Error: Please run this script from the docs/ directory"
    exit 1
fi

echo "✅ Directory structure looks correct"

# Check for required files
REQUIRED_FILES=(
    "Описание сервис-прошивки ''EVO Reset Service''.md"
    "templates/github-template.html"
    "templates/github-markdown.min.css"
    "scripts/convert-to-pdf.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found: $file"
    else
        echo "❌ Missing: $file"
        exit 1
    fi
done

# Check for required commands
REQUIRED_COMMANDS=("pandoc" "google-chrome")
MISSING_COMMANDS=()

for cmd in "${REQUIRED_COMMANDS[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "✅ Command available: $cmd"
    else
        echo "❌ Command missing: $cmd"
        MISSING_COMMANDS+=("$cmd")
    fi
done

if [ ${#MISSING_COMMANDS[@]} -ne 0 ]; then
    echo ""
    echo "Please install the missing commands:"
    for cmd in "${MISSING_COMMANDS[@]}"; do
        case "$cmd" in
            "pandoc")
                echo "  - pandoc: sudo apt-get install pandoc"
                ;;
            "google-chrome")
                echo "  - google-chrome: sudo apt-get install google-chrome-stable"
                ;;
        esac
    done
    exit 1
fi

echo ""
echo "✅ All requirements satisfied!"
echo ""
echo "You can now run the conversion script:"
echo "  chmod +x scripts/convert-to-pdf.sh"
echo "  ./scripts/convert-to-pdf.sh"