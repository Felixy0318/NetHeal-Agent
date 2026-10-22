$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location -LiteralPath $RepoRoot

$BootstrapPython = $null
$BootstrapArgs = @()
$PythonCandidates = @(
    @{ Command = "py"; Args = @("-3.11") },
    @{ Command = "python"; Args = @() },
    @{ Command = "py"; Args = @("-3") },
    @{ Command = "python3"; Args = @() }
)

foreach ($Candidate in $PythonCandidates) {
    $Resolved = Get-Command $Candidate.Command -ErrorAction SilentlyContinue
    if (-not $Resolved) {
        continue
    }

    $CandidateArgs = @($Candidate.Args)
    try {
        $VersionOk = & $Resolved.Source @CandidateArgs -c "import sys; print(int(sys.version_info >= (3, 11)))" 2>$null
        if ($LASTEXITCODE -eq 0 -and $VersionOk.Trim() -eq "1") {
            $BootstrapPython = $Resolved.Source
            $BootstrapArgs = $CandidateArgs
            break
        }
    } catch {
        continue
    }
}

if (-not $BootstrapPython) {
    throw "Python 3.11 or newer was not found. Install Python 3.11+ or make it available through the Windows 'py' launcher."
}

$SelectedVersion = & $BootstrapPython @BootstrapArgs -c "import sys; print('.'.join(map(str, sys.version_info[:3])))"
Write-Host "[0/5] Using Python $SelectedVersion"

$VenvPython = Join-Path $RepoRoot ".venv\Scripts\python.exe"
if (-not (Test-Path -LiteralPath $VenvPython)) {
    Write-Host "[1/5] Creating Python virtual environment..."
    & $BootstrapPython @BootstrapArgs -m venv (Join-Path $RepoRoot ".venv")
    if ($LASTEXITCODE -ne 0) { throw "Creating the Python virtual environment failed." }
}

Write-Host "[2/5] Installing pinned dependencies..."
& $VenvPython -m pip install --upgrade pip
if ($LASTEXITCODE -ne 0) { throw "Upgrading pip failed." }
& $VenvPython -m pip install -r (Join-Path $RepoRoot "requirements.txt")
if ($LASTEXITCODE -ne 0) { throw "Installing project dependencies failed." }

$EnvFile = Join-Path $RepoRoot ".env"
if (-not (Test-Path -LiteralPath $EnvFile)) {
    Write-Host "[3/5] Creating local .env from the safe template..."
    Copy-Item -LiteralPath (Join-Path $RepoRoot ".env_template") -Destination $EnvFile
} else {
    Write-Host "[3/5] Existing .env preserved."
}

Write-Host "[4/5] Running NetHeal automated tests..."
& $VenvPython -m unittest discover -s tests -p "test_netheal*.py" -v
if ($LASTEXITCODE -ne 0) { throw "NetHeal automated tests failed." }

Write-Host "[5/5] Running six acceptance cases..."
& $VenvPython -m app.netheal.acceptance_runner
if ($LASTEXITCODE -ne 0) { throw "NetHeal acceptance cases failed." }

Write-Host ""
Write-Host "Setup complete. Start with:"
Write-Host "  .\.venv\Scripts\python.exe cosight_server\deep_research\main.py"
Write-Host "Open Co-Sight: http://localhost:7788/cosight/"
Write-Host "Open NetHeal:  http://localhost:7788/cosight/netheal.html"
