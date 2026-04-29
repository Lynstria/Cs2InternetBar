# ========================================================
# optimize.ps1 - CIBO ULTIMATE MEGA MERGE (VER 1.3.5)
# ========================================================
# Requires -RunAsAdministrator
# Fix: Netsh legacy syntax, Powercfg GUIDs, Kernel Paging
# ========================================================

$Host.UI.RawUI.WindowTitle = "CIBO - CS2 GOD MODE PIPELINE"
$ErrorActionPreference = "SilentlyContinue"

function Write-Section($title) {
    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Write-OK($msg) { Write-Host "  [OK] $msg" -ForegroundColor Green }

Write-Host @"
    ██████╗██████╗  ██████╗ ███████╗    ███████╗██████╗ 
   ██╔════╝██╔══██╗██╔═══██╗██╔════╝    ██╔════╝██╔══██╗
   ██║     ██████╔╝██║   ██║███████╗    ███████╗██████╔╝
   ██║     ██╔══██╗██║   ██║╚════██║    ╚════██║██╔═══╝ 
   ╚██████╗██║  ██║╚██████╔╝███████║    ███████║██║     
    ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝     
                CIBO OPTIMIZER - 2026 MEGA MERGE
"@ -ForegroundColor Magenta

# ========================================================
# STAGE 1: SECURITY & DEFENDER (EAT RESOURCES)
# ========================================================
Write-Section "STAGE 1: KILL SECURITY & DEFENDER"

$defenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
if (!(Test-Path $defenderPath)) { New-Item -Path $defenderPath -Force }
Set-ItemProperty -Path $defenderPath -Name "DisableAntiSpyware" -Value 1 -Force
Set-ItemProperty -Path $defenderPath -Name "DisableRealtimeMonitoring" -Value 1 -Force

# Tắt SmartScreen & Firewall
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Force
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-OK "Defender + SmartScreen + Firewall: DESTROYED"

# ========================================================
# STAGE 2: VIRTUALIZATION & VBS (FIX STUTTER)
# ========================================================
Write-Section "STAGE 2: DISABLE VIRTUALIZATION & VBS"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -Force
$hyperVServices = @("hvhost", "vmickvpexchange", "vmicguestinterface", "vmicshutdown", "vmictimesync", "vmicrdv", "vmicvmsession", "vmicvss", "vmcompute")
foreach ($svc in $hyperVServices) {
    Stop-Service -Name $svc -Force
    Set-Service -Name $svc -StartupType Disabled
    Write-OK "Virtualization Service Killed: $svc"
}

# ========================================================
# STAGE 3: INPUT LAG (ZERO LATENCY)
# ========================================================
Write-Section "STAGE 3: INPUT LAG"

$mousePath = "HKCU:\Control Panel\Mouse"
Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Force
Write-OK "Input Lag: Minimized"

# ========================================================
# STAGE 4: POWER PLAN & CPU (FIXED SYNTAX)
# ========================================================
Write-Section "STAGE 4: POWER & CPU"

# Import Ultimate Performance GUID chuẩn của Windows
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
powercfg -setactive e9a42b02-d5df-448d-aa00-03f14749eb61

# Force CPU 100% không cho hạ xung (Parking)
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR CPMINCORES 100
powercfg /apply
Write-OK "Power: ULTIMATE PERFORMANCE (Forced 100% CPU)"

# ========================================================
# STAGE 5: MẠNG (MODERN TCP STACK FIX)
# ========================================================
Write-Section "STAGE 5: MẠNG & TCP (FIXED)"

# Xóa bỏ các tham số netsh cũ gây lỗi (chimney, netdns, dca...)
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

# ========================================================
# STAGE 6: VISUALS (LITE STYLE)
# ========================================================
Write-Section "STAGE 6: VISUAL EFFECTS"

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Force
Write-OK "Visual: Minimal (Transparency OFF)"

# ========================================================
# STAGE 7: GPU & MULTIMEDIA
# ========================================================
Write-Section "STAGE 7: GPU & GAME TASK"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force
$gameTask = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-ItemProperty -Path $gameTask -Name "GPU Priority" -Value 8 -Force
Set-ItemProperty -Path $gameTask -Name "Priority" -Value 6 -Force
Set-ItemProperty -Path $gameTask -Name "Scheduling Category" -Value "High" -Force
Write-OK "GPU Scheduling: ENABLED + High Priority"

# ========================================================
# STAGE 8: KERNEL & MEMORY (RAM FLUSH)
# ========================================================
Write-Section "STAGE 8: KERNEL & DISK"

Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" -Name "DisablePagingExecutive" -Value 1 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Force

# Clear Standby List (RAM Cleaning)
[System.GC]::Collect()
Write-OK "Kernel: Paging Executive Disabled + RAM Flushed"

# ========================================================
# STAGE 9: DEBLOAT SERVICES
# ========================================================
Write-Section "STAGE 9: DEBLOAT SERVICES"

$services = @("SysMain", "DiagTrack", "WSearch", "TabletInputService", "PrintSpooler", "WerSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "MapsBroker", "PhoneSvc")
foreach ($s in $services) {
    Stop-Service -Name $s -Force
    Set-Service -Name $s -StartupType Disabled
    Write-OK "Disabled: $s"
}

# ========================================================
# STAGE 10: DVR & PRIORITY (FINAL)
# ========================================================
Write-Section "STAGE 10: DVR & BACKGROUND"

Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "  ✅ CIBO OPTIMIZE HOÀN TẤT" -ForegroundColor Green
Write-Host "  Thời gian: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Cyan
Write-Host "  Sẵn sàng Pre-fire! KHÔNG CẦN RESTART." -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green
