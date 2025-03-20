# Windows Hardening Script for Cyberstrike RvB
# Applies to Windows Server 2016, 2019, and Windows 10

# --- 1. Enforce Strong Password Policy ---
Write-Output "Configuring password policies..."
secedit /export /cfg C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("MinimumPasswordLength = 0", "MinimumPasswordLength = 12") | Set-Content C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("PasswordHistorySize = 0", "PasswordHistorySize = 10") | Set-Content C:\secpol.cfg
(Get-Content C:\secpol.cfg).replace("MaximumPasswordAge = 0", "MaximumPasswordAge = 60") | Set-Content C:\secpol.cfg
secedit /configure /db C:\Windows\Security\Local.sdb /cfg C:\secpol.cfg /areas SECURITYPOLICY

# --- 2. Disable Unnecessary Services ---
Write-Output "Disabling unneeded services..."
$services = @("RemoteRegistry", "Telnet", "FTP", "SMB1", "Spooler")
foreach ($service in $services) {
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue
    Set-Service -Name $service -StartupType Disabled
}

# --- 3. Configure Windows Firewall ---
Write-Output "Configuring Windows Firewall..."
New-NetFirewallRule -DisplayName "Allow DNS" -Direction Inbound -Action Allow -Protocol UDP -LocalPort 53
New-NetFirewallRule -DisplayName "Allow HTTP & HTTPS" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 80,443
New-NetFirewallRule -DisplayName "Allow SMB" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 445
New-NetFirewallRule -DisplayName "Allow RDP" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 3389
New-NetFirewallRule -DisplayName "Block Telnet & FTP" -Direction Inbound -Action Block -Protocol TCP -LocalPort 21,23

# --- 4. Hardening Remote Desktop ---
Write-Output "Securing RDP..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Value 1

# --- 5. Restrict Administrator Account Usage ---
Write-Output "Restricting local admin account..."
Set-LocalUser -Name "Administrator" -Password (ConvertTo-SecureString "CyberStrikeSecure!2024" -AsPlainText -Force)
Disable-LocalUser -Name "Administrator"

# --- 6. Remove Unauthorized Users ---
Write-Output "Removing unauthorized users..."
$allowedUsers = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
Get-LocalUser | Where-Object { $_.Name -notin $allowedUsers } | ForEach-Object {
    Remove-LocalUser -Name $_.Name
}

# --- 7. Enable Logging & Auditing ---
Write-Output "Enabling security logging..."
auditevtwr -Enable
Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 1

Write-Output "Windows hardening complete. Reboot recommended."
