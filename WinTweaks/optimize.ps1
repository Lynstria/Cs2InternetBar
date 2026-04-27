# ========================================================
# optimize.ps1 - WINDOWS ULTRA LITE & CS2 GOD MODE (MEGA MERGE)
# ========================================================
# Tổng hợp 100% từ: Script gốc + CS2 INSTANT + CS2 ULTIMATE + KERNEL TWEAKS
# KHÔNG LỌC - TẬP HỢP TẤT CẢ LỆNH - KHÔNG BỚT LỆNH NÀO
# Tắt toàn bộ Security, Visual, Máy ảo, Driver Delay
# Quy tắc: KHÔNG Restart, KHÔNG Endtask, KHÔNG Reset Explorer
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
               OPTIMIZE.PS1 - FULL MEGA MERGE
"@ -ForegroundColor Magenta

Start-Sleep -Milliseconds 500

# ========================================================
# STAGE 1: TRIỆT TIÊU SECURITY & DEFENDER (EAT RESOURCES)
# ========================================================
Write-Section "STAGE 1: KILL SECURITY & DEFENDER"

# Disable Windows Defender hoàn toàn via Registry
$defenderPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"
Ensure-RegistryPath $defenderPath
Set-ItemProperty -Path $defenderPath -Name "DisableAntiSpyware" -Value 1 -Force
Set-ItemProperty -Path "$defenderPath\Real-Time Protection" -Name "DisableRealtimeMonitoring" -Value 1 -Force
Set-ItemProperty -Path "$defenderPath\Real-Time Protection" -Name "DisableBehaviorMonitoring" -Value 1 -Force
Set-ItemProperty -Path "$defenderPath\Real-Time Protection" -Name "DisableOnAccessProtection" -Value 1 -Force
Set-ItemProperty -Path "$defenderPath\Real-Time Protection" -Name "DisableScanOnRealtimeEnable" -Value 1 -Force
Set-ItemProperty -Path "$defenderPath\Spynet" -Name "SpyNetReporting" -Value 0 -Force
Set-ItemProperty -Path "$defenderPath\Spynet" -Name "SubmitSamplesConsent" -Value 2 -Force

# Tắt SmartScreen & Security Center
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\wscsvc" -Name "Start" -Value 4 -Force

# Tắt Windows Firewall (Cho phép network bypass hoàn toàn)
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False
Write-OK "Defender + SmartScreen + Firewall: DESTROYED"

# ========================================================
# STAGE 2: VÔ HIỆU HÓA MÁY ẢO & VBS (GIẢM STUTTER)
# ========================================================
Write-Section "STAGE 2: DISABLE VIRTUALIZATION & VBS"

$vbsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard"
Ensure-RegistryPath $vbsPath
Set-ItemProperty -Path $vbsPath -Name "EnableVirtualizationBasedSecurity" -Value 0 -Force
Set-ItemProperty -Path "$vbsPath\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -Force

# Tắt toàn bộ Hyper-V và Virtualization services
$hyperVServices = @("hvhost", "vmickvpexchange", "vmicguestinterface", "vmicshutdown", "vmictimesync", "vmicrdv", "vmicvmsession", "vmicvss", "vmicguestinterface", "vmcompute")
foreach ($svc in $hyperVServices) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    Write-OK "Virtualization Service Killed: $svc"
}
Write-OK "VBS & Hyper-V: COMPLETELY DISABLED"

# ========================================================
# STAGE 3: CHUỘT & BÀN PHÍM (ZERO INPUT LAG)
# ========================================================
Write-Section "STAGE 3: CHUỘT & BÀN PHÍM"

$mousePath = "HKCU:\Control Panel\Mouse"
Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseTrails" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "DoubleClickSpeed" -Value "200" -Force
Set-ItemProperty -Path $mousePath -Name "SmoothMouseXCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force
Set-ItemProperty -Path $mousePath -Name "SmoothMouseYCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force

$kbPath = "HKCU:\Control Panel\Keyboard"
Set-ItemProperty -Path $kbPath -Name "KeyboardDelay" -Value "0" -Force
Set-ItemProperty -Path $kbPath -Name "KeyboardSpeed" -Value "31" -Force

$accessPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"
Ensure-RegistryPath $accessPath
Set-ItemProperty -Path $accessPath -Name "AutoRepeatDelay" -Value "200" -Force
Set-ItemProperty -Path $accessPath -Name "AutoRepeatRate" -Value "15" -Force
Set-ItemProperty -Path $accessPath -Name "Flags" -Value "0" -Force
Set-ItemProperty -Path $accessPath -Name "BounceTime" -Value "0" -Force
Set-ItemProperty -Path $accessPath -Name "DelayBeforeAcceptance" -Value "0" -Force

# Tắt Sticky / Toggle / Filter Keys
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -Force
Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "58" -Force
Write-OK "Input Lag: Minimized (Mouse Fix Applied)"

# ========================================================
# STAGE 4: POWER PLAN & CPU (MAX PERFORMANCE)
# ========================================================
Write-Section "STAGE 4: POWER & CPU"

$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $ultimateGuid 2>$null
powercfg -setactive $ultimateGuid 2>$null

# Tắt Idle States, USB Suspend, PCI-E Power
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR 5d76a2ca-e8c0-402f-a133-2158492d58ad 1
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /apply
Write-OK "Power: ULTIMATE PERFORMANCE + CPU 100%"

# ========================================================
# STAGE 5: MẠNG (LOW LATENCY STACK)
# ========================================================
Write-Section "STAGE 5: MẠNG & TCP"

# Netsh Full Set
$netshSet = @(
    "interface tcp set global autotuninglevel=disabled",
    "interface tcp set global chimney=disabled",
    "interface tcp set global dca=enabled",
    "interface tcp set global netdns=enabled",
    "interface tcp set global ecncapability=disabled",
    "interface tcp set global timestamps=disabled",
    "interface tcp set global rss=enabled",
    "interface tcp set heuristics disabled",
    "interface tcp set global netdma=enabled"
)
foreach ($cmd in $netshSet) { iex "netsh $cmd" }

# Registry TCP Nagle + DelAck
$tcpInterfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
foreach ($iface in $tcpInterfaces) {
    Set-ItemProperty -Path $iface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $iface.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $iface.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
}

# Network Throttling + QoS DSCP 46
$mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Force
Set-ItemProperty -Path $mmPath -Name "SystemResponsiveness" -Value 0 -Force

$qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\cs2.exe"
Ensure-RegistryPath $qosPath
Set-ItemProperty -Path $qosPath -Name "Version" -Value "1.0" -Force
Set-ItemProperty -Path $qosPath -Name "Application Name" -Value "cs2.exe" -Force
Set-ItemProperty -Path $qosPath -Name "Protocol" -Value "*" -Force
Set-ItemProperty -Path $qosPath -Name "DSCP Value" -Value "46" -Force

ipconfig /flushdns | Out-Null
Write-OK "Network: TCP Stack Optimized + QoS for CS2"

# ========================================================
# STAGE 6: TRIỆT TIÊU VISUAL EFFECTS (WINDOWS LITE STYLE)
# ========================================================
Write-Section "STAGE 6: VISUAL EFFECTS"

$visualPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $visualPath -Name "DragFullWindows" -Value "0" -Force
Set-ItemProperty -Path $visualPath -Name "MenuShowDelay" -Value "0" -Force
Set-ItemProperty -Path $visualPath -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force

$fxPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
Ensure-RegistryPath $fxPath
Set-ItemProperty -Path $fxPath -Name "VisualFXSetting" -Value 2 -Force

# Tắt Transparency
$themesPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $themesPath -Name "EnableTransparency" -Value 0 -Force
Write-OK "Visual: Minimal (Lite Mode)"

# ========================================================
# STAGE 7: GPU & MULTIMEDIA (AFFINITY & PRIORITY)
# ========================================================
Write-Section "STAGE 7: GPU & GAME TASK"

# Hardware Accelerated GPU Scheduling (HAGS) ON
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Force

# Multimedia Class Scheduler
$gameTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Ensure-RegistryPath $gameTaskPath
Set-ItemProperty -Path $gameTaskPath -Name "Affinity" -Value 0 -Force
Set-ItemProperty -Path $gameTaskPath -Name "Background Only" -Value "False" -Force
Set-ItemProperty -Path $gameTaskPath -Name "GPU Priority" -Value 8 -Force
Set-ItemProperty -Path $gameTaskPath -Name "Priority" -Value 6 -Force
Set-ItemProperty -Path $gameTaskPath -Name "Scheduling Category" -Value "High" -Force
Set-ItemProperty -Path $gameTaskPath -Name "SFIO Priority" -Value "High" -Force
Write-OK "GPU Scheduling + Game Task: HIGH"

# ========================================================
# STAGE 8: KERNEL & MEMORY (LITE OPTIMIZATION)
# ========================================================
Write-Section "STAGE 8: KERNEL & DISK"

$memPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Set-ItemProperty -Path $memPath -Name "DisablePagingExecutive" -Value 1 -Force
Set-ItemProperty -Path $memPath -Name "LargeSystemCache" -Value 0 -Force

$pfPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
Set-ItemProperty -Path $pfPath -Name "EnablePrefetcher" -Value 0 -Force
Set-ItemProperty -Path $pfPath -Name "EnableSuperfetch" -Value 0 -Force

# Disk I/O tweaks
fsutil behavior set disableLastAccess 1 | Out-Null
fsutil behavior set disable8dot3 1 | Out-Null
$ntfsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
Set-ItemProperty -Path $ntfsPath -Name "NtfsMemoryUsage" -Value 2 -Force
Set-ItemProperty -Path $ntfsPath -Name "NtfsDisable8dot3NameCreation" -Value 1 -Force

# Clear Standby List
try {
    $signature = '[DllImport("ntdll.dll")] public static extern uint NtSetSystemInformation(int InfoClass, IntPtr Info, int Length);'
    $ntdll = Add-Type -MemberDefinition $signature -Name "NtDll" -Namespace "Win32" -PassThru
    [IntPtr]$ptr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(4)
    [System.Runtime.InteropServices.Marshal]::WriteInt32($ptr, 4)
    $ntdll::NtSetSystemInformation(80, $ptr, 4) | Out-Null
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
    Write-OK "Standby Memory: FLUSHED"
} catch { }
Write-OK "Kernel: LargeSystemCache + No Paging Executive"

# ========================================================
# STAGE 9: TRIỆT TIÊU SERVICES & DRIVERS (LITE MOD)
# ========================================================
Write-Section "STAGE 9: DEBLOAT SERVICES"

$allServices = @(
    "SysMain", "DiagTrack", "StateRepository", "WSearch", "TabletInputService", "PrintSpooler", 
    "WerSvc", "XblAuthManager", "XblGameSave", "XboxNetApiSvc", "XboxGipSvc", "MapsBroker", 
    "lfsvc", "wisvc", "icssvc", "SharedAccess", "RemoteRegistry", "WMPNetworkSvc", "TrkWks", 
    "PhoneSvc", "RetailDemo", "dmwappushservice", "CDPSvc", "OneSyncSvc", "WpnService", 
    "StorSvc", "SSDPSRV", "upnphost", "FDResPub", "fdPHost", "WbioSrvc", "SDRSVC", "Fax", "WalletService"
)

foreach ($svc in $allServices) {
    Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
    Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
    Write-OK "Service Disabled: $svc"
}

# Tắt các Driver gây trễ IRQ
$drivers = @("Print*", "WSDPrint*", "Sensor*", "HID Sensor*", "Bluetooth*")
Get-PnpDevice | Where-Object { $_.Status -eq "OK" } | ForEach-Object {
    foreach ($p in $drivers) {
        if ($_.FriendlyName -like $p) {
            Disable-PnpDevice -InstanceId $_.InstanceId -Confirm:$false -ErrorAction SilentlyContinue
            Write-OK "Driver Disabled: $($_.FriendlyName)"
        }
    }
}

# ========================================================
# STAGE 10: GAME BAR / DVR / BACKGROUND APPS
# ========================================================
Write-Section "STAGE 10: DVR & BACKGROUND"

Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Force

# Background Apps Global Disable
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications" -Name "ToastEnabled" -Value 0 -Force

# Startup & Priority Control
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0 -Force
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl" -Name "Win32PrioritySeparation" -Value 38 -Force

# CS2 Priority (If running)
$cs2 = Get-Process "cs2" -ErrorAction SilentlyContinue
if ($cs2) { $cs2.PriorityClass = "High"; Write-OK "CS2 Priority: HIGH" }

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "  ✅  optimize.ps1 HOÀN TẤT - TỔNG HỢP TOÀN BỘ LỆNH THÀNH CÔNG" -ForegroundColor Green
Write-Host "  Script finished at: $(Get-Date -Format 'HH:mm:ss dd/MM/yyyy')" -ForegroundColor Cyan
Write-Host "  Khởi động CS2 ngay - Không cần restart máy!" -ForegroundColor White
Write-Host "================================================================" -ForegroundColor Green
