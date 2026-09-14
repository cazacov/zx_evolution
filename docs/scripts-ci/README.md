# Automated Markdown to PDF Conversion

GitHub Actions converts Markdown sources in `../documents.json` to PDF.

## Selective generation

For `push` and `pull_request`, the workflow compares the relevant commits, finds changed `docs/*.md` files, and generates PDFs only for matching manifest entries with `pdfEnabled: true`. Changing a README or another Markdown file absent from the manifest does not generate a PDF.

Only the PDFs generated in that run are staged and committed. A manual workflow dispatch generates all enabled documents by default.

## Files involved

- `.github/workflows/markdown-to-pdf.yml` — GitHub Actions workflow.
- `docs/scripts-ci/convert-to-pdf.sh` — Linux conversion script.
- `docs/documents.json` — source Markdown/PDF mapping.
- `docs/templates/github-template.html` — HTML template.
- `docs/templates/github-markdown.min.css` — GitHub-like CSS.

## Current automation

The workflow has these enabled mappings:

- `Описание сервис-прошивки ''EVO Reset Service''.md` → `Описание сервис-прошивки ''EVO Reset Service''.pdf`
- `ZXEvo_firmware_update.md` → `ZXEvo_firmware_update.pdf`
- `supported_monitors.md` → `supported_monitors.pdf`

## Manual execution on Linux/WSL

Generate all enabled PDFs:

```bash
cd docs
chmod +x scripts-ci/convert-to-pdf.sh
./scripts-ci/convert-to-pdf.sh --all
```

Generate one document after its Markdown changed:

```bash
./scripts-ci/convert-to-pdf.sh --changed-markdown supported_monitors.md
```

Use `--output-list <file>` when another script needs the list of PDFs created during the run.

## Requirements

- Pandoc
- Google Chrome/Chromium
- Python 3
- Git (only for the workflow commit step)