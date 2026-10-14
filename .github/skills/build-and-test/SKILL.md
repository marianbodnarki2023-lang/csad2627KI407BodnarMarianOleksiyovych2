---
name: build-and-test
description: "Use after src/hello.py and src/add.py exist to configure pytest, run scripts, and cross-platform build/test scripts for a Python project using venv."
---

# Build and Test

## Вхід

Перед початком мають існувати:

- `src/hello.py`
- `src/add.py`

Якщо будь-якого файла немає, зупинись і повідом, що потрібно спочатку виконати scaffold.

## Вихід

Створи такі файли, якщо їх ще немає:

- `requirements.txt` із залежністю `pytest>=7`.
- `pytest.ini`:

      [pytest]
      pythonpath = src
      testpaths = tests

- `tests/test_basic.py` із тестом `test_basic_addition`, який перевіряє `assert add(2, 3) == 5`.
- `run.sh`, `run.bat`, `ci.sh` і `ci.bat` згідно з вимогами нижче.

Не перезаписуй наявні файли автоматично. Спершу порівняй їх з очікуваним вмістом; якщо вони відрізняються, повідом про розбіжність і зупинись.

### Віртуальне середовище та залежності

Створюй `.venv/` лише якщо її ще немає:

- Linux/macOS: `python3 -m venv .venv`
- Windows: `python -m venv .venv`

Не виконуй `activate`. Усі виклики Python і pip роби через інтерпретатор середовища:

- Linux/macOS: `.venv/bin/python`
- Windows: `.venv\Scripts\python.exe`

Встановлюй залежності командою `-m pip install -r requirements.txt` через відповідний інтерпретатор venv. Не додавай повторний рядок `pytest>=7` до `requirements.txt`.

### Скрипти запуску

`run.sh` має використовувати Bash із `set -euo pipefail`, створити `.venv/`, якщо її немає, встановити залежності та запустити `src/hello.py` через `.venv/bin/python`.

`run.bat` має створити `.venv`, якщо відсутній `.venv\Scripts\python.exe`, встановити залежності та запустити `src\hello.py` через `.venv\Scripts\python.exe`. Після кожної виконуваної команди — створення venv, встановлення залежностей і запуску програми — одразу перевіряй `%errorlevel%` та заверши скрипт із ненульовим кодом при помилці. Для умовного створення venv використовуй label/`goto`, а не дужковий блок, щоб `%errorlevel%` не розгортався завчасно.

### CI-скрипти

`ci.sh` має використовувати Bash із `set -euo pipefail`, створити `.venv/`, якщо її немає, встановити залежності, виконати `.venv/bin/python -m pytest -v`, а після успішних тестів скопіювати `src/hello.py` і `src/add.py` у `dist/`.

`ci.bat` має виконати ті самі кроки через `.venv\Scripts\python.exe`: створення середовища за потреби, встановлення залежностей, `-m pytest -v` і копіювання обох модулів у `dist\`. Після кожної виконуваної команди — створення venv, встановлення залежностей, запуску pytest, створення `dist\` і кожного копіювання — одразу перевіряй `%errorlevel%` та заверши скрипт із ненульовим кодом при помилці. Використовуй label/`goto` замість дужкового блоку для умовного створення venv.

Не копіюй файли в `dist/`, доки тести не пройшли. Якщо цільовий файл уже існує й відрізняється від відповідного джерела, повідом про це перед заміною.

Зроби `run.sh` і `ci.sh` виконуваними в Git index. Якщо обидва файли вже відстежуються, виконай:

    git update-index --chmod=+x -- run.sh ci.sh

Якщо файл або файли ще не відстежуються, додай до index лише ці два потрібні скрипти разом з executable bit:

    git update-index --add --chmod=+x -- run.sh ci.sh

Не додавай до index інші файли й не створюй коміт. Після команди перевір `git ls-files --stage -- run.sh ci.sh`: для обох файлів mode має бути `100755`. Якщо команда завершується помилкою або mode відрізняється, зупинись і повідом про причину.

## Перевірки

- Запусти pytest через інтерпретатор із `.venv` і перевір, що результат містить `test_basic_addition` та `PASSED`.
- Запусти `dist/hello.py` через інтерпретатор із `.venv` і перевір, що він друкує `Hello, World!`.
- Переконайся, що `dist/hello.py` і `dist/add.py` існують після успішного `ci.sh` або `ci.bat`.
- Переконайся, що `.venv/` виключена з Git.
- Повторний запуск не повинен перестворювати наявну `.venv/` або дублювати `pytest>=7` у `requirements.txt`.

Якщо `python` або `python3` не знайдено, зупинись і повідом, яка команда недоступна. На Windows Python із середовища розташований у `.venv\Scripts\`; на Linux/macOS — у `.venv/bin/`.

## Типові помилки

- Не запускай `pytest` або `pip` із системного Python: використовуй `.venv`.
- Не активуй середовище; викликай його інтерпретатор за повним відносним шляхом.
- Якщо `.venv/` потрапила під Git, перевір `.gitignore` і повідом про проблему; не додавай її до index.
- Якщо встановлення залежностей, тест або копіювання завершилися помилкою, зупинись і не повідомляй про успішну збірку.

## Приклад

**Вхід:**

    src/hello.py та src/add.py вже існують

**Очікуваний результат:**

    Створено requirements.txt, pytest.ini, tests/test_basic.py,
    run.sh, run.bat, ci.sh і ci.bat.
    test_basic_addition: PASSED
    Створено dist/hello.py і dist/add.py.
    Запуск dist/hello.py друкує: Hello, World!