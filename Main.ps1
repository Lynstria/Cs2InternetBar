<#
.SYNOPSIS
    CIBO Core Pipeline v3.4 - Robust Execution & Dependency Fix
#>

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$PYTHON_PORTABLE_URL = "https://github.com/Lynstria/Cs2InternetBar/releases/download/1.0/python-portable.zip"
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "            VER 3.4 - DEPENDENCY AUTO-FIX             " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

# Stage 0: Tải & giải nén Python portable
Write-Host "`n[0] Downloading Python portable (~50MB)..." -ForegroundColor Yellow
$WORK_DIR = Join-Path $env:TEMP "CIBO_Bootstrap"
if (Test-Path $WORK_DIR) { Remove-Item $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $WORK_DIR -Force | Out-Null

$pythonZip = Join-Path $WORK_DIR "python-portable.zip"
try {
    Invoke-WebRequest -Uri $PYTHON_PORTABLE_URL -OutFile $pythonZip -ErrorAction Stop
} catch {
    Write-Host "[!] Failed to download Python portable. Check your internet." -ForegroundColor Red
    pause
    exit 1
}

Write-Host "[0] Extracting Python..." -ForegroundColor Yellow
Expand-Archive -Path $pythonZip -DestinationPath $WORK_DIR -Force
Remove-Item $pythonZip

$pythonDir = Get-ChildItem -Path $WORK_DIR -Recurse -Filter "python.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $pythonDir) {
    Write-Host "[!] python.exe not found!" -ForegroundColor Red
    pause
    exit 1
}
$pythonExe = $pythonDir.FullName
$pythonRoot = $pythonDir.Directory.FullName

# Cập nhật PATH
$env:PATH = "$pythonRoot;$pythonRoot\Scripts;$env:PATH"

# Cài đặt các thư viện bắt buộc vào portable Python
Write-Host "[0] Installing required Python modules (vdf, psutil, pywin32, requests)..." -ForegroundColor Yellow
try {
    & $pythonExe -m pip install --quiet --disable-pip-version-check --target "$pythonRoot\Lib\site-packages" vdf psutil pywin32 requests
    if ($LASTEXITCODE -ne 0) { throw "pip install failed" }
    Write-Host "[0] Dependencies installed." -ForegroundColor Green
} catch {
    Write-Host "[!] Failed to install Python packages. Using system Python if available..." -ForegroundColor Yellow
    # Fallback: thử dùng python hệ thống nếu có
    $pythonExe = (Get-Command python.exe -ErrorAction SilentlyContinue).Source
    if (-not $pythonExe) {
        Write-Host "[!] No Python available. Exiting." -ForegroundColor Red
        pause
        exit 1
    }
}
$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONUTF8 = 1

Write-Host "[0] Python ready: $pythonExe" -ForegroundColor Green

# Stage 1: User Intent
$deployConfig = Read-Host "`n[?] Deploy autoexec.cfg? (Y/N)"

# Stage 2: Locate CS2
Write-Host "`n[*] Locating CS2 (auto-detection + folder picker fallback)..." -ForegroundColor Yellow

$findCs2Temp = Join-Path $WORK_DIR "FindCs2.py"
try {
    Invoke-WebRequest -Uri "$REPO_RAW/CS2/FindCs2.py" -OutFile $findCs2Temp -ErrorAction Stop
} catch {
    Write-Host "[!] Failed to download FindCs2.py" -ForegroundColor Red
    pause
    exit 1
}

$cs2Base = $null
try {
    $pythonOutput = & $pythonExe $findCs2Temp 2>&1
    foreach ($line in $pythonOutput) {
        if ($line -match "CS2PATH:(.+)") {
            $cs2Base = $Matches[1].Trim()
            break
        }
    }
} catch {
    Write-Host "[!] Error running FindCs2.py" -ForegroundColor Red
}

if (-not $cs2Base -or $cs2Base -eq "NOT_FOUND") {
    Write-Host "[!] CS2 not found. Installation cancelled." -ForegroundColor Red
    pause
    exit 1
}
Write-Host "[+] CS2 Path: $cs2Base" -ForegroundColor Green

# Stage 3: Execute ResultCs2.py
$resultArgs = @("--cs2-path", $cs2Base)
if ($deployConfig -ne "Y" -and $deployConfig -ne "y") {
    $resultArgs += "--skip-config"
}

$resultCs2Temp = Join-Path $WORK_DIR "ResultCs2.py"
try {
    Invoke-WebRequest -Uri "$REPO_RAW/CS2/ResultCs2.py" -OutFile $resultCs2Temp -ErrorAction Stop
    Write-Host "[*] Running ResultCs2.py..." -ForegroundColor Yellow
    & $pythonExe $resultCs2Temp $resultArgs
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] ResultCs2.py exited with code $LASTEXITCODE" -ForegroundColor Yellow
    } else {
        Write-Host "[SUCCESS] Config & DPI applied." -ForegroundColor Green
    }
} catch {
    Write-Host "[!] ResultCs2.py failed: $_" -ForegroundColor Red
}

# Stage 4: Optimize System
Write-Host "`n[*] Applying Windows streaming optimizations..." -ForegroundColor Yellow
$optimizeTemp = Join-Path $WORK_DIR "optimize.ps1"
try {
    Invoke-WebRequest -Uri "$REPO_RAW/WinTweaks/optimize.ps1" -OutFile $optimizeTemp -ErrorAction Stop
    Write-Host "[*] Running optimize.ps1 (Administrator required)..." -ForegroundColor Yellow
    # Chạy file tạm thay vì Invoke-Expression
    & $optimizeTemp
    Write-Host "[+] Optimization complete." -ForegroundColor Green
} catch {
    Write-Host "[!] Optimize script error: $_" -ForegroundColor Red
}

# Cleanup
Write-Host "`n[*] Cleaning up temporary files..." -ForegroundColor Gray
Remove-Item $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host " [!] PIPELINE FINISHED - READY TO PRE-FIRE" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
pause