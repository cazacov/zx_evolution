# Документация ZX Evolution

Эта папка хранит Markdown-копии оригинальной документации ZX Evolution, вычитанные для удобного просмотра на GitHub. Оригинальные ODT являются источником содержания; Markdown адаптирован для навигации, ссылок и отображения иллюстраций в репозитории.

Исходная документация находится в Subversion-репозитории [`svn://zxevo.ru/pentevo`](svn://zxevo.ru/pentevo).

## Документы в формате MD и PDF

- [Описание сервис-прошивки «EVO Reset Service»](<Описание сервис-прошивки ''EVO Reset Service''.md>) 
  - [PDF](<Описание сервис-прошивки ''EVO Reset Service''.pdf>)
  - [Исходник ODT в SVN](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2F%D0%9E%D0%BF%D0%B8%D1%81%D0%B0%D0%BD%D0%B8%D0%B5%20%D1%81%D0%B5%D1%80%D0%B2%D0%B8%D1%81-%D0%BF%D1%80%D0%BE%D1%88%D0%B8%D0%B2%D0%BA%D0%B8%20%27%27EVO%20Reset%20Service%27%27.odt)
- [Обновление прошивок ZX Evolution](ZXEvo_firmware_update.md) 
  - [PDF](ZXEvo_firmware_update.pdf)
  - [Исходник ODT в SVN](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2FZXEvo_firmware_update.odt)
- [Поддерживаемые мониторы](supported_monitors.md)
  - [PDF](supported_monitors.pdf)
  - [Исходник ODT в SVN](http://svn.nedopc.com/filedetails.php?repname=pentevo&path=%2Fdocs%2Fsupported_monitors.odt)


## Реестр документов

[documents.json](documents.json) — единый список ODT-источников из SVN, соответствующих Markdown/PDF-файлов, каталогов иллюстраций и файлов контрольных ревизий. Добавляйте новые документы в этот реестр перед включением их в автоматизацию.

Каждый документ имеет собственный файл `…-revision.txt` с последней SVN-ревизией, уже представленной в вычитанном Markdown. Этот файл следует коммитить вместе с соответствующими правками документации.

## Скрипты

- `scripts/` — PowerShell-скрипты для ручного запуска в Windows.
- `scripts-ci/` — shell-скрипты для GitHub Actions и Linux/WSL. Workflow [`.github/workflows/markdown-to-pdf.yml`](../.github/workflows/markdown-to-pdf.yml) вызывает `scripts-ci/convert-to-pdf.sh`.

### Ручное обновление Markdown по ODT

`scripts/compare-odt-revisions.ps1` читает `documents.json`, получает две ревизии выбранного ODT из SVN, преобразует их в Markdown через Pandoc и показывает diff. Скрипт не перезаписывает вычитанный Markdown: найденные смысловые изменения переносятся вручную.

Без параметров появляется меню выбора документа:

```powershell
.\scripts\compare-odt-revisions.ps1
```

Для неинтерактивного выбора и показа изменений отдельными шагами:

```powershell
.\scripts\compare-odt-revisions.ps1 -DocumentId evo-reset-service -EachRevision -KeepFiles
```

После ручного переноса правок контрольную точку нужно обновить явно:

```powershell
.\scripts\compare-odt-revisions.ps1 -DocumentId evo-reset-service -ToRevision <номер-ревизии> -MarkProcessed
```

Для работы скрипта требуются `svn`, Pandoc и Git. PowerShell-скрипт сохранён в UTF-8 с BOM и совместим с Windows PowerShell 5.1 и PowerShell 7.

### Ручное создание PDF

`scripts/ERS-to-PDF.ps1` вручную создаёт HTML и PDF только для EVO Reset Service с помощью Pandoc, шаблона GitHub Markdown и Chrome в headless-режиме:

```powershell
.\scripts\ERS-to-PDF.ps1
```

Нужны Pandoc и Google Chrome; PDF перед запуском не должен быть открыт в программе просмотра. Подробности: [scripts/README.md](scripts/README.md).

### Автоматическое создание PDF

`scripts-ci/convert-to-pdf.sh` читает `documents.json` и преобразует все документы с `pdfEnabled: true` на Linux runner в GitHub Actions. `scripts-ci/test-setup.sh` проверяет локальную Linux/WSL-среду перед его запуском. Подробности: [scripts-ci/README.md](scripts-ci/README.md).