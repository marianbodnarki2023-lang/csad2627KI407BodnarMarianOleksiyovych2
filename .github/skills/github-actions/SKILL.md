---
name: github-actions
description: "Use when creating or validating a GitHub Actions CI workflow for the Python hello project on Ubuntu, Windows, and macOS."
---

# GitHub Actions

## Вхід

Перед початком мають існувати `ci.sh` і `ci.bat`. Перевір також наявні правила репозиторію та `.github/workflows/ci.yml`, якщо файл уже є.

## Вихід

Створи `.github/workflows/ci.yml` лише якщо його немає. Workflow має відповідати таким вимогам:

- Тригери `push` і `pull_request` для гілок `develop` та `master`.
- Одна job з matrix `os: [ubuntu-latest, windows-latest, macos-latest]` і `fail-fast: false`.
- Кроки checkout і `actions/setup-python@v5` з `python-version: "3.12"`.
- Для не-Windows runner: умова `runner.os != 'Windows'`, `shell: bash`, а вміст `run` — рівно виклик `./ci.sh`.
- Для Windows runner: умова `runner.os == 'Windows'`, `shell: cmd`, а вміст `run` — рівно виклик `ci.bat`.
- Після CI-скрипту завантаж артефакт через `actions/upload-artifact@v4` із `path: dist/`, унікальним ім’ям `hello-${{ matrix.os }}` і `if-no-files-found: error`.
- Workflow не повинен містити credentials, налаштування автентифікації або чутливі значення.

Приклад структури workflow:

    name: Python Hello World CI
    on:
      push:
        branches: [develop, master]
      pull_request:
        branches: [develop, master]

    jobs:
      build:
        runs-on: ${{ matrix.os }}
        strategy:
          fail-fast: false
          matrix:
            os: [ubuntu-latest, windows-latest, macos-latest]
        steps:
          - uses: actions/checkout@v4
          - uses: actions/setup-python@v5
            with:
              python-version: "3.12"
          - name: Run CI on Linux and macOS
            if: runner.os != 'Windows'
            run: ./ci.sh
            shell: bash
          - name: Run CI on Windows
            if: runner.os == 'Windows'
            run: ci.bat
            shell: cmd
          - uses: actions/upload-artifact@v4
            with:
              name: hello-${{ matrix.os }}
              path: dist/
              if-no-files-found: error

Не додавай до workflow окремих команд Python, pip або pytest. Встановлення залежностей, запуск тестів і підготовку `dist/` виконують `ci.sh` та `ci.bat`.

## Правила

- Перед створенням перевір наявність workflow. Не перезаписуй наявний файл без перевірки.
- Якщо файл уже відповідає вимогам, залиш його без змін. Якщо відрізняється, повідом про розбіжності й не перезаписуй автоматично.
- Переконайся, що `ci.sh` має executable bit у Git, інакше `./ci.sh` може завершитися помилкою на Linux/macOS. Якщо скрипт уже відстежується Git, перевір його mode; за потреби повідом користувачу про команду `git update-index --chmod=+x ci.sh`. Не виконуй `git add` і не змінюй staging автоматично.
- Змінюй лише workflow, якщо користувач окремо не попросив інше.

## Перевірки

- Перевір YAML за допомогою `actionlint`, якщо він доступний; інакше скористайся Python із PyYAML, наприклад `python -c "import yaml; yaml.safe_load(open('.github/workflows/ci.yml', encoding='utf-8'))"`. Якщо валідатора немає, повідом це як невиконану перевірку.
- Переконайся, що файл містить `ubuntu-latest`, `windows-latest` і `macos-latest`, одну job, matrix та `fail-fast: false`.
- Переконайся, що всі `run` кроки містять лише виклики `./ci.sh` або `ci.bat` відповідно до ОС; прямих команд Python, pip і pytest немає.
- Переконайся, що workflow містить `actions/setup-python@v5`, версію Python `3.12`, `actions/upload-artifact@v4`, `dist/`, `hello-${{ matrix.os }}` і `if-no-files-found: error`.
- Переконайся, що вміст workflow не містить слів `token`, `password` чи `secret` без урахування регістру.
- Повідом окремо, якщо `ci.sh` не має executable bit або не вдалося перевірити його.

## Типова помилка

Якщо `ci.sh` не має executable bit, виклик `./ci.sh` на Linux/macOS завершується помилкою. Перевір Git mode скрипту; якщо він відстежується, підкажи користувачу `git update-index --chmod=+x ci.sh`. Не маскуй проблему заміною на `bash ci.sh`, бо workflow має викликати саме `./ci.sh`.

## Приклад

**Вхід:**

    Є ci.sh і ci.bat. Налаштуй CI на develop/master для Linux, Windows і macOS.

**Очікуваний результат:**

    Створено .github/workflows/ci.yml з однією matrix-job для трьох ОС.
    Linux/macOS запускають ./ci.sh через bash; Windows запускає ci.bat через cmd.
    Workflow завантажує dist/ як артефакт hello-${{ matrix.os }}.
    YAML валідний; прямих команд Python, pip і pytest та заборонених слів немає.