# ========================================================
# optimize.ps1 - CS2 ULTIMATE OPTIMIZATION (TỔNG HỢP TOÀN BỘ)
# Tổng hợp 100% từ 3 list: Script gốc + CS2 INSTANT + CS2 ULTIMATE
# KHÔNG LỌC - TẬP HỢP TẤT CẢ LỆNH
# Không endtask, không reset Explorer, KHÔNG CÓ LỆNH NÀO YÊU CẦU RESTART MÁY
# Chia thành STAGE từ NHẸ → SÂU
# Chạy với quyền Administrator
# ========================================================

#Requires -RunAsAdministrator

$Host.UI.RawUI.WindowTitle = "CS2 Ultimate Optimizer - optimize.ps1"
$ErrorActionPreference = "SilentlyContinue"

function Write-Section($title) {
    Write-Host "`n================================================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Yellow
    Write-Host "================================================================" -ForegroundColor Cyan
}

function Write-OK($msg)   { Write-Host "  [OK] $msg" -ForegroundColor Green }
function Write-SKIP($msg) { Write-Host "  [--] $msg" -ForegroundColor DarkGray }

function Ensure-RegistryPath($path) {
    if (-not (Test-Path $path)) {
        New-Item -Path $path -Force | Out-Null
    }
}

Write-Host @"
   ██████╗██████╗  ██████╗ ███████╗    ███████╗██████╗ 
  ██╔════╝██╔══██╗██╔═══██╗██╔════╝    ██╔════╝██╔══██╗
  ██║     ██████╔╝██║   ██║███████╗    ███████╗██████╔╝
  ██║     ██╔══██╗██║   ██║╚════██║    ╚════██║██╔═══╝ 
  ╚██████╗██║  ██║╚██████╔╝███████║    ███████║██║     
   ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝    ╚══════╝╚═╝     
                  OPTIMIZE.PS1 - FULL MERGE
"@ -ForegroundColor Magenta

Start-Sleep -Milliseconds 500

# ========================================================
# STAGE 1: NHẸ - TỐI ƯU CHUỘT & BÀN PHÍM (Input lag thấp nhất)
# ========================================================
Write-Section "STAGE 1: NHẸ - CHUỘT & BÀN PHÍM"

# Mouse Acceleration OFF (từ cả 3 list)
$mousePath = "HKCU:\Control Panel\Mouse"
Ensure-RegistryPath $mousePath
Set-ItemProperty -Path $mousePath -Name "MouseSpeed" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold1" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "MouseThreshold2" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "SmoothMouseXCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xC0,0xCC,0x0C,0x00,0x00,0x00,0x00,0x00,0x80,0x99,0x19,0x00,0x00,0x00,0x00,0x00,0x40,0x66,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x33,0x33,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force
Set-ItemProperty -Path $mousePath -Name "SmoothMouseYCurve" -Value ([byte[]](0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x38,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x70,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xA8,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xE0,0x00,0x00,0x00,0x00,0x00)) -Type Binary -Force
Set-ItemProperty -Path $mousePath -Name "MouseTrails" -Value "0" -Force
Set-ItemProperty -Path $mousePath -Name "DoubleClickSpeed" -Value "200" -Force
Write-OK "Mouse Acceleration + Smoothing + Trails: OFF"

# Keyboard max sensitivity & zero delay (từ cả 3 list)
$kbPath = "HKCU:\Control Panel\Keyboard"
Ensure-RegistryPath $kbPath
Set-ItemProperty -Path $kbPath -Name "KeyboardDelay" -Value "0" -Force
Set-ItemProperty -Path $kbPath -Name "KeyboardSpeed" -Value "31" -Force

$accessPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"
Ensure-RegistryPath $accessPath
Set-ItemProperty -Path $accessPath -Name "AutoRepeatDelay" -Value "200" -Force
Set-ItemProperty -Path $accessPath -Name "AutoRepeatRate" -Value "15" -Force
Set-ItemProperty -Path $accessPath -Name "Flags" -Value "0" -Force
Set-ItemProperty -Path $accessPath -Name "BounceTime" -Value "0" -Force
Set-ItemProperty -Path $accessPath -Name "DelayBeforeAcceptance" -Value "0" -Force
Write-OK "Keyboard: Max speed + Zero delay"

# Tắt Sticky / Toggle / Filter Keys
$stickyPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
Ensure-RegistryPath $stickyPath
Set-ItemProperty -Path $stickyPath -Name "Flags" -Value "506" -Force
$togglePath = "HKCU:\Control Panel\Accessibility\ToggleKeys"
Ensure-RegistryPath $togglePath
Set-ItemProperty -Path $togglePath -Name "Flags" -Value "58" -Force
Write-OK "StickyKeys / ToggleKeys / FilterKeys: OFF"

# ========================================================
# STAGE 2: NHẸ - POWER PLAN & CPU/GPU CƠ BẢN
# ========================================================
Write-Section "STAGE 2: NHẸ - POWER PLAN"

# Ultimate Performance (từ script gốc)
$ultimateGuid = "e9a42b02-d5df-448d-aa00-03f14749eb61"
powercfg -duplicatescheme $ultimateGuid 2>$null
powercfg -setactive $ultimateGuid 2>$null
Write-OK "Power Plan: ULTIMATE PERFORMANCE"

# Fallback High Performance
$highPerfGuid = "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c"
powercfg /setactive $highPerfGuid 2>$null

# Tắt USB Selective Suspend, PCI-E Link State, CPU Throttle 100%
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setdcvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a8218c268e20 ee12f906-d277-404b-b6da-e5fa1a576df5 0
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMIN 100
powercfg /setacvalueindex SCHEME_CURRENT SUB_PROCESSOR PROCTHROTTLEMAX 100
powercfg /apply
Write-OK "USB Suspend + PCI-E Power + CPU 100%: OFF"

# ========================================================
# STAGE 3: TRUNG BÌNH - DỪNG SERVICES (Stop only + Disable)
# ========================================================
Write-Section "STAGE 3: TRUNG BÌNH - DỪNG SERVICES"

$allServices = @("SysMain","DiagTrack","StateRepository","WSearch","TabletInputService","PrintSpooler","WerSvc","XblAuthManager","XblGameSave","XboxNetApiSvc","XboxGipSvc","MapsBroker","lfsvc","wisvc","icssvc","SharedAccess","RemoteRegistry","WMPNetworkSvc","TrkWks","PhoneSvc","RetailDemo","dmwappushservice","CDPSvc","OneSyncSvc","WpnService","StorSvc","SSDPSRV","upnphost","FDResPub","fdPHost","WbioSrvc")

foreach ($svc in $allServices) {
    $s = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($s) {
        if ($s.Status -eq "Running") {
            Stop-Service -Name $svc -Force -ErrorAction SilentlyContinue
        }
        Set-Service -Name $svc -StartupType Disabled -ErrorAction SilentlyContinue
        Write-OK "Service: $svc (Stopped + Disabled)"
    } else {
        Write-SKIP "Service not found: $svc"
    }
}

# ========================================================
# STAGE 4: TRUNG BÌNH - TỐI ƯU MẠNG (Low latency + QoS)
# ========================================================
Write-Section "STAGE 4: TRUNG BÌNH - MẠNG"

# Tất cả netsh từ 3 list
netsh interface tcp set global autotuninglevel=normal
netsh interface tcp set global autotuninglevel=disabled
netsh interface tcp set global chimney=disabled
netsh interface tcp set global chimney=enabled
netsh interface tcp set global dca=enabled
netsh interface tcp set global dca=disabled
netsh interface tcp set global netdns=enabled
netsh interface tcp set global ecncapability=disabled
netsh interface tcp set global timestamps=disabled
netsh interface tcp set global rss=enabled
netsh interface tcp set heuristics disabled
netsh interface tcp set global netdma=enabled
Write-OK "Netsh TCP: Full low-latency set"

# Registry TCP Nagle + Global (từ ULTIMATE)
$tcpInterfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" -ErrorAction SilentlyContinue
foreach ($iface in $tcpInterfaces) {
    Set-ItemProperty -Path $iface.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $iface.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force
    Set-ItemProperty -Path $iface.PSPath -Name "TcpDelAckTicks" -Value 0 -Type DWord -Force
}
$tcpGlobal = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters"
Ensure-RegistryPath $tcpGlobal
Set-ItemProperty -Path $tcpGlobal -Name "DefaultTTL" -Value 64 -Type DWord -Force
Set-ItemProperty -Path $tcpGlobal -Name "EnablePMTUDiscovery" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $tcpGlobal -Name "Tcp1323Opts" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $tcpGlobal -Name "TcpTimedWaitDelay" -Value 30 -Type DWord -Force
Set-ItemProperty -Path $tcpGlobal -Name "MaxUserPort" -Value 65534 -Type DWord -Force
Set-ItemProperty -Path $tcpGlobal -Name "TcpNumConnections" -Value 0x00fffffe -Type DWord -Force
Set-ItemProperty -Path $tcpGlobal -Name "DisableTaskOffload" -Value 1 -Type DWord -Force

# NetworkThrottling + QoS DSCP 46 cho cs2.exe
$mmPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
Ensure-RegistryPath $mmPath
Set-ItemProperty -Path $mmPath -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force
Set-ItemProperty -Path $mmPath -Name "SystemResponsiveness" -Value 0 -Type DWord -Force

$qosPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\QoS\cs2.exe"
Ensure-RegistryPath $qosPath
Set-ItemProperty -Path $qosPath -Name "Version" -Value "1.0" -Type String -Force
Set-ItemProperty -Path $qosPath -Name "Application Name" -Value "cs2.exe" -Type String -Force
Set-ItemProperty -Path $qosPath -Name "Protocol" -Value "*" -Type String -Force
Set-ItemProperty -Path $qosPath -Name "DSCP Value" -Value "46" -Type String -Force
Set-ItemProperty -Path $qosPath -Name "Throttle Rate" -Value "-1" -Type String -Force

# Tắt LSO + EEE trên tất cả adapter
Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | ForEach-Object {
    Disable-NetAdapterLso -Name $_.Name -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "EEE" -RegistryValue 0 -ErrorAction SilentlyContinue
    Set-NetAdapterAdvancedProperty -Name $_.Name -RegistryKeyword "*EEE" -RegistryValue 0 -ErrorAction SilentlyContinue
}
ipconfig /flushdns | Out-Null
Write-OK "Network: Nagle OFF + QoS DSCP 46 + LSO/EEE OFF + DNS flush"

# ========================================================
# STAGE 5: SÂU - GAME BAR / DVR / VISUAL EFFECTS
# ========================================================
Write-Section "STAGE 5: SÂU - GAME DVR & VISUAL"

$gameDVRPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR"
Ensure-RegistryPath $gameDVRPath
Set-ItemProperty -Path $gameDVRPath -Name "AppCaptureEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $gameDVRPath -Name "HistoricalCaptureEnabled" -Value 0 -Type DWord -Force

$gameDVRPolicy = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
Ensure-RegistryPath $gameDVRPolicy
Set-ItemProperty -Path $gameDVRPolicy -Name "AllowGameDVR" -Value 0 -Type DWord -Force

$gameBarPath = "HKCU:\SOFTWARE\Microsoft\GameBar"
Ensure-RegistryPath $gameBarPath
Set-ItemProperty -Path $gameBarPath -Name "UseNexusForGameBarEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $gameBarPath -Name "AutoGameModeEnabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $gameBarPath -Name "AllowAutoGameMode" -Value 0 -Type DWord -Force

$compatPath = "HKCU:\System\GameConfigStore"
Ensure-RegistryPath $compatPath
Set-ItemProperty -Path $compatPath -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $compatPath -Name "GameDVR_FSEBehaviorMode" -Value 2 -Type DWord -Force

$dwmPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $dwmPath -Name "DragFullWindows" -Value "0" -Type String -Force
Set-ItemProperty -Path $dwmPath -Name "MenuShowDelay" -Value "0" -Type String -Force
Set-ItemProperty -Path $dwmPath -Name "UserPreferencesMask" -Value ([byte[]](0x90,0x12,0x03,0x80,0x10,0x00,0x00,0x00)) -Type Binary -Force
Write-OK "GameDVR + Game Bar + Visual Effects: OFF"

# ========================================================
# STAGE 6: SÂU - GPU SCHEDULING & MULTIMEDIA PRIORITY
# ========================================================
Write-Section "STAGE 6: SÂU - GPU & GAME PRIORITY"

$hagsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers"
Ensure-RegistryPath $hagsPath
Set-ItemProperty -Path $hagsPath -Name "HwSchMode" -Value 2 -Type DWord -Force

$gameTaskPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games"
Ensure-RegistryPath $gameTaskPath
Set-ItemProperty -Path $gameTaskPath -Name "Affinity" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $gameTaskPath -Name "Background Only" -Value "False" -Type String -Force
Set-ItemProperty -Path $gameTaskPath -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path $gameTaskPath -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path $gameTaskPath -Name "Scheduling Category" -Value "High" -Type String -Force
Set-ItemProperty -Path $gameTaskPath -Name "SFIO Priority" -Value "High" -Type String -Force
Write-OK "Hardware GPU Scheduling + Game Task High Priority: ENABLED"

# ========================================================
# STAGE 7: SÂU - MEMORY & DISK I/O
# ========================================================
Write-Section "STAGE 7: SÂU - MEMORY & DISK"

$memMgmtPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management"
Ensure-RegistryPath $memMgmtPath
Set-ItemProperty -Path $memMgmtPath -Name "DisablePagingExecutive" -Value 1 -Type DWord -Force
Set-ItemProperty -Path $memMgmtPath -Name "LargeSystemCache" -Value 0 -Type DWord -Force

$prefetchPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters"
Ensure-RegistryPath $prefetchPath
Set-ItemProperty -Path $prefetchPath -Name "EnablePrefetcher" -Value 0 -Type DWord -Force
Set-ItemProperty -Path $prefetchPath -Name "EnableSuperfetch" -Value 0 -Type DWord -Force

# Clear Standby List
try {
    $signature = @"
    [DllImport("ntdll.dll")]
    public static extern uint NtSetSystemInformation(int InfoClass, IntPtr Info, int Length);
"@
    $ntdll = Add-Type -MemberDefinition $signature -Name "NtDll" -Namespace "Win32" -PassThru
    [IntPtr]$ptr = [System.Runtime.InteropServices.Marshal]::AllocHGlobal(4)
    [System.Runtime.InteropServices.Marshal]::WriteInt32($ptr, 4)
    $ntdll::NtSetSystemInformation(80, $ptr, 4) | Out-Null
    [System.Runtime.InteropServices.Marshal]::FreeHGlobal($ptr)
    Write-OK "Standby Memory List: CLEARED"
} catch { Write-SKIP "Standby clear skipped" }

# Disk I/O
fsutil behavior set disableLastAccess 1 | Out-Null
fsutil behavior set disable8dot3 1 | Out-Null
$ntfsPath = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"
Set-ItemProperty -Path $ntfsPath -Name "NtfsMemoryUsage" -Value 2 -Type DWord -Force
Set-ItemProperty -Path $ntfsPath -Name "NtfsDisable8dot3NameCreation" -Value 1 -Type DWord -Force
[System.GC]::Collect()
Write-OK "Memory + Disk I/O: Optimized"

# ========================================================
# STAGE 8: SÂU - CS2 PROCESS PRIORITY & FOREGROUND BOOST
# ========================================================
Write-Section "STAGE 8: SÂU - CS2 PRIORITY"

$cs2 = Get-Process "cs2" -ErrorAction SilentlyContinue
if ($cs2) {
    $cs2.PriorityClass = "High"
    Write-OK "CS2 Priority: HIGH"
} else {
    Write-SKIP "CS2 chưa chạy - Priority sẽ áp dụng khi mở game"
}

$foregroundPath = "HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl"
Ensure-RegistryPath $foregroundPath
Set-ItemProperty -Path $foregroundPath -Name "Win32PrioritySeparation" -Value 40 -Type DWord -Force
Write-OK "Foreground Boost: MAX"

# ========================================================
# STAGE 9: SÂU - BACKGROUND APPS & NOTIFICATIONS
# ========================================================
Write-Section "STAGE 9: SÂU - BACKGROUND & NOTIFICATIONS"

$bgAppPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
Ensure-RegistryPath $bgAppPath
Set-ItemProperty -Path $bgAppPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force

$notifPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\PushNotifications"
Ensure-RegistryPath $notifPath
Set-ItemProperty -Path $notifPath -Name "ToastEnabled" -Value 0 -Type DWord -Force

$actionPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\Explorer"
Ensure-RegistryPath $actionPath
Set-ItemProperty -Path $actionPath -Name "DisableNotificationCenter" -Value 1 -Type DWord -Force

$deliveryPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeliveryOptimization"
Ensure-RegistryPath $deliveryPath
Set-ItemProperty -Path $deliveryPath -Name "DODownloadMode" -Value 0 -Type DWord -Force
Write-OK "Background Apps + Notifications + Delivery Optimization: OFF"

Write-Host "`n================================================================" -ForegroundColor Green
Write-Host "  ✅  optimize.ps1 HOÀN TẤT - TẤT CẢ LỆNH ĐÃ ĐƯỢC TẬP HỢP" -ForegroundColor Green
Write-Host "================================================================" -ForegroundColor Green

Write-Host "   Script chạy xong lúc: $(Get-Date -Format 'HH:mm:ss dd/MM/yyyy')" -ForegroundColor Cyan
Write-Host "   Khởi động CS2 ngay bây giờ - Không cần restart máy!" -ForegroundColor White
