# =============================
# Windows Hardening Script for Cyberstrike RvB (Windows Server 2016)
# =============================

$allowedAdmins = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
# --- [0] Detect OS Version ---
$osVersion = (Get-CimInstance Win32_OperatingSystem).Caption
Write-Host "[+] Detected OS: $osVersion"
$includeNTDS = $false
$includeDNS = $false

if ($osVersion -match "2016") {
    $includeDNS = $true
} elseif ($osVersion -match "2019") {
    $includeDNS = $true
    $includeNTDS = $true
} elseif ($osVersion -match "Windows 10") {
    Write-Host "[!] Skipping domain service configurations on Windows 10."
}

if ($osVersion -match "2019") {
    $exchange = Get-Service -Name "MSExchangeIS" -ErrorAction SilentlyContinue
    if ($exchange) {
        Set-Service -Name "MSExchangeIS" -StartupType Automatic
        Start-Service -Name "MSExchangeIS"
        Write-Host "[✓] MSExchangeIS is running and set to auto-start."
    }
}

# --- 1. Ensure Windows Firewall is Running ---
Set-Service -Name MpsSvc -StartupType Automatic
Start-Service -Name MpsSvc

# --- 2. Configure Windows Firewall Rules ---
New-NetFirewallRule -DisplayName "Allow DNS" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 53
New-NetFirewallRule -DisplayName "Allow HTTP & HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443
New-NetFirewallRule -DisplayName "Allow SMB" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445
New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389
New-NetFirewallRule -DisplayName "Block Telnet & FTP" -Direction Inbound -Action Block -Protocol TCP -LocalPort 21,23

# --- [4] Harden Remote Desktop ---
Write-Host "[+] Securing RDP settings..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# --- [5] Enforce Admin Group Membership ---
Write-Host "[+] Enforcing allowed administrators..."
$adminGroup = [ADSI]"WinNT://./Administrators,group"
$members = @($adminGroup.psbase.Invoke("Members")) | ForEach-Object {
    $_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)
}
foreach ($member in $members) {
    if ($allowedAdmins -notcontains $member) {
        Write-Host "[-] Removing unauthorized admin: $member"
        net localgroup Administrators $member /delete
    }
}

# --- [6] Remove Unauthorized Local Users ---
Write-Host "[+] Removing unauthorized local users..."
Get-LocalUser | Where-Object {
    $_.Enabled -eq $true -and $_.SID -like "S-1-5-21*" -and ($allowedAdmins -notcontains $_.Name)
} | ForEach-Object {
    Write-Host "[-] Deleting user: $($_.Name)"
    Remove-LocalUser -Name $_.Name
}

# --- [7] Update Passwords for Allowed Users ---
#Write-Host "[+] Updating passwords for allowed users..."
#$securePassword = ConvertTo-SecureString "CyberStrikeSecure!2024" -AsPlainText -Force
#foreach ($user in $allowedAdmins) {
#    try {
#        Set-LocalUser -Name $user -Password $securePassword
#        Write-Host "[✓] Password updated for: $user"
#    } catch {
#        Write-Host "[!] Could not update password for: $user"
#    }
#}

# --- [8] Configure Auto-Restart for Critical Services ---
Write-Host "[+] Setting failure recovery for critical services..."
$criticalServices = @("LanmanServer")
if ($includeDNS) { $criticalServices += "DNS" }
if ($includeNTDS) { $criticalServices += "NTDS" }
foreach ($service in $criticalServices) {
    sc.exe failure $service reset= 0 actions= restart/60000/restart/60000/restart/60000 | Out-Null
}

# --- [9] Remove & Disable Unnecessary Services ---
Write-Host "[+] Disabling unnecessary/risky services..."
$unnecessaryServices = @("RemoteRegistry", "Telnet", "FTP", "Spooler")
foreach ($service in $unnecessaryServices) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled -ErrorAction SilentlyContinue
}

# --- [10] Install Windows Updates ---
Write-Host "[+] Installing Windows Updates..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
Install-Module PSWindowsUpdate -Force -Confirm:$false | Out-Null
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# --- [11] Ensure Critical Services are Running ---
Write-Host "[+] Ensuring critical services are running..."
foreach ($svc in $criticalServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        Set-Service -Name $svc -StartupType Automatic
        Start-Service -Name $svc
        Write-Host "[✓] $svc is running and set to auto-start."
    }
}

Write-Host "[✓] Windows hardening complete. Rebooting..."
Restart-Computer -Force
