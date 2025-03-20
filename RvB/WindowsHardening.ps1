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

# --- 3. Configure Windows Firewall ---
Write-Output "Configuring Windows Firewall..."
netsh advfirewall firewall add rule name="Allow DNS" dir=in action=allow protocol=UDP localport=53
netsh advfirewall firewall add rule name="Allow HTTP & HTTPS" dir=in action=allow protocol=TCP localport=80,443
netsh advfirewall firewall add rule name="Allow SMB" dir=in action=allow protocol=TCP localport=445
netsh advfirewall firewall add rule name="Allow RDP" dir=in action=allow protocol=TCP localport=3389
netsh advfirewall firewall add rule name="Block Telnet & FTP" dir=in action=block protocol=TCP localport=21,23

# --- 4. Hardening Remote Desktop ---
Write-Output "Securing RDP..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# --- 5. Restrict Administrator & Other Domain Accounts ---
Write-Output "Updating passwords for key accounts..."
$users = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
$newPassword = ConvertTo-SecureString "CyberStrikeSecure!2024" -AsPlainText -Force
foreach ($user in $users) {
    Write-Output "Updating password for: $user"
    net user $user CyberStrikeSecure!2024
}

# --- 6. Remove Unauthorized Users ---
Write-Output "Removing unauthorized users..."
$allowedUsers = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
foreach ($user in (Get-WmiObject Win32_UserAccount | Where-Object { $_.LocalAccount -eq $true }).Name) {
    if ($user -notin $allowedUsers) {
        Write-Output "Removing user: $user"
        net user $user /delete
    }
}

# --- 7. Enable Logging & Auditing ---
Write-Output "Enabling security logging..."
audpol /set /category:"Account Logon" /success:enable /failure:enable

# --- 8. Service Integrity & Recovery ---
Write-Output "Configuring auto-restart for critical services..."
$criticalServices = @("DNS", "LanmanServer", "NTDS")
foreach ($service in $criticalServices) {
    sc.exe failure $service reset= 0 actions= restart/60000/restart/60000/restart/60000
}

Write-Output "Windows Server 2016 hardening complete. Reboot recommended."
