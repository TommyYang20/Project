# --- 1. Enforce Strong Password Policy ---
Write-Output "Configuring password policies..."
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("MinimumPasswordLength = 0", "MinimumPasswordLength = 12") | Set-Content C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("PasswordHistorySize = 0", "PasswordHistorySize = 10") | Set-Content C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("MaximumPasswordAge = 0", "MaximumPasswordAge = 60") | Set-Content C:\secpol.cfg
secedit /configure /db C:\Windows\Security\Local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY

# --- 2. Disable Unnecessary Services ---
Write-Output "Disabling unneeded services..."
$services = @("RemoteRegistry", "Telnet", "FTP", "Spooler")
foreach ($service in $services) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled
}

# --- 3. Ensure Windows Firewall is Running ---
Write-Output "Ensuring Windows Firewall service is running..."
Set-Service -Name "MpsSvc" -StartupType Automatic
Start-Service -Name "MpsSvc"
Start-Sleep -Seconds 5

# --- 4. Configure Windows Firewall Using PowerShell ---
Write-Output "Configuring Windows Firewall..."
if ((Get-Service MpsSvc).Status -eq 'Running') {
    Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True
    New-NetFirewallRule -DisplayName "Allow DNS" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 53
    New-NetFirewallRule -DisplayName "Allow HTTP & HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443
    New-NetFirewallRule -DisplayName "Allow SMB" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445
    New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389
    New-NetFirewallRule -DisplayName "Block Telnet & FTP" -Direction Inbound -Action Block -Protocol TCP -LocalPort 21,23
} else {
    Write-Output "Windows Firewall service is not running. Skipping firewall rules."
}

# --- 5. Hardening Remote Desktop ---
Write-Output "Securing RDP..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# --- 6. Restrict Administrator & Other Domain Accounts ---
Write-Output "Updating passwords for key accounts..."
$users = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
foreach ($user in $users) {
    Write-Output "Updating password for: $user"
    net user $user CyberStrikeSecure!2024
}

# --- 7. Remove Unauthorized Users ---
Write-Output "Removing unauthorized users..."
$allowedUsers = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
foreach ($user in (Get-WmiObject Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }).Name) {
    if ($user -notin $allowedUsers) {
        Write-Output "Removing user: $user"
        net user $user /delete
    }
}

# --- 8. Enable Logging & Auditing ---
Write-Output "Enabling security logging..."
auditpol /set /subcategory:"Logon" /success:enable /failure:enable

# --- 9. Service Integrity & Recovery ---
Write-Output "Configuring auto-restart for critical services..."
$criticalServices = @("DNS", "LanmanServer", "NTDS")
foreach ($service in $criticalServices) {
    sc.exe failure $service reset= 0 actions= restart/60000/restart/60000/restart/60000
}

Write-Output "Windows Server 2016 hardening complete. Reboot recommended."
