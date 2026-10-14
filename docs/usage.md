# Використання проєкту

Усі команди нижче виконуйте з кореня репозиторію.

## Запуск агента

1. Відкрийте папку проєкту у VS Code.
2. Відкрийте Copilot Chat.
3. Виберіть агента `build-engineer`.
4. Виконайте `/init`, щоб послідовно створити проєкт, налаштувати збірку й CI та запустити фінальну перевірку.
5. Виконайте `/check`, щоб окремо перевірити вже створений проєкт у режимі лише читання.

## Локальна збірка й перевірка

Linux/macOS:

```bash
./ci.sh
```

Windows:

```bat
ci.bat
```

Скрипти встановлюють залежності у `.venv`, запускають тести та копіюють застосунок у `dist/`.

## Запуск Hello World

Запуск файлу з `dist/`:

Linux/macOS:

```bash
python3 dist/hello.py
```

Windows:

```bat
python dist\hello.py
```

Також можна запустити скрипт, який використовує вихідний файл із `src/` і встановлює залежності у `.venv`:

Linux/macOS:

```bash
./run.sh
```

Windows:

```bat
run.bat
```

## Запуск тестів

Linux/macOS:

```bash
.venv/bin/python -m pytest -v
```

Windows:

```bat
.venv\Scripts\python -m pytest -v
```