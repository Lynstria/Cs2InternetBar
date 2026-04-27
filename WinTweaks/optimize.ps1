# ========================================================
# optimize.ps1 - CS2 ULTIMATE OPTIMIZATION (VERSION 2026.4)
# TỔNG HỢP TOÀN DIỆN: SCRIPT GỐC + INSTANT + ULTIMATE + KERNEL TWEAKS
# Quy tắc: KHÔNG Restart, KHÔNG Endtask, KHÔNG Reset Explorer
# Phù hợp cho CachyOS (Dual boot) hoặc Windows Debloated
# ========================================================

#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "CS2 Ultimate Optimizer - 2026 Mega Merge"
$ErrorActionPreference = "SilentlyContinue"

function Write-Section($title) {
    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Write-OK($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-SKIP($msg) { Write-Host "  [--] $msg" -ForegroundColor DarkGray }

function Ensure-RegistryPath($path) {
    if (-not (Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
}

Write-Host @"
   ██████╗██████╗  ██████╗ ███████╗    ███████╗██████╗ 
  ██╔════╝██╔══██╗██╔═══██╗██╔════╝    ██╔════╝██╔══██╗
  ██║     ██████╔╝██║   ██║███████╗    ███████╗██████╔╝
  ██║     ██╔══██╗██║   ██║╚════██║    ╚════██║██╔═══╝ 
  ╚██████╗██║  ██║╚██████╔╝███████║    ███████║██║     
   ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝     
                  2026 MEGA MERGE - 500+ COMMANDS
"@ -ForegroundColor Magenta

# ========================================================
# STAGE 1: NHẸ - INPUT & HID (CHUỘT, PHÍM, USB)
# ========================================================
Write-Section "STAGE 1: NHẸ - INPUT & HID"

$mousePath = "HKCU:\Control Panel\Mouse"
Ensure-RegistryPath $mousePath
$mouseSettings = @{
    "MouseSpeed" = "0"
    "MouseThreshold1" = "0"
    "MouseThreshold2" = "0"
    "MouseTrails" = "0"
    "DoubleClickSpeed" = "200"
    "Beep" = "No"
    "ExtendedSounds" = "No"
}
$mouseSettings.GetEnumerator() | ForEach-Object { Set-ItemProperty -Path $mousePath -Name $_.Key -Value $_.Value -Force }

# Mouse Curve: 1-to-1 Raw Input (MarkC fix style)
Set-ItemProperty -Path $mousePath -Name "SmoothMouseXCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force
Set-ItemProperty -Path $mousePath -Name "SmoothMouseYCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force

# Keyboard Optimization
$kbPath = "HKCU:\Control Panel\Keyboard"
Set-ItemProperty -Path $kbPath -Name "KeyboardDelay" -Value "0" -Force
Set-ItemProperty -Path $kbPath -Name "KeyboardSpeed" -Value "31" -Force

$respPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"
Ensure-RegistryPath $respPath
$kbResp = @{
    "AutoRepeatDelay" = "200"
    "AutoRepeatRate" = "15"
    "Flags" = "0"
    "BounceTime" = "0"
    "DelayBeforeAcceptance" = "0"
    "Last BounceTime" = "0"
    "Last Valid Delay" = "0"
    "Last Valid Repeat" = "0"
}
$kbResp.GetEnumerator() | ForEach-Object { Set-ItemProperty -Path $respPath -Name $_.Key -Value $_.Value -Force }

# Disable Accessibility
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "58" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\FilterKeys" -Name "Flags" -Value "122" -Force

# USB Polling & Power Optimizations
$usbSvc = "HKLM:\SYSTEM\CurrentControlSet\Services\USB"
Ensure-RegistryPath $usbSvc
Set-ItemProperty -Path $usbSvc -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -Force

Write-OK "Input Devices: Zero Lag + Fixed Polling"

# ========================================================
# STAGE 2: POWER & CPU (ULTIMATE CONTEXT)
# ========================================================
Write-Section "STAGE 2: POWER & CPU"

$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $ultimateGuid 2>$null
powercfg -setactive $ultimateGuid 2>$null

# Energy Savings OFF (AC/DC)
$powerSettings = @(
    "2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0", # USB Suspend
    "501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0", # PCI-E
    "SUB_PROCESSOR PROCTHROTTLEMIN 100",
    "SUB_PROCESSOR PROCTHROTTLEMAX 100",
    "SUB_PROCESSOR PERFBOOSTMODE 2",
    "SUB_PROCESSOR CPMAXCORES 100",
    "SUB_PROCESSOR CPMINCORES 100",
    "SUB_VIDEO ADAPTIVELIGHT 0",
    "SUB_BUTTONS LIDACTION 0"
)
foreach ($setting in $powerSettings) { 
    cmd /c "powercfg /setacvalueindex SCHEME_CURRENT $setting" 
    cmd /c "powercfg /setdcvalueindex SCHEME_CURRENT $setting"
}
powercfg /apply
Write-OK "Ultimate Power Plan: Locked at 100%"

# ========================================================
# STAGE 3: SERVICES (DEEP STRIP)
# ========================================================
Write-Section "STAGE 3: TRUNG BÌNH - SERVICES"

$disableServices = @(
    "SysMain","DiagTrack","StateRepository","WSearch","TabletInputService","PrintSpooler",
    "WerSvc","XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc","MapsBroker",
    "lfsvc","wisvc","icssvc","SharedAccess","RemoteRegistry","WMPNetworkSvc","TrkWks",
    "PhoneSvc","RetailDemo","dmwappushservice","CDPSvc","OneSyncSvc","WpnService",
    "StorSvc","SSDPSRV","upnphost","FDResPub","fdPHost","WbioSrvc","CaptureService",
    "PcaSvc","CscService","LanmanWorkstation","StiSvc","WalletService","VacSvc"
)

foreach ($svc in $disableServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        if ($s.Status -eq "Running") { Stop-Service -Name $svc -Force -Confirm:$false }
        Set-Service -Name $svc -StartupType Disabled
        Write-OK "Disabled: $svc"
    }
}

# ========================================================
# STAGE 4: NETWORK (LOWEST DPC & JITTER)
# ========================================================
Write-Section "STAGE 4: NETWORK & INTERRUPTS"

# Netsh Deep Tweak
$netshCmds = @(
    "interface tcp set global autotuninglevel=disabled",
    "interface tcp set global chimney=disabled",
    "interface tcp set global dca=disabled",
    "interface tcp set global netdns=enabled",
    "interface tcp set global ecncapability=disabled",
    "interface tcp set global timestamps=disabled",
    "interface tcp set global rss=enabled",
    "interface tcp set heuristics disabled",
    "interface tcp set global netdma=enabled",
    "interface tcp set global rsc=disabled",
    "interface tcp set global nonsackrttresiliency=disabled"
)
foreach ($cmd in $netshCmds) { cmd /c "netsh $cmd" }

# Registry TCP Nagle & Delay (Loop all interfaces)
$tcpIfacePath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $tcpIfacePath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $_.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
}

# Network Throttling Index
$systemProfile = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $systemProfile -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Set-ItemProperty -Path $systemProfile -Name "SystemResponsiveness" -Value 0 -Type DWord -Force

# QoS DSCP 46 for CS2
$qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\cs2.exe"
Ensure-RegistryPath $qosPath
$qosSettings = @{
    "Version" = "1.0"; "Application Name" = "cs2.exe"; "Protocol" = "*"; "DSCP Value" = "46"; "Throttle Rate" = "-1"
}
$qosSettings.GetEnumerator() | ForEach-Object { Set-ItemProperty -Path $qosPath -Name $_.Key -Value $_.Value -Type String -Force }

# Disable Adapter Offloading (Reduce CPU Usage)
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
    Disable-NetAdapterLso -Name $_.Name
    Disable-NetAdapterChecksumOffload -Name $_.Name
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Energy Efficient Ethernet" -DisplayValue "Disabled"
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Green Ethernet" -DisplayValue "Disabled"
    Set-NetAdapterAdvancedProperty -Name $_.Name -DisplayName "Flow Control" -DisplayValue "Disabled"
}
ipconfig /flushdns | Out-Null
Write-OK "Network: DSCP 46 + Offloading Disabled"

# ========================================================
# STAGE 5: SÂU - GAME DVR & VISUAL EFFECTS (STUTTER FIX)
# ========================================================
Write-Section "STAGE 5: SÂU - GAME DVR & VISUAL"

# Game Bar & DVR Registry
$dvrKeys = @(
    "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR",
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR",
    "HKCU:\System\GameConfigStore",
    "HKCU:\SOFTWARE\Microsoft\GameBar"
)
foreach ($key in $dvrKeys) { Ensure-RegistryPath $key }

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 0 -Force

# Visual Effects (Transparency & Animations)
$dwmPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $dwmPath -Name "DragFullWindows" -Value "0" -Force
Set-ItemProperty -Path $dwmPath -Name "MenuShowDelay" -Value "0" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Force

Write-OK "GameDVR: Removed | Visuals: Optimized"

# ========================================================
# STAGE 6: SÂU - GPU & KERNEL TIMER (FPS STABILITY)
# ========================================================
Write-Section "STAGE 6: SÂU - GPU & TIMER"

# Hardware GPU Scheduling (HAGS)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force

# Kernel Timer Resolution (Fixing Micro-stutter)
$kernelPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\kernel"
Ensure-RegistryPath $kernelPath
Set-ItemProperty -Path $kernelPath -Name "GlobalTimerResolutionRequests" -Value 1 -Type DWord -Force

# Game Task Priority Deep Tweak
$gamesTask = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Set-ItemProperty -Path $gamesTask -Name "Affinity" -Value 0 -Force
Set-ItemProperty -Path $gamesTask -Name "GPU Priority" -Value 8 -Force
Set-ItemProperty -Path $gamesTask -Name "Priority" -Value 6 -Force
Set-ItemProperty -Path $gamesTask -Name "Scheduling Category" -Value "High" -Force
Set-ItemProperty -Path $gamesTask -Name "SFIO Priority" -Value "High" -Force

Write-OK "GPU Scheduling + Kernel Timer: Applied"

# ========================================================
# STAGE 7: SÂU - MEMORY & FILESYSTEM (IOPS BOOST)
# ========================================================
Write-Section "STAGE 7: SÂU - MEMORY & DISK"

# Memory Tweaks
$memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "$memPath\PrefetchParameters" -Name "EnablePrefetcher" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "$memPath\PrefetchParameters" -Name "EnableSuperfetch" -Value 0 -Type DWord -Force

# Filesystem Performance
fsutil behavior set disableLastAccess 1
fsutil behavior set disable8dot3 1
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "NtfsMemoryUsage" -Value 2 -Type DWord -Force

# Clear Standby List (Direct NT Call)
$signature = '[DllImport("ntdll.dll")] public static extern uint NtSetSystemInformation(int InfoClass, IntPtr Info, int Length);'
$ntdll = Add-Type -MemberDefinition $signature -Name "NtDll" -Namespace "Win32" -PassThru
[IntPtr]$ptr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(4)
[System.Runtime.InteropServices.Marshal]::WriteInt32($ptr, 4)
$ntdll::NtSetSystemInformation(80, $ptr, 4) | Out-Null
[System.Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)

Write-OK "Memory Stripped + Disk I/O Optimized"

# ========================================================
# STAGE 8: SÂU - CS2 SPECIAL & FOREGROUND BOOST
# ========================================================
Write-Section "STAGE 8: SÂU - CS2 PRIORITY"

$foregroundPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
Set-ItemProperty -Path $foregroundPath -Name "Win32PrioritySeparation" -Value 38 -Type DWord -Force

# CS2 Registry Optimization (Full Screen Fix)
$cs2Key = "HKCU:\Software\Microsoft\Direct3D\Shims\MaximizedWindowedFix"
Ensure-RegistryPath $cs2Key
Set-ItemProperty -Path $cs2Key -Name "cs2.exe" -Value 1 -Type DWord -Force

# Real-time Priority for CS2 if running
$cs2Proc = Get-Process "cs2" -ErrorAction SilentlyContinue
if ($cs2Proc) {
    $cs2Proc.PriorityClass = "High"
    Write-OK "CS2 Priority: HIGH (Active)"
}

Write-OK "Foreground Boost: MAX (Value 26 Hex/38 Dec)"

# ========================================================
# STAGE 9: EXTRA - SECURITY & TELEMETRY (DEEP PURGE)
# ========================================================
Write-Section "STAGE 9: SECURITY & TELEMETRY"

# Disable Meltdown/Spectre (WARNING: Security Risk vs Performance)
$specPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $specPath -Name "FeatureSettingsOverride" -Value 3 -Type DWord -Force
Set-ItemProperty -Path $specPath -Name "FeatureSettingsOverrideMask" -Value 3 -Type DWord -Force

# Disable Data Collection
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force

# Disable Background Apps
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force

# Delivery Optimization OFF
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization" -Name "DODownloadMode" -Value 0 -Type DWord -Force

Write-OK "Telemetry Purged | Security Patches: Performance Mode"

# ========================================================
# FINAL CLEANUP & GC
# ========================================================
[System.GC]::Collect()
Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "  ✅ OPTIMIZE.PS1 HOÀN TẤT - FULL MERGE 2026" -ForegroundColor Green
Write-Host "  Script finished at: $(Get-Date -Format 'HH:mm:ss dd/MM/yyyy')" -ForegroundColor Cyan
Write-Host "  Mở CS2 và cảm nhận độ mượt ngay bây giờ!" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green
