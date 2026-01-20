# Automated Markdown to PDF Conversion

This repository includes automated conversion of markdown files to PDF using GitHub Actions.

## How it works

1. **Trigger**: The GitHub Action is triggered when any `.md` file in the `docs/` folder is changed
2. **Conversion**: Uses Pandoc to convert markdown to HTML, then Chrome headless to generate PDF
3. **Output**: Updates the corresponding PDF file and commits it back to the repository

## Files involved

- `.github/workflows/markdown-to-pdf.yml` - GitHub Action workflow
- `docs/scripts/convert-to-pdf.sh` - Linux conversion script
- `docs/templates/github-template.html` - HTML template for PDF generation
- `docs/templates/github-markdown.min.css` - CSS styles for the PDF
- `docs/templates/github-markdown-overrides.css` - Additional CSS overrides

## Current automation

The workflow currently processes:
- `Описание сервис-прошивки ''EVO Reset Service''.md` → `Описание сервис-прошивки ''EVO Reset Service''.pdf`

## Manual execution

To run the conversion manually on Linux/WSL:

```bash
cd docs
chmod +x scripts/convert-to-pdf.sh
./scripts/convert-to-pdf.sh
```

## Requirements

- Pandoc (for markdown to HTML conversion)
- Google Chrome/Chromium (for HTML to PDF conversion)
- Git (for committing changes)

The GitHub Action automatically installs these dependencies on the Ubuntu runner.