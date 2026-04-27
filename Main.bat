@echo off
setlocal enabledelayedexpansion
title Main.bat - High Performance Pipeline

:: --- Cấu hình GitHub ---
set "REPO_RAW=https://raw.githubusercontent.com/Username/Repo/main"

echo ======================================================
echo           M - STEAM & CS2 AUTO OPTIMIZER
echo ======================================================
echo.

:: Bước 1: Hỏi về Override High DPI
set /p "choice=Ban co muon bat Override High DPI (Application) cho CS2 khong? (Y/N): "

:: Bước 2: Tìm đường dẫn Steam và CS2 tự động
echo [*] Dang tim duong dan CS2 tu dong...
for /f "tokens=2*" %%a in ('reg query "HKEY_CURRENT_USER\Software\Valve\Steam" /v "SteamPath" 2^>nul') do set "STEAM_ROOT=%%b"

if not defined STEAM_ROOT (
    echo [!] Khong tim thay Steam trong Registry. Hay kiem tra lai!
    pause & exit
)

:: Chuyển đổi slash từ / sang \ cho đúng định dạng Windows
set "STEAM_ROOT=%STEAM_ROOT:/=\%"
set "CS2_BASE_PATH=%STEAM_ROOT%\steamapps\common\Counter-Strike Global Offensive"
set "CFG_PATH=%CS2_BASE_PATH%\game\csgo\cfg"
set "EXE_PATH=%CS2_BASE_PATH%\game\bin\win64\cs2.exe"

:: Kiểm tra xem thư mục game có tồn tại không
if not exist "%CFG_PATH%" (
    echo [!] Khong tim thay thu muc CS2 tai: %CS2_BASE_PATH%
    echo [!] Hay chac chan ban da cai game vao o mac dinh hoac o dang dung.
    pause & exit
)

:: Bước 3: Tải và lưu Config
echo [*] Dang tai autoexec.cfg tu GitHub...
curl -sL "%REPO_RAW%/cs2_files/autoexec.cfg" -o "%CFG_PATH%\autoexec.cfg"
if %errorlevel% equ 0 (echo [OK] Da luu config vao: %CFG_PATH%) else (echo [ERR] Tai config that bai.)

:: Bước 4: Xử lý Override Application (DPI) dựa trên lựa chọn ban đầu
if /i "%choice%"=="Y" (
    echo [*] Dang cau hinh Override Application cho cs2.exe...
    if exist "%EXE_PATH%" (
        reg add "HKCU\Software\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "%EXE_PATH%" /t REG_SZ /d "~ DPIUNAWARE" /f >nul
        echo [OK] Da bat High DPI Scaling Override.
    ) else (
        echo [!] Khong tim thay file cs2.exe de setup DPI.
    )
) else (
    echo [*] Bo qua buoc cau hinh Override Application.
)

:: Bước 5: Chạy Optimize PowerShell
echo [*] Dang tai va thuc thi danh sach toi uu he thong...
curl -sL "%REPO_RAW%/win_tweaks/optimize.ps1" -o "%TEMP%\optimize.ps1"
if %errorlevel% equ 0 (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%TEMP%\optimize.ps1"
    echo [OK] Toi uu he thong hoan tat.
) else (
    echo [ERR] Khong the tai file optimize.ps1.
)

:: Bước 6: Kết thúc
echo.
echo ======================================================
echo [!] HOAN THANH TOAN BO QUY TRINH!
echo [!] Main.bat se tu dong dong sau 3 giay.
echo ======================================================
timeout /t 3 >nul
exit
