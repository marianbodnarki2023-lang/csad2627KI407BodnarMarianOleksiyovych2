@echo off
if exist .venv\Scripts\python.exe goto venv_ready
if exist .venv goto invalid_venv
python -m venv .venv
if errorlevel 1 exit /b %errorlevel%
goto venv_ready

:invalid_venv
echo Existing .venv has no Python interpreter.
exit /b 1

:venv_ready
.venv\Scripts\python.exe -m pip install -r requirements.txt
if errorlevel 1 exit /b %errorlevel%
.venv\Scripts\python.exe src\hello.py
if errorlevel 1 exit /b %errorlevel%