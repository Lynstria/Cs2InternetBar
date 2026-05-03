<#
.SYNOPSIS
    CIBO Core Pipeline v3.6 - Self-Healing Pip for Bare Metal
#>

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$PYTHON_PORTABLE_URL = "https://github.com/Lynstria/Cs2InternetBar/releases/download/1.0/python-portable.zip"
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "            VER 3.6 - SELF-HEALING PIP                " -ForegroundColor Green
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

# Chưa thêm PATH vào hệ thống

# --- Hàm sửa pip nếu bị lỗi ---
function Repair-Pip {
    Write-Host "[*] Attempting to repair pip..." -ForegroundColor Yellow
    try {
        # Thử ensurepip có sẵn
        & $pythonExe -m ensurepip --upgrade 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[+] Pip repaired via ensurepip." -ForegroundColor Green
            return $true
        }
    } catch {}

    # Nếu không được, tải get-pip.py
    $getPip = Join-Path $WORK_DIR "get-pip.py"
    try {
        Invoke-WebRequest -Uri "https://bootstrap.pypa.io/get-pip.py" -OutFile $getPip -ErrorAction Stop
        & $pythonExe $getPip --no-setuptools --no-wheel 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[+] Pip installed via get-pip.py." -ForegroundColor Green
            return $true
        }
    } catch {
        Write-Host "[-] get-pip.py download failed." -ForegroundColor Red
    }
    return $false
}

# Cài thư viện cần thiết
Write-Host "[0] Installing required Python modules (vdf, psutil, pywin32, requests)..." -ForegroundColor Yellow
$modules = @("vdf", "psutil", "pywin32", "requests")
$installCmd = "--quiet --disable-pip-version-check --target `"$pythonRoot\Lib\site-packages`" $modules"
$pipOk = $false

try {
    & $pythonExe -m pip install $installCmd 2>&1
    if ($LASTEXITCODE -eq 0) {
        $pipOk = $true
    } else {
        throw "pip install failed with code $LASTEXITCODE"
    }
} catch {
    Write-Host "[!] Initial pip install failed. Trying to repair pip..." -ForegroundColor Yellow
    if (Repair-Pip) {
        Write-Host "[*] Retrying module installation..." -ForegroundColor Yellow
        try {
            & $pythonExe -m pip install $installCmd 2>&1
            if ($LASTEXITCODE -eq 0) { $pipOk = $true }
        } catch {}
    }
}

if (-not $pipOk) {
    # Cuối cùng, thử tìm Python hệ thống (nếu có)
    $systemPython = (Get-Command python.exe -ErrorAction SilentlyContinue).Source
    if ($systemPython) {
        $pythonExe = $systemPython
        $pythonRoot = Split-Path $systemPython -Parent
        Write-Host "[+] Using system Python: $pythonExe" -ForegroundColor Green
    } else {
        Write-Host "[!] No Python with required modules available. Exiting." -ForegroundColor Red
        pause
        exit 1
    }
} else {
    Write-Host "[0] Modules installed into portable Python." -ForegroundColor Green
}

# Lúc này mới thêm PATH để dùng các script
$env:PATH = "$pythonRoot;$pythonRoot\Scripts;$env:PATH"
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
$pythonOutput = & $pythonExe $findCs2Temp 2>&1
foreach ($line in $pythonOutput) {
    if ($line -match "CS2PATH:(.+)") {
        $cs2Base = $Matches[1].Trim()
        break
    }
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