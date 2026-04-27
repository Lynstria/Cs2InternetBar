# ==============================================================================
# Project: CS2 InternetBar Optimizer (CIBO)
# Component: Orchestrator Pipeline (Main.ps1)
# Version: 1.1.0-Stable
# ==============================================================================

# --- Global Source Configuration ---
$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Stop" # Cấu hình để bắt mọi Exception phát sinh

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "     ⚡ CIBO CORE - LOW-LATENCY STREAMING PIPELINE ⚡" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

try {
    # --- STAGE 1: User Intent Acquisition ---
    $choice = Read-Host "[?] Deploy High DPI Scaling Override (Application) for CS2? (Y/N)"

    # --- STAGE 2: Environment Discovery & Registry Analysis ---
    Write-Host "[*] Initializing Environment Discovery..." -ForegroundColor Gray
    $steamRegistry = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue

    if (-not $steamRegistry) {
        throw "Registry Error: SteamPath not found. Ensure Steam is installed correctly."
    }

    $steamRoot = $steamRegistry.SteamPath -replace '/', '\'
    $cs2Base   = Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"
    $cfgPath   = Join-Path $cs2Base "game\csgo\cfg"
    $exePath   = Join-Path $cs2Base "game\bin\win64\cs2.exe"

    # --- STAGE 3: Artifact Deployment (I/O Operations) ---
    if (Test-Path $cfgPath) {
        Write-Host "[*] Fetching Config Artifacts from Remote Repository..." -ForegroundColor Yellow
        try {
            Invoke-WebRequest -Uri "$REPO_RAW/CS2/autoexec.cfg" -OutFile "$cfgPath\autoexec.cfg" -TimeoutSec 10
            Write-Host "[SUCCESS] Artifact 'autoexec.cfg' deployed to: $cfgPath" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to fetch CS2 config. Check Network/Repository URL." -ForegroundColor Red
        }
    } else {
        Write-Host "[WARNING] Deployment Target Not Found: $cfgPath" -ForegroundColor Yellow
    }

    # --- STAGE 4: Registry Manipulation (DPI Override) ---
    if ($choice -eq "Y" -or $choice -eq "y") {
        Write-Host "[*] Injecting Registry Keys for Application Scaling Override..." -ForegroundColor Yellow
        if (Test-Path $exePath) {
            $regKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            if (-not (Test-Path $regKey)) { New-Item -Path $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $exePath -Value "~ DPIUNAWARE" -PropertyType String -Force | Out-Null
            Write-Host "[SUCCESS] DPI Scaling Override applied to Process: cs2.exe" -ForegroundColor Green
        } else {
            Write-Host "[SKIPPED] Target Executable not found at Binary Path." -ForegroundColor Gray
        }
    }

    # --- STAGE 5: In-Memory Script Execution (Streaming) ---
    Write-Host "[*] Streaming 'WinTweaks/optimize.ps1' via Memory-Pipe..." -ForegroundColor Yellow
    try {
        $optimizeContent = Invoke-RestMethod -Uri "$REPO_RAW/WinTweaks/optimize.ps1"
        if ($null -ne $optimizeContent) {
            Invoke-Expression $optimizeContent
            Write-Host "[SUCCESS] Optimization Sequence Executed via IEX." -ForegroundColor Green
        }
    } catch {
        Write-Host "[FATAL] Pipeline Break: Unable to stream WinTweaks. Check GitHub Raw connectivity." -ForegroundColor Red
    }

} catch {
    # --- GLOBAL ERROR HANDLING ---
    Write-Host "`n[!] CRITICAL SYSTEM ERROR: $($_.Exception.Message)" -ForegroundColor White -BackgroundColor Red
    Write-Host "[!] Trace: $($_.ScriptStackTrace)" -ForegroundColor Gray
} finally {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host " [!] PIPELINE COMPLETED - SESSION TERMINATED." -ForegroundColor Cyan
    Write-Host "======================================================" -ForegroundColor Cyan
    Start-Sleep -Seconds 3
}
