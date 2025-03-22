# Windows Hardening Script for Cyberstrike RvB (Windows Server 2016)

# --- 1. Ensure Windows Firewall is Running ---
Set-Service -Name MpsSvc -StartupType Automatic
Start-Service -Name MpsSvc

# --- 2. Configure Windows Firewall Rules ---
New-NetFirewallRule -DisplayName "Allow DNS" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 53
New-NetFirewallRule -DisplayName "Allow HTTP & HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443
New-NetFirewallRule -DisplayName "Allow SMB" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445
New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389
New-NetFirewallRule -DisplayName "Block Telnet & FTP" -Direction Inbound -Action Block -Protocol TCP -LocalPort 21,23


# --- 3. Hardening Remote Desktop ---
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# --- 4. Restrict Administrator & Other Domain Accounts ---
$users = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
foreach ($user in $users) {
    net user $user CyberStrikeSecure!2024
}

# --- 5. Remove Unauthorized Users ---
$allowedUsers = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
foreach ($user in (Get-WmiObject Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }).Name) {
    if ($user -notin $allowedUsers) {
        net user $user /delete
    }
}
# --- 5.2. Remove Unauthorized Local Users ---
Write-Host "[+] Checking local users..."
$allowedUsers = $allowedAdmins
Get-LocalUser | Where-Object {
    $_.Enabled -eq $true -and $_.SID -like "S-1-5-21*" -and ($allowedUsers -notcontains $_.Name)
} | ForEach-Object {
    Write-Host "[-] Removing unauthorized user: $($_.Name)"
    Remove-LocalUser -Name $_.Name
}

# --- 5.1. Enforce Allowed Admins ---
Write-Host "[+] Checking local administrators..."
$allowedAdmins = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
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



# --- 6. Configure Auto-Restart for Critical Services ---
$criticalServices = @("DNS", "LanmanServer", "NTDS")
foreach ($service in $criticalServices) {
    sc.exe failure $service reset= 0 actions= restart/60000/restart/60000/restart/60000
}

# --- 7. Remove Unnecessary Services ---
$unnecessaryServices = @("RemoteRegistry", "Telnet", "FTP", "Spooler")
foreach ($service in $unnecessaryServices) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled
}

# --- 8. Windows Update (Applies to all systems) ---
Write-Host "[+] Installing Windows Updates..."
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
Install-Module PSWindowsUpdate -Force
Import-Module PSWindowsUpdate
Get-WindowsUpdate -AcceptAll -Install -AutoReboot

# --- 9. Enable & Start Critical Services ---
Write-Host "[+] Starting scored critical services if present..."
$criticalServices = @("DNS", "NTDS", "MSExchangeIS", "LanmanServer")
foreach ($svc in $criticalServices) {
    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue
    if ($service) {
        Set-Service -Name $svc -StartupType Automatic
        Start-Service -Name $svc
        Write-Host "[+] $svc is running and set to auto-start."
    }
}

# --- 10. Disable Risky Services (Optional) ---
Write-Host "[+] Disabling unnecessary/risky services..."
Stop-Service -Name 'RemoteRegistry' -Force -ErrorAction SilentlyContinue
Set-Service -Name 'RemoteRegistry' -StartupType Disabled -ErrorAction SilentlyContinue

Write-Output "Windows Server 2016 hardening complete. Reboot recommended."
