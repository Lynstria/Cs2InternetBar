<#
.SYNOPSIS
    CIBO Core Pipeline - Low-Latency Streaming Setup
    Tải và chạy Python scripts trực tiếp từ GitHub, không cài file thừa.
#>

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "            VER 2.0 - GITHUB NATIVE EXECUTION         " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

# Kiểm tra Python
try {
    $null = Get-Command python -ErrorAction Stop
} catch {
    Write-Host "[!] Python not found. Please install Python 3 and required libraries." -ForegroundColor Red
    pause
    exit 1
}

# --- STAGE 1: User Intent ---
$deployConfig = Read-Host "`n[?] Deploy autoexec.cfg? (Y/N)"

# --- STAGE 2: Locate CS2 ---
Write-Host "`n[*] Locating CS2 environment..." -ForegroundColor Yellow

# Tải FindCs2.py về file tạm
$findCs2Temp = [System.IO.Path]::GetTempFileName() + ".py"
try {
    Invoke-WebRequest -Uri "$REPO_RAW/CS2/FindCs2.py" -OutFile $findCs2Temp -ErrorAction Stop
} catch {
    Write-Host "[!] Failed to download FindCs2.py" -ForegroundColor Red
    exit 1
}

# Chạy FindCs2.py và lấy đường dẫn CS2
$cs2Base = $null
try {
    $pythonOutput = & python $findCs2Temp 2>&1
    # Tìm dòng chứa "CS2PATH:" (FindCs2.py được sửa để in ra dòng này khi thành công)
    foreach ($line in $pythonOutput) {
        if ($line -match "CS2PATH:(.+)") {
            $cs2Base = $Matches[1].Trim()
            break
        }
    }
    if (-not $cs2Base) {
        # Fallback: tìm dòng "✅ Đã tìm thấy CS2 tại:"
        foreach ($line in $pythonOutput) {
            if ($line -match "Đã tìm thấy CS2 tại: (.+)") {
                $cs2Base = $Matches[1].Trim()
                break
            }
        }
    }
} catch {
    Write-Host "[!] Error running FindCs2.py" -ForegroundColor Red
    $cs2Base = $null
} finally {
    Remove-Item $findCs2Temp -Force -ErrorAction SilentlyContinue
}

if (-not $cs2Base) {
    Write-Host "[!] Could not auto-detect CS2. Manual fallback not implemented in hybrid mode." -ForegroundColor Red
    exit 1
}
Write-Host "[+] CS2 Path: $cs2Base" -ForegroundColor Green

# --- STAGE 3: Execute ResultCs2.py ---
$resultArgs = @("--cs2-path", $cs2Base)
if ($deployConfig -ne "Y" -and $deployConfig -ne "y") {
    $resultArgs += "--skip-config"
}

$resultCs2Temp = [System.IO.Path]::GetTempFileName() + ".py"
try {
    Invoke-WebRequest -Uri "$REPO_RAW/CS2/ResultCs2.py" -OutFile $resultCs2Temp -ErrorAction Stop
    Write-Host "[*] Running ResultCs2.py..." -ForegroundColor Yellow
    $proc = Start-Process -FilePath python -ArgumentList "$resultCs2Temp $resultArgs" -Wait -NoNewWindow -PassThru
    if ($proc.ExitCode -ne 0) {
        throw "ResultCs2.py exited with code $($proc.ExitCode)"
    }
    Write-Host "[SUCCESS] ResultCs2 tasks completed." -ForegroundColor Green
} catch {
    Write-Host "[!] ResultCs2.py failed: $_" -ForegroundColor Red
} finally {
    Remove-Item $resultCs2Temp -Force -ErrorAction SilentlyContinue
}

# --- STAGE 4: Optimize System ---
Write-Host "`n[*] Applying Windows streaming optimizations..." -ForegroundColor Yellow
try {
    $optimizeScript = Invoke-RestMethod -Uri "$REPO_RAW/WinTweaks/optimize.ps1"
    Invoke-Expression $optimizeScript
} catch {
    Write-Host "[!] Optimize script error: $_" -ForegroundColor Red
}

# Kết thúc
Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host " [!] PIPELINE FINISHED - READY TO PRE-FIRE" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
Start-Sleep -Seconds 2