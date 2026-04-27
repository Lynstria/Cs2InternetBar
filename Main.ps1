# ==============================================================================
# Project: CS2 InternetBar Optimizer (CIBO)
# Component: Orchestrator Pipeline (Main.ps1)
# Version: 1.2.2-Fixed (27/04/2026) - Stage 5 FORCED WinTweaks
# ==============================================================================

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "                  VER 1.2.2 - FORCED STAGE 5          " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

try {
    # --- STAGE 1: User Intent ---
    $choice = Read-Host "[?] Deploy High DPI Scaling Override for CS2? (Y/N)"

    # --- STAGE 2: Environment Discovery ---
    Write-Host "[*] Detecting Steam & CS2 folder..." -ForegroundColor Gray
    $steamRegistry = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
    if (-not $steamRegistry) { throw "SteamPath not found in Registry!" }

    $steamRoot = $steamRegistry.SteamPath -replace '/', '\'
    $cs2Base   = Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"
    $cfgPath   = Join-Path $cs2Base "game\csgo\cfg"
    $exePath   = Join-Path $cs2Base "game\bin\win64\cs2.exe"

    Write-Host "[+] CS2 folder detected: $cs2Base" -ForegroundColor Green

    # --- STAGE 3: Deploy Config ---
    if (Test-Path $cfgPath) {
        Write-Host "[*] Downloading latest autoexec.cfg (VER 2026)..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "$REPO_RAW/CS2/autoexec.cfg" -OutFile "$cfgPath\autoexec.cfg" -TimeoutSec 15
        Write-Host "[SUCCESS] autoexec.cfg deployed!" -ForegroundColor Green
    } else {
        throw "CS2 cfg folder not found! Please verify CS2 is installed correctly."
    }

    # --- STAGE 4: DPI Override ---
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "[*] Applying DPI Scaling Override..." -ForegroundColor Yellow
        if (Test-Path $exePath) {
            $regKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $exePath -Value "~ DPIUNAWARE" -PropertyType String -Force | Out-Null
            Write-Host "[SUCCESS] DPI Override applied to cs2.exe" -ForegroundColor Green
        }
    }

    # --- STAGE 5: WinTweaks (BẮT BUỘC - luôn chạy) ---
    Write-Host "[*] Streaming WinTweaks/optimize.ps1 (FORCED)..." -ForegroundColor Yellow
    try {
        $optimizeContent = Invoke-RestMethod -Uri "$REPO_RAW/WinTweaks/optimize.ps1" -TimeoutSec 10
        Invoke-Expression $optimizeContent
        Write-Host "[SUCCESS] WinTweaks executed!" -ForegroundColor Green
    } catch {
        throw "CRITICAL: Failed to load WinTweaks/optimize.ps1 from repository! (This step is now mandatory)"
    }

} catch {
    Write-Host "`n[!] ERROR: $($_.Exception.Message)" -ForegroundColor White -BackgroundColor Red
    Write-Host "[!] Trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
} finally {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host " [!] CIBO PIPELINE HOÀN TẤT - READY TO PRE-FIRE" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Cyan
    Start-Sleep -Seconds 3
}
