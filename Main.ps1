# ==============================================================================
# Project: CS2 InternetBar Optimizer (CIBO)
# Component: Orchestrator Pipeline (Main.ps1)
# Version: 1.3.3 - Ultra Lean (Reg + Process Only)
# ==============================================================================

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Stop"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "            VER 1.3.3 - ULTRA LEAN EDITION            " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

try {
    # --- STAGE 0: Check Config Version ---
    Write-Host "[*] Checking latest autoexec.cfg version..." -ForegroundColor Gray
    try {
        $configRaw = Invoke-RestMethod -Uri "$REPO_RAW/CS2/autoexec.cfg" -TimeoutSec 5
        $versionLine = ($configRaw -split "`r?`n")[1].Trim()
        Write-Host "[+] Cloud Version: $versionLine" -ForegroundColor Green
    } catch { Write-Host "[!] Skip version check (Offline/Timeout)" -ForegroundColor Yellow }

    # --- STAGE 1: User Intent ---
    $deployConfig = Read-Host "`n[?] Deploy autoexec.cfg? (Y/N)"
    $deployDPI    = Read-Host "[?] Deploy High DPI Override? (Y/N)"

    # --- STAGE 2: Environment Discovery (Regedit -> Task Manager) ---
    Write-Host "`n[*] Locating Steam Environment..." -ForegroundColor Gray
    $steamRoot = $null

    # Cách 1: Quét Registry (Nhẹ nhất)
    $reg = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
    if ($reg) {
        $steamRoot = $reg.SteamPath -replace '/', '\'
        Write-Host "[+] Found via Registry: $steamRoot" -ForegroundColor DarkGreen
    }

    # Cách 2: Truy vấn Process từ Task Manager (Nặng đô hơn - dùng khi Reg sai)
    if (-not (Test-Path (Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"))) {
        Write-Host "[!] Default path invalid. Querying Steam Process..." -ForegroundColor Yellow
        $proc = Get-CimInstance Win32_Process -Filter "Name='steam.exe'" | Select-Object -First 1
        if ($proc.ExecutablePath) {
            $steamRoot = Split-Path $proc.ExecutablePath -Parent
            Write-Host "[+] Found via Task Manager: $steamRoot" -ForegroundColor DarkGreen
        }
    }

    if (-not $steamRoot) { throw "Could not locate Steam via Registry or Process." }

    # Thiết lập đường dẫn CS2
    $cs2Base = Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"
    $cfgPath = Join-Path $cs2Base "game\csgo\cfg"
    $exePath = Join-Path $cs2Base "game\bin\win64\cs2.exe"

    # Kiểm tra cuối cùng trước khi Deploy
    if (-not (Test-Path $cs2Base)) { 
        throw "Steam found but CS2 folder is missing at: $cs2Base" 
    }

    # --- STAGE 3: Deploy Config ---
    if ($deployConfig -eq "Y" -or $deployConfig -eq "y") {
        Write-Host "[*] Downloading autoexec.cfg..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "$REPO_RAW/CS2/autoexec.cfg" -OutFile "$cfgPath\autoexec.cfg" -Force
        Write-Host "[SUCCESS] Config injected!" -ForegroundColor Green
    }

    # --- STAGE 4: DPI Override ---
    if ($deployDPI -eq "Y" -or $deployDPI -eq "y") {
        Write-Host "[*] Applying DPI Registry Tweak..." -ForegroundColor Yellow
        $regKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
        if (-not (Test-Path $regKey)) { New-Item $regKey -Force | Out-Null }
        New-ItemProperty -Path $regKey -Name $exePath -Value "~ DPIUNAWARE" -PropertyType String -Force | Out-Null
        Write-Host "[SUCCESS] DPI Fixed!" -ForegroundColor Green
    }

    # --- STAGE 5: WinTweaks ---
    Write-Host "`n[*] Streaming Optimizer..." -ForegroundColor Yellow
    $opt = Invoke-RestMethod -Uri "$REPO_RAW/WinTweaks/optimize.ps1"
    Invoke-Expression $opt

} catch {
    Write-Host "`n[!] FATAL ERROR: $($_.Exception.Message)" -ForegroundColor White -BackgroundColor Red
} finally {
    Write-Host "`n======================================================" -ForegroundColor Cyan
    Write-Host " [!] PIPELINE FINISHED - READY TO PRE-FIRE" -ForegroundColor Green
    Write-Host "======================================================" -ForegroundColor Cyan
    Start-Sleep -Seconds 2
}
