# =============================
# Updated WindowsHardening.ps1 (for Windows 10, Server 2016, Server 2019)
# =============================

# ----- 1. Change User Passwords -----
Write-Output "[+] Changing default passwords..."
$NewPassword = ConvertTo-SecureString "ComplexP@ssw0rd!" -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $NewPassword
net user johncyberstrike ComplexP@ssw0rd!
net user joecyberstrike ComplexP@ssw0rd!
net user janecyberstrike ComplexP@ssw0rd!
Write-Output "[!] REMINDER: Submit password change request for FTP & SSH users."

# ----- 2. Ensure System is Joined to Domain -----
Write-Output "[+] Checking domain membership..."
$Domain = "cyberstrike.corps"
$CurrentDomain = (Get-WmiObject Win32_ComputerSystem).Domain
if ($CurrentDomain -ne $Domain) {
    Write-Output "[!] System is NOT joined to $Domain. Joining now..."
    Add-Computer -DomainName $Domain -Credential (Get-Credential) -Force -Restart
} else {
    Write-Output "[+] System is already part of $Domain."
}

# ----- 3. Remove Unauthorized Admin Users -----
Write-Output "[+] Checking and removing unauthorized admin users..."
$AllowedAdmins = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike")
$CurrentAdmins = Get-LocalGroupMember -Group "Administrators" | Select-Object -ExpandProperty Name
ForEach ($User in $CurrentAdmins) {
    If ($User -notin $AllowedAdmins) {
        Write-Output "Removing unauthorized admin: $User"
        Remove-LocalGroupMember -Group "Administrators" -Member $User
    }
}

# ----- 4. Disable Unused Services -----
Write-Output "[+] Disabling unneeded services..."
Stop-Service -Name "Spooler" -Force
Set-Service -Name "Spooler" -StartupType Disabled

# ----- 5. Enforce Group Policy Updates -----
Write-Output "[+] Forcing Group Policy updates..."
gpupdate /force

# ----- 6. Enable Advanced Windows Logging -----
Write-Output "[+] Configuring Windows Audit Policies..."
auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable
auditpol /set /category:"Account Logon" /success:enable /failure:enable
auditpol /set /category:"System" /success:enable /failure:enable

# ----- 7. Install Sysmon for Advanced Logging -----
Write-Output "[+] Installing Sysmon for better logging..."
$SysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
$SysmonPath = "$env:TEMP\Sysmon.zip"
Invoke-WebRequest -Uri $SysmonUrl -OutFile $SysmonPath
Expand-Archive -Path $SysmonPath -DestinationPath "$env:TEMP\Sysmon"
Start-Process -FilePath "$env:TEMP\Sysmon\sysmon.exe" -ArgumentList "-accepteula -i" -NoNewWindow -Wait

# ----- 8. Ensure Critical Services Are Running -----
Write-Output "[+] Checking and restarting critical Windows services..."
$CriticalServices = @("DNS", "LanmanServer", "LanmanWorkstation", "ADWS", "W32Time")
ForEach ($service in $CriticalServices) {
    If ((Get-Service -Name $service).Status -ne "Running") {
        Write-Output "Restarting $service..."
        Start-Service -Name $service
    }
}

# ----- 9. Perform System Backup -----
Write-Output "[+] Creating system backup..."
wbadmin start backup -backupTarget:D: -include:C: -allCritical -quiet

# ----- 10. Monitor Open Ports -----
Write-Output "[+] Checking open ports..."
Get-NetTCPConnection | Select-Object LocalAddress,LocalPort,State

# ----- 11. Prevent Brute Force Attacks -----
Write-Output "[+] Enabling account lockout policy..."
net accounts /lockoutthreshold:3 /lockoutduration:30 /lockoutwindow:30

# ----- 12. Remove Unnecessary Applications -----
Write-Output "[+] Removing unnecessary applications..."
Get-AppxPackage *xbox* | Remove-AppxPackage
Get-AppxPackage *bing* | Remove-AppxPackage
Get-AppxPackage *solitaire* | Remove-AppxPackage
Get-AppxPackage *skype* | Remove-AppxPackage

# ----- 13. Harden RDP Access -----
Write-Output "[+] Hardening RDP access..."
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1
Write-Output "RDP access has been disabled."

# ----- 14. Restrict PowerShell Execution Policies -----
Write-Output "[+] Restricting PowerShell execution policies..."
Set-ExecutionPolicy RemoteSigned -Force

# ----- 15. Disable Guest Account -----
Write-Output "[+] Disabling Guest Account..."
net user Guest /active:no

# ----- 16. Check Scoring Engine Connectivity -----
Write-Output "[+] Checking connection to scoring engine..."
Test-NetConnection -ComputerName scoring.sdc.cpp

Write-Output "[+] Windows hardening script complete. Reboot recommended."
