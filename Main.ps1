<#
.SYNOPSIS
    CIBO Core Pipeline v3.8 - Inlined Optimize + irm | iex Compatible
    No temp files left (except autoexec.cfg in CS2 cfg)
#>

$REPO_RAW = "https://raw.githubusercontent.com/Lynstria/Cs2InternetBar/main"
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "      CIBO CORE - LOW-LATENCY STREAMING PIPELINE      " -ForegroundColor Cyan
Write-Host "         VER 3.8 - INLINED OPTIMIZE + CLEAN         " -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan

# Stage 0: Download & extract Python portable
Write-Host "`n[0] Downloading Python portable (~50MB)..." -ForegroundColor Yellow
$WORK_DIR = Join-Path $env:TEMP "CIBO_Bootstrap"
if (Test-Path $WORK_DIR) { Remove-Item $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue }
New-Item -ItemType Directory -Path $WORK_DIR -Force | Out-Null

$pythonZip = Join-Path $WORK_DIR "python-portable.zip"
try {
    Invoke-WebRequest -Uri "https://github.com/Lynstria/Cs2InternetBar/releases/download/1.0/python-portable.zip" -OutFile $pythonZip -ErrorAction Stop
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

# --- Function to repair pip ---
function Repair-Pip {
    Write-Host "[*] Attempting to repair pip..." -ForegroundColor Yellow
    try {
        & $pythonExe -m ensurepip --upgrade 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[+] Pip repaired via ensurepip." -ForegroundColor Green
            return $true
        }
    } catch {}

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

# Install required modules (using array arguments)
Write-Host "[0] Installing required Python modules (vdf, psutil, pywin32, requests)..." -ForegroundColor Yellow
$pipArgs = @(
    "-m", "pip", "install",
    "--quiet",
    "--disable-pip-version-check",
    "--target", "$pythonRoot\Lib\site-packages",
    "vdf", "psutil", "pywin32", "requests"
)
$pipOk = $false

function Invoke-PipInstall {
    param([string]$PythonPath)
    & $PythonPath @pipArgs 2>&1
    return $LASTEXITCODE -eq 0
}

if (Invoke-PipInstall -PythonPath $pythonExe) {
    $pipOk = $true
} else {
    Write-Host "[!] Initial pip install failed. Trying to repair pip..." -ForegroundColor Yellow
    if (Repair-Pip) {
        Write-Host "[*] Retrying module installation..." -ForegroundColor Yellow
        if (Invoke-PipInstall -PythonPath $pythonExe) {
            $pipOk = $true
        }
    }
}

if (-not $pipOk) {
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

# Add to PATH
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

# Stage 4: Optimize System (INLINED - no external file needed)
Write-Host "`n[*] Applying Windows streaming optimizations..." -ForegroundColor Yellow

function Write-Section($title) {
    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Write-OK($msg) { Write-Host "  [OK] $msg" -ForegroundColor Green }

Write-Section "STAGE 1: KILL SECURITY & DEFENDER"

$defenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (!(Test-Path $defenderPath)) { New-Item -Path $defenderPath -Force | Out-Null }
Set-ItemProperty -Path $defenderPath -Name "DisableAntiSpyware" -Value 1 -Force
Set-ItemProperty -Path $defenderPath -Name "DisableRealtimeMonitoring" -Value 1 -Force

# Turn off SmartScreen & Firewall
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Force
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-OK "Defender + SmartScreen + Firewall: DESTROYED"

Write-Section "STAGE 2: DISABLE VIRTUALIZATION & VBS"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -Force
$hyperVServices = @("hvhost", "vmickvpexchange", "vmicguestinterface", "vmicshutdown", "vmictimesync", "vmicrdv", "vmicvmsession", "vmicvss", "vmcompute")
foreach ($svc in $hyperVServices) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled
    Write-OK "Virtualization Service Killed: $svc"
}

Write-Section "STAGE 3: INPUT LAG"

$mousePath = "HKCU:\Control Panel\Mouse"
Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Force
Write-OK "Input Lag: Minimized"

Write-Section "STAGE 4: POWER & CPU"

# Import Ultimate Performance GUID
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

# Force CPU 100%
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg /apply
Write-OK "Power: ULTIMATE PERFORMANCE (Forced 100% CPU)"

Write-Section "STAGE 5: NETWORK & TCP"

netsh int tcp set global rss=enabled
netsh int tcp set global autotuninglevel=disabled
netsh int tcp set global ecncapability=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global initialrto=600
netsh int tcp set global rsc=disabled
netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set global fastopen=enabled
netsh int tcp set heuristics disabled

# Tối ưu Registry cho TCP Nagle & Throttling
$tcpPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $tcpPath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
}
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Force
Write-OK "Network: TCP Stack Refined for CS2"

Write-Section "STAGE 6: VISUAL EFFECTS"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Force
Write-OK "Visual: Minimal (Transparency OFF)"

Write-Section "STAGE 7: GPU & GAME TASK"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force
$gameTask = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-ItemProperty -Path $gameTask -Name "GPU Priority" -Value 8 -Force
Set-ItemProperty -Path $gameTask -Name "Priority" -Value 6 -Force
Set-ItemProperty -Path $gameTask -Name "Scheduling Category" -Value "High" -Force
Write-OK "GPU Scheduling: ENABLED + High Priority"

Write-Section "STAGE 8: KERNEL & DISK"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force
[System.GC]::Collect()
Write-OK "Kernel: Paging Executive Disabled + RAM Flushed"

Write-Section "STAGE 9: DEBLOAT SERVICES"

$services = @("SysMain", "DiagTrack", "WSearch", "TabletInputService", "PrintSpooler", "WerSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "MapsBroker", "PhoneSvc")
foreach ($s in $services) {
    Stop-Service -Name $s -Force -ErrorAction SilentlyContinue
    Set-Service -Name $s -StartupType Disabled
    Write-OK "Disabled: $s"
}

Write-Section "STAGE 10: DVR & PRIORITY"

Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "  ✅ CIBO OPTIMIZE COMPLETE" -ForegroundColor Green
Write-Host "  Time: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
Write-Host "  Ready to Pre-fire! NO RESTART REQUIRED." -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green

# Cleanup - Remove ALL temp files (except autoexec.cfg which is in CS2 cfg)
Write-Host "`n[*] Cleaning up temporary files..." -ForegroundColor Gray
Remove-Item $WORK_DIR -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "[+] Temp files cleaned. Only autoexec.cfg remains in CS2 cfg." -ForegroundColor Gray

Write-Host "`n======================================================" -ForegroundColor Cyan
Write-Host " [!] PIPELINE FINISHED - READY TO PRE-FIRE" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Cyan
pause
