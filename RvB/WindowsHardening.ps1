# ==============================
# harden-windows.ps1
# ==============================
# NOTE: Customize domain names, user lists, features, etc. for your environment.

# ----- 0. Variables -----
$domain = "cyberstrike.corps"
$allowedLocalAdmins = @("Administrator","johncyberstrike","joecyberstrike","janecyberstrike","janicecyberstrike")
# If your domain accounts appear in local Administrators group as DOMAIN\user, adjust logic as needed.

# ----- 1. Remove Unauthorized Local User Accounts -----
Write-Host "Removing unauthorized local accounts..."
$localUsers = Get-LocalUser
foreach ($user in $localUsers) {
    # Skip built-in accounts or domain-based SIDs
    # If it's not in the $allowedLocalAdmins list and not a built-in system account, remove it.
    if ($allowedLocalAdmins -notcontains $user.Name -and $user.Name -notmatch "^(WDAGUtility|DefaultAccount|Guest)$") {
        Write-Host "Removing local account $($user.Name)"
        # Uncomment to actually remove:
        # Remove-LocalUser -Name $user.Name
    }
}

# ----- 2. Ensure Only Authorized Accounts in Local Administrators Group -----
Write-Host "Ensuring only authorized accounts in local Administrators group..."
$adminGroup = [ADSI]"WinNT://./Administrators,group"
$members = @($adminGroup.psbase.Invoke("Members")) | ForEach-Object {
    New-Object System.DirectoryServices.DirectoryEntry($_)
}

foreach ($member in $members) {
    # e.g. "WinNT://cyberstrike.corps/janicecyberstrike" or "WinNT://./Administrator"
    $accountName = $member.Name
    if ($allowedLocalAdmins -notcontains $accountName) {
        Write-Host "Removing $($accountName) from local Administrators group..."
        # Uncomment to actually remove:
        # $adminGroup.Remove("WinNT://$accountName")
    }
}

# ----- 3. Enable & Configure Windows Firewall (Inbound default block) -----
Write-Host "Enabling Windows Firewall for all profiles..."
netsh advfirewall set allprofiles state on

# Example: allow inbound rules for critical domain services (DNS, SMB, Exchange, etc.)
# Adjust to your actual ports & services.

Write-Host "Allowing DNS inbound on TCP/UDP 53..."
netsh advfirewall firewall add rule name="Allow DNS TCP 53" dir=in action=allow protocol=TCP localport=53
netsh advfirewall firewall add rule name="Allow DNS UDP 53" dir=in action=allow protocol=UDP localport=53

Write-Host "Allowing SMB (file sharing) inbound on TCP 445..."
netsh advfirewall firewall add rule name="Allow SMB 445" dir=in action=allow protocol=TCP localport=445

Write-Host "Allowing Exchange inbound ports (example 25 for SMTP, 443, 587, etc.)..."
# netsh advfirewall firewall add rule name="Allow SMTP" dir=in action=allow protocol=TCP localport=25
# netsh advfirewall firewall add rule name="Allow HTTPS" dir=in action=allow protocol=TCP localport=443
# Add other Exchange ports as needed.

# Remove extraneous or suspicious firewall rules
Write-Host "Removing extraneous inbound firewall rules..."
# Adjust logic as needed to remove rules that are known to be unwanted.

# ----- 4. Disable SMBv1 -----
Write-Host "Disabling SMBv1..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force

# ----- 5. Basic Password Policies (Local) -----
Write-Host "Setting local password policies..."
# For domain-joined servers, do this in Group Policy at the domain level if possible.
# Example local policy changes (adjust to your needs):
# Minimum password length = 12, max password age = 60 days, etc.
secedit /export /cfg C:\Temp\currentSecPolicy.inf
(gc C:\Temp\currentSecPolicy.inf) | 
    Foreach-Object {
        $_ -replace "MinimumPasswordLength = .*","MinimumPasswordLength = 12" `
           -replace "MaximumPasswordAge = .*","MaximumPasswordAge = 60"
    } | Out-File C:\Temp\newSecPolicy.inf

secedit /configure /db C:\Windows\security\local.sdb /cfg C:\Temp\newSecPolicy.inf /areas SECURITYPOLICY

# ----- 6. Remove or Disable Unnecessary Windows Features -----
Write-Host "Removing unnecessary Windows features..."
# Example placeholders – adjust to fit your environment:
# Uninstall-WindowsFeature -Name "Web-Server" -Restart:$false
# Uninstall-WindowsFeature -Name "Fax-Services" -Restart:$false
# ... etc.

# ----- 7. Install Windows Updates -----
Write-Host "Installing Windows Updates... (requires PSWindowsUpdate module)"
# Example approach using PSWindowsUpdate if installed:
# Install-Module PSWindowsUpdate -Force
# Import-Module PSWindowsUpdate
# Get-WindowsUpdate -AcceptAll -Install -AutoReboot

Write-Host "Windows Server hardening script complete."
