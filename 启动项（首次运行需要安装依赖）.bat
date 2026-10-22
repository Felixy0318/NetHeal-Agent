@echo off
setlocal
cd /d "%~dp0"

if not exist ".venv\Scripts\python.exe" (
  echo [NetHeal-Agent] First run: creating the Python environment and installing dependencies...
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-netheal.ps1"
  if errorlevel 1 (
    echo [NetHeal-Agent] Setup failed. Review the message above.
    pause
    exit /b 1
  )
)

echo [NetHeal-Agent] Starting Co-Sight on http://localhost:7788/cosight/ ...
".venv\Scripts\python.exe" "cosight_server\deep_research\main.py"
if errorlevel 1 (
  echo [NetHeal-Agent] The service exited with an error.
  pause
  exit /b 1
)

