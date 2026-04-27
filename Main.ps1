# --- Cấu hình nguồn ---
$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "          M - POWERSHELL STREAMING PIPELINE" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan

# Bước 1: Hỏi (Y/N)
$choice = Read-Host "Ban co muon bat Override High DPI cho CS2 khong? (Y/N)"

# Bước 2: tìm đường dẫn Steam & CS2 từ Registry
$steamPath = Get-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamPath" -ErrorAction SilentlyContinue
if (-not $steamPath) {
    Write-Host "[!] Khong tim thay Steam. Huy quy trinh." -ForegroundColor Red
    return
}

$steamRoot = $steamPath.SteamPath -replace '/', '\'
$cs2Base = Join-Path $steamRoot "steamapps\common\Counter-Strike Global Offensive"
$cfgPath = Join-Path $cs2Base "game\csgo\cfg"
$exePath = Join-Path $cs2Base "game\bin\win64\cs2.exe"

# Bước 3: Tải Config (Chỉ tải file này về ổ cứng)
if (Test-Path $cfgPath) {
    Write-Host "[*] Dang tai autoexec.cfg..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri "$REPO_RAW/CS2/autoexec.cfg" -OutFile "$cfgPath\autoexec.cfg"
    Write-Host "[OK] Da luu config vao folder game." -ForegroundColor Green
}

# Bước 4: Xử lý Override DPI (Registry)
if ($choice -eq "Y" -or $choice -eq "y") {
    if (Test-Path $exePath) {
        $registryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers"
        if (-not (Test-Path $registryPath)) { New-Item -Path $registryPath -Force }
        New-ItemProperty -Path $registryPath -Name $exePath -Value "~ DPIUNAWARE" -PropertyType String -Force | Out-Null
        Write-Host "[OK] Da bat High DPI Scaling Override." -ForegroundColor Green
    }
}

# Bước 5: Stream file Optimize trực tiếp từ RAM
Write-Host "[*] Dang thuc thi goi toi uu tu RAM..." -ForegroundColor Yellow
$optimizeScript = Invoke-RestMethod -Uri "$REPO_RAW/WinTweaks/optimize.ps1"
Invoke-Expression $optimizeScript

Write-Host "`n[!] HOAN THANH" -ForegroundColor Cyan
Start-Sleep -Seconds 3
