$ErrorActionPreference = "Stop"
Set-Location -LiteralPath $PSScriptRoot

if (-not (Test-Path -LiteralPath ".venv\Scripts\python.exe")) {
    Write-Host "[NetHeal-Agent] First run: creating the Python environment and installing dependencies..."
    & "$PSScriptRoot\setup-netheal.ps1"
}

Write-Host "[NetHeal-Agent] Starting Co-Sight on http://localhost:7788/cosight/ ..."
& "$PSScriptRoot\.venv\Scripts\python.exe" "$PSScriptRoot\cosight_server\deep_research\main.py"

