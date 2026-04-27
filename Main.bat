@echo off
setlocal enabledelayedexpansion
title Main.bat - Cs2InternetBar Pipeline

:: --- Cấu hình link GitHub Raw của bạn ---
:: Lưu ý: Cấu trúc là raw.githubusercontent.com/User/Repo/Branch
set "REPO_RAW=https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"

echo ======================================================
echo           M - CS2 INTERNET BAR OPTIMIZER
echo ======================================================
echo.

:: Bước 1: Hỏi về Override High DPI
set /p "choice=Ban co muon bat Override High DPI (Application) cho CS2 khong? (Y/N): "

:: Bước 2: Tìm đường dẫn Steam và CS2 tự động từ Registry
echo [*] Dang tim duong dan CS2 tu dong...
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "STEAM_ROOT=%%b"

if not defined STEAM_ROOT (
    echo [!] Khong tim thay Steam. Hay kiem tra lai!
    pause & exit
)

:: Chỉnh sửa định dạng đường dẫn
set "STEAM_ROOT=%STEAM_ROOT:/=\%"
set "CS2_BASE_PATH=%STEAM_ROOT%\steamapps\common\Counter-Strike Global Offensive"
set "CFG_PATH=%CS2_BASE_PATH%\game\csgo\cfg"
set "EXE_PATH=%CS2_BASE_PATH%\game\bin\win64\cs2.exe"

:: Kiểm tra thư mục game
if not exist "%CFG_PATH%" (
    echo [!] Khong tim thay thu muc CS2 tai: %CS2_BASE_PATH%
    pause & exit
)

:: Bước 3: Tải và lưu Config (Đúng đường dẫn CS2/autoexec.cfg)
echo [*] Dang tai autoexec.cfg tu GitHub...
curl -sL "%REPO_RAW%/CS2/autoexec.cfg" -o "%CFG_PATH%\autoexec.cfg"
if %errorlevel% equ 0 (echo [OK] Da luu config vao: %CFG_PATH%) else (echo [ERR] Tai config that bai.)

:: Bước 4: Xử lý Override Application (DPI)
if /i "%choice%"=="Y" (
    echo [*] Dang cau hinh Override Application cho cs2.exe...
    if exist "%EXE_PATH%" (
        reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%EXE_PATH%" /t REG_SZ /d "~ DPIUNAWARE" /f >nul
        echo [OK] Da bat High DPI Scaling Override.
    ) else (
        echo [!] Khong tim thay file cs2.exe.
    )
)

:: Bước 5: Thực thi Optimize PowerShell trực tiếp từ GitHub (Không lưu file)
echo [*] Dang stream va thuc thi danh sach toi uu tu GitHub...

powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((New-Object System.Net.WebClient).DownloadString('%REPO_RAW%/WinTweaks/optimize.ps1'))"

if %errorlevel% equ 0 (
    echo [OK] Toi uu he thong hoan tat truc tiep tu RAM.
) else (
    echo [ERR] Co loi trong qua trinh thuc thi script toi uu.
)

:: Bước 6: Kết thúc
echo.
echo ======================================================
echo [!] HOAN THANH! CHUC BAN LEO RANK THUAN LOI.
echo ======================================================
timeout /t 3 >nul
exit
