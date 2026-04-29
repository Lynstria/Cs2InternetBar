# ==============================================================================
# Project: CS2 InternetBar Optimizer (CIBO)
# Component: Orchestrator Pipeline (Main.ps1)
# Version: 1.3.4 - Hybrid (Reg + Process + Manual Pick)
# ==============================================================================

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Stop"

# Thêm assembly để hiện hộp thoại chọn folder
Add-Type -AssemblyName System.Windows.Forms

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "            VER 1.3.4 - HYBRID DETECTION              " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

try {
    # --- STAGE 1: User Intent ---
    $deployConfig = Read-Host "`n[?] Deploy autoexec.cfg? (Y/N)"
    $deployDPI    = Read-Host "[?] Deploy High DPI Override? (Y/N)"

    # --- STAGE 2: Environment Discovery ---
    Write-Host "`n[*] Locating Steam/CS2 Environment..." -ForegroundColor Gray
    $steamRoot = $null
    $cs2Base   = $null

    # 1. Nhẹ đô: Registry
    $reg = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
    if ($reg) { $steamRoot = $reg.SteamPath -replace '/', '\' }

    # 2. Nặng đô: Task Manager (nếu registry không có hoặc sai)
    if (-not $steamRoot -or -not (Test-Path "$steamRoot\steamapps\common\Counter-Strike Global Offensive")) {
        $proc = Get-CimInstance Win32_Process -Filter "Name='steam.exe'" | Select-Object -First 1
        if ($proc.ExecutablePath) { $steamRoot = Split-Path $proc.ExecutablePath -Parent }
    }

    # Kiểm tra lại đường dẫn CS2 sau 2 bước tự động
    if ($steamRoot) {
        $checkPath = Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"
        if (Test-Path $checkPath) { $cs2Base = $checkPath }
    }

    # 3. Phương án cuối cùng: Chọn thủ công (Manual Pick)
    if (-not $cs2Base) {
        Write-Host "[!] Could not auto-detect CS2. Please select folder manually..." -ForegroundColor Yellow
        $Browser = New-Object System.Windows.Forms.FolderBrowserDialog
        $Browser.Description = "Chọn thư mục gốc của CS2 (Thư mục 'Counter-Strike Global Offensive')"
        $Browser.ShowNewFolderButton = $false
        
        $result = $Browser.ShowDialog()
        if ($result -eq "OK") {
            $cs2Base = $Browser.SelectedPath
        } else {
            throw "User cancelled folder selection. Execution aborted."
        }
    }

    # Xác lập các nhánh con
    $cfgPath = Join-Path $cs2Base "game\csgo\cfg"
    $exePath = Join-Path $cs2Base "game\bin\win64\cs2.exe"

    # Kiểm tra tính hợp lệ của folder đã chọn/tìm thấy
    if (-not (Test-Path $cfgPath)) { throw "Invalid CS2 Folder! Missing 'game\csgo\cfg'." }

    Write-Host "[+] Target: $cs2Base" -ForegroundColor Green

    # --- STAGE 3: Deploy Config ---
    if ($deployConfig -eq "Y" -or $deployConfig -eq "y") {
        Write-Host "[*] Downloading autoexec.cfg..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri "$REPO_RAW/CS2/autoexec.cfg" -OutFile "$cfgPath\autoexec.cfg" -Force
        Write-Host "[SUCCESS] Config injected!" -ForegroundColor Green
    }

    # --- STAGE 4: DPI Override ---
    if ($deployDPI -eq "Y" -or $deployDPI -eq "y") {
        if (Test-Path $exePath) {
            Write-Host "[*] Applying DPI Registry Tweak..." -ForegroundColor Yellow
            $regKey = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
            if (-not (Test-Path $regKey)) { New-Item $regKey -Force | Out-Null }
            New-ItemProperty -Path $regKey -Name $exePath -Value "~ DPIUNAWARE" -PropertyType String -Force | Out-Null
            Write-Host "[SUCCESS] DPI Fixed!" -ForegroundColor Green
        }
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
