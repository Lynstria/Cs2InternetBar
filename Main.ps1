# ==============================================================================
# Project: CS2 InternetBar Optimizer (CIBO)
# Component: Orchestrator Pipeline (Main.ps1)
# Version: 1.3.0 (27/04/2026) - Dual Choice + Online Config Version
# ==============================================================================

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "                  VER 1.3.0 - DUAL CHOICE             " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

try {
    # --- STAGE 0: Fetch Online Config Version (luôn quét GitHub) ---
    Write-Host "[*] Checking latest autoexec.cfg version from GitHub..." -ForegroundColor Gray
    try {
        $configRaw = Invoke-RestMethod -Uri "$REPO_RAW/CS2/autoexec.cfg" -TimeoutSec 10
        $configLines = $configRaw -split "`r?`n"
        if ($configLines.Count -ge 3) {
            $versionLine = $configLines[1].Trim()
            Write-Host "[+] Latest config detected: $versionLine" -ForegroundColor Green
        } else {
            Write-Host "[!] Could not read config version (unexpected format)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "[!] Warning: Cannot fetch config version from GitHub" -ForegroundColor Yellow
    }

    # --- STAGE 1: User Intent (2 câu hỏi riêng biệt) ---
    Write-Host "`n[?] Deploy autoexec.cfg (config)? (Y/N)" -ForegroundColor Yellow
    $deployConfig = Read-Host
    Write-Host "[?] Deploy High DPI Scaling Override for CS2? (Y/N)" -ForegroundColor Yellow
    $deployDPI = Read-Host

    # --- STAGE 2: Environment Discovery ---
    Write-Host "`n[*] Detecting Steam & CS2 folder..." -ForegroundColor Gray
    $steamRegistry = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
    if (-not $steamRegistry) { throw "SteamPath not found in Registry!" }

    $steamRoot = $steamRegistry.SteamPath -replace '/', '\'
    $cs2Base   = Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"
    $cfgPath   = Join-Path $cs2Base "game\csgo\cfg"
    $exePath   = Join-Path $cs2Base "game\bin\win64\cs2.exe"

    Write-Host "[+] CS2 folder detected: $cs2Base" -ForegroundColor Green

    # --- STAGE 3: Deploy Config (chỉ chạy nếu người dùng chọn Y) ---
    if ($deployConfig -eq "Y" -or $deployConfig -eq "y") {
        if (Test-Path $cfgPath) {
            Write-Host "[*] Downloading latest autoexec.cfg..." -ForegroundColor Yellow
            Invoke-WebRequest -Uri "$REPO_RAW/CS2/autoexec.cfg" -OutFile "$cfgPath\autoexec.cfg" -TimeoutSec 15
            Write-Host "[SUCCESS] autoexec.cfg deployed!" -ForegroundColor Green
        } else {
            throw "CS2 cfg folder not found! Please verify CS2 is installed correctly."
        }
    } else {
        Write-Host "[SKIP] autoexec.cfg deployment skipped by user" -ForegroundColor Gray
    }

    # --- STAGE 4: DPI Override (chỉ chạy nếu người dùng chọn Y) ---
    if ($deployDPI -eq "Y" -or $deployDPI -eq "y") {
        Write-Host "[*] Applying DPI Scaling Override..." -ForegroundColor Yellow
        if (Test-Path $exePath) {
            $regKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $exePath -Value "~ DPIUNAWARE" -PropertyType String -Force | Out-Null
            Write-Host "[SUCCESS] DPI Override applied to cs2.exe" -ForegroundColor Green
        } else {
            Write-Host "[SKIP] cs2.exe not found → DPI override skipped" -ForegroundColor Gray
        }
    } else {
        Write-Host "[SKIP] DPI Override skipped by user" -ForegroundColor Gray
    }

    # --- STAGE 5: WinTweaks (BẮT BUỘC - luôn chạy) ---
    Write-Host "`n[*] Streaming WinTweaks/optimize.ps1 (FORCED)..." -ForegroundColor Yellow
    $optimizeContent = Invoke-RestMethod -Uri "$REPO_RAW/WinTweaks/optimize.ps1" -TimeoutSec 10
    Invoke-Expression $optimizeContent
    Write-Host "[SUCCESS] WinTweaks executed!" -ForegroundColor Green

} catch {
    Write-Host "`n[!] ERROR: $($_.Exception.Message)" -ForegroundColor White -BackgroundColor Red
    Write-Host "[!] Trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
} finally {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host " [!] CIBO PIPELINE HOÀN TẤT - READY TO PRE-FIRE" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Cyan
    Start-Sleep -Seconds 3
}
