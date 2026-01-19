# Конвертация Markdown в PDF (в стиле GitHub)

Ниже описаны шаги, которые позволяют получить PDF и HTML максимально похожие на рендер GitHub Markdown, с корректной кириллицей и встроенными изображениями.

## Предварительные требования

1) Pandoc (v3.x)
- Установка: https://pandoc.org/installing.html
- Проверка:
```powershell
pandoc --version
```

2) Google Chrome (для headless-экспорта в PDF)
- Установка: https://www.google.com/chrome/
- Проверка:
```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" --version
```

3) PowerShell (есть в Windows по умолчанию)

## Файлы в папке

- Исходный Markdown: `Описание сервис-прошивки ''EVO Reset Service''.md`
- Изображения: `media\...`
- GitHub CSS: `templates\github-markdown.min.css`
- Локальные правки CSS: `templates\github-markdown-overrides.css`
- HTML шаблон: `templates\github-template.html`
- Генератор: `ERS-to-PDF.ps1`
- Результаты: `Описание сервис-прошивки ''EVO Reset Service''.html`, `Описание сервис-прошивки ''EVO Reset Service''.pdf`

## Как пользоваться (одна команда)

Запустите скрипт из этой папки:
```powershell
.\ERS-to-PDF.ps1
```

Скрипт создаёт/обновляет оба файла:
- `Описание сервис-прошивки ''EVO Reset Service''.html`
- `Описание сервис-прошивки ''EVO Reset Service''.pdf`

## Настройка размера и плотности текста

Основные настройки находятся в двух файлах:
- `templates\github-template.html` — базовый размер шрифта (`font-size: 14px`)
- `templates\github-markdown-overrides.css` — межстрочный интервал и отступы

Рекомендации:
- Чтобы сделать текст крупнее/мельче, меняйте `font-size`.
- Чтобы уменьшить количество страниц, чаще всего помогает уменьшить `line-height` и вертикальные отступы.

## Примечания и устранение проблем

- Если Chrome пишет, что файл занят, закройте просмотрщик PDF и запустите скрипт снова.
- Если картинки не попали в PDF, убедитесь, что пути в Markdown указывают на `media/...` и перезапустите скрипт.
- Если шрифты с кириллицей выглядят неправильно, установите системный шрифт с поддержкой кириллицы (например, Arial или Noto Sans) и повторите генерацию.
