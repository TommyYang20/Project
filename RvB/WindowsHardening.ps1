# =============================
# Comprehensive Windows Hardening Script
# Cyberstrike Blue Team Defense - Windows Server 2016/2019
# =============================

# Ensure script runs with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "[ERROR] This script must be run as an Administrator!" -ForegroundColor Red
    exit 1
}

# ----- 1. Change Default Passwords -----
Write-Host "[INFO] Changing default passwords..."
$Users = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike", "strikesavior", "planetliberator", "haunterhunter", "vanguardprime", "roguestrike", "falconpunch", "specter", "antiterminite")
foreach ($User in $Users) {
    try {
        net user $User "complexP@ssw0rd!" /y
        Write-Host "[SUCCESS] Password changed for $User."
    } catch {
        Write-Host "[ERROR] Failed to change password for $User." -ForegroundColor Red
    }
}

# ----- 2. Disable Guest and Default Accounts -----
Write-Host "[INFO] Disabling Guest and default accounts..."
net user Guest /active:no
Write-Host "[SUCCESS] Guest account disabled."

# ----- 3. Enforce Strong Password Policies -----
Write-Host "[INFO] Enforcing stronger password policies..."
net accounts /minpwlen:14 /maxpwage:30 /lockoutthreshold:5 /lockoutduration:30 /lockoutwindow:30
Write-Host "[SUCCESS] Password policies applied."

# ----- 4. Enable Windows Firewall and Secure Network Rules -----
Write-Host "[INFO] Configuring Windows Firewall..."
netsh advfirewall set allprofiles state on
Write-Host "[SUCCESS] Windows Firewall is enabled."

# ----- 5. Disable SMBv1 (Legacy and Vulnerable) -----
Write-Host "[INFO] Disabling SMBv1..."
Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
Write-Host "[SUCCESS] SMBv1 disabled."

# ----- 6. Restart Critical Services -----
Write-Host "[INFO] Checking and restarting critical services..."
$CriticalServices = @("LanmanServer", "LanmanWorkstation", "W32Time", "DNS", "ADWS")
foreach ($service in $CriticalServices) {
    if (Get-Service -Name $service -ErrorAction SilentlyContinue) {
        Write-Host "Restarting $service..."
        Start-Service -Name $service
    } else {
        Write-Host "[WARNING] Service $service not found. Skipping..."
    }
}
Write-Host "[SUCCESS] Critical services are running."

# ----- 7. Remove Unnecessary Software -----
Write-Host "[INFO] Removing unnecessary software..."
$UnwantedApps = @("XPS-Viewer", "Internet-Explorer-Optional-amd64")
foreach ($App in $UnwantedApps) {
    Write-Host "Removing $App..."
    if (Get-WindowsFeature -Name $App) {
        Uninstall-WindowsFeature -Name $App -Restart
    } else {
        Write-Host "[WARNING] Feature $App not found. Skipping..."
    }
}
Write-Host "[SUCCESS] Unnecessary software removed."

# ----- 8. Enable Audit Logging and Security Monitoring -----
Write-Host "[INFO] Enabling Security Event Logging..."
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
Write-Host "[SUCCESS] Security Event Logging enabled."

# ----- 9. Create System Backup -----
Write-Host "[INFO] Checking if Windows Backup feature is installed..."
if (!(Get-WindowsFeature -Name Windows-Server-Backup).Installed) {
    Write-Host "[INFO] Installing Windows Backup feature..."
    Install-WindowsFeature -Name Windows-Server-Backup -IncludeManagementTools
}
Write-Host "[INFO] Creating system backup..."
wbadmin start backup -backupTarget:D: -include:C: -allCritical -quiet
Write-Host "[SUCCESS] System backup created."

# ----- 10. Monitor Open Ports and Network Security -----
Write-Host "[INFO] Checking open ports..."
netstat -ano | findstr LISTEN

# ----- 11. Ensure Scoring Engine Connectivity -----
Write-Host "[INFO] Checking connection to scoring engine..."
ping scoring.sdc.cpp

Write-Host "[INFO] Windows hardening script complete. Reboot recommended."
