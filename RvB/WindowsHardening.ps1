# =============================
# Updated WindowsHardening.ps1 (for Windows 10, Server 2016, Server 2019)
# =============================

# Function for logging with timestamps
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Output $logMessage
    # Log to file (adjust path as needed)
    $logMessage | Out-File -FilePath "C:\Windows\Temp\windows_hardening.log" -Append -Encoding utf8
}

# ----- 1. Change User Passwords -----
Write-Log "[+] Changing default passwords..."
try {
    $NewPassword = ConvertTo-SecureString "ComplexP@ssw0rd!" -AsPlainText -Force
    Set-LocalUser -Name "Administrator" -Password $NewPassword -ErrorAction Stop
    net user johncyberstrike ComplexP@ssw0rd!
    net user joecyberstrike ComplexP@ssw0rd!
    net user janecyberstrike ComplexP@ssw0rd!
    net user janicecyberstrike ComplexP@ssw0rd!
    Write-Log "[+] Passwords changed successfully."
} catch {
    Write-Log "Changing passwords failed: $_" "ERROR"
    exit 1
}

Write-Log "[!] REMINDER: Submit password change request for FTP & SSH users."

# ----- 2. Ensure System is Joined to Domain -----
Write-Log "[+] Checking domain membership..."
try {
    $Domain = "cyberstrike.corps"
    $CurrentDomain = (Get-WmiObject Win32_ComputerSystem).Domain
    if ($CurrentDomain -ne $Domain) {
        Write-Log "[!] System is NOT joined to $Domain. Attempting to join..."
        $credential = Get-Credential -Message "Enter credentials for domain join"
        Add-Computer -DomainName $Domain -Credential $credential -Force -ErrorAction Stop
        Write-Log "[+] Successfully joined the domain. Restarting..."
        Restart-Computer -Force
    } else {
        Write-Log "[+] System is already part of $Domain."
    }
} catch {
    Write-Log "Domain membership check failed: $_" "ERROR"
    exit 1
}

# ----- 3. Remove Unauthorized Admin Users -----
Write-Log "[+] Checking and removing unauthorized admin users..."
try {
    $AllowedAdmins = @("Administrator", "johncyberstrike", "joecyberstrike", "janecyberstrike", "janicecyberstrike")
    $CurrentAdmins = (Get-LocalGroupMember -Group "Administrators").Name
    foreach ($User in $CurrentAdmins) {
        if ($AllowedAdmins -notcontains $User) {
            Write-Log "[*] Removing unauthorized admin: $User"
            Remove-LocalGroupMember -Group "Administrators" -Member $User -ErrorAction Stop
        }
    }
    Write-Log "[+] Unauthorized admin removal complete."
} catch {
    Write-Log "Admin removal failed: $_" "ERROR"
    exit 1
}

# ----- 4. Disable Unused Services -----
Write-Log "[+] Disabling unneeded services (Spooler)..."
try {
    $spooler = Get-Service -Name "Spooler" -ErrorAction Stop
    if ($spooler.Status -ne "Stopped") {
        Stop-Service -Name "Spooler" -Force -ErrorAction Stop
    }
    Set-Service -Name "Spooler" -StartupType Disabled -ErrorAction Stop
    Write-Log "[+] Spooler service disabled."
} catch {
    Write-Log "Disabling Spooler failed: $_" "ERROR"
    exit 1
}

# ----- 5. Enforce Group Policy Updates -----
Write-Log "[+] Forcing Group Policy updates..."
try {
    gpupdate /force | Out-Null
    Write-Log "[+] Group Policy updated."
} catch {
    Write-Log "Group Policy update failed: $_" "ERROR"
    exit 1
}

# ----- 6. Enable Advanced Windows Logging -----
Write-Log "[+] Configuring Windows Audit Policies..."
try {
    auditpol /set /category:"Logon/Logoff" /success:enable /failure:enable | Out-Null
    auditpol /set /category:"Account Logon" /success:enable /failure:enable | Out-Null
    auditpol /set /category:"System" /success:enable /failure:enable | Out-Null
    Write-Log "[+] Audit policies configured."
} catch {
    Write-Log "Configuring audit policies failed: $_" "ERROR"
    exit 1
}

# ----- 7. Install Sysmon for Advanced Logging -----
Write-Log "[+] Installing Sysmon for advanced logging..."
try {
    $SysmonUrl = "https://download.sysinternals.com/files/Sysmon.zip"
    $SysmonPath = "$env:TEMP\Sysmon.zip"
    Invoke-WebRequest -Uri $SysmonUrl -OutFile $SysmonPath -ErrorAction Stop
    Expand-Archive -Path $SysmonPath -DestinationPath "$env:TEMP\Sysmon" -Force
    Start-Process -FilePath "$env:TEMP\Sysmon\sysmon.exe" -ArgumentList "-accepteula -i" -NoNewWindow -Wait
    Write-Log "[+] Sysmon installed successfully."
} catch {
    Write-Log "Sysmon installation failed: $_" "ERROR"
    exit 1
}

# ----- 8. Ensure Critical Services Are Running -----
Write-Log "[+] Checking and restarting critical Windows services..."
try {
    $CriticalServices = @("DNS", "LanmanServer", "LanmanWorkstation", "ADWS", "W32Time")
    foreach ($service in $CriticalServices) {
        $svc = Get-Service -Name $service -ErrorAction SilentlyContinue
        if ($svc -and $svc.Status -ne "Running") {
            Write-Log "[*] Restarting $service..."
            Start-Service -Name $service -ErrorAction Stop
        }
    }
    Write-Log "[+] Critical services are running."
} catch {
    Write-Log "Restarting critical services failed: $_" "ERROR"
    exit 1
}

# ----- 9. Perform System Backup -----
Write-Log "[+] Creating system backup..."
try {
    wbadmin start backup -backupTarget:D: -include:C: -allCritical -quiet
    Write-Log "[+] Backup initiated."
} catch {
    Write-Log "Backup failed: $_" "ERROR"
    exit 1
}

# ----- 10. Monitor Open Ports -----
Write-Log "[+] Checking open ports..."
try {
    $ports = Get-NetTCPConnection | Select-Object LocalAddress, LocalPort, State
    $ports | Format-Table | Out-String | Write-Log
} catch {
    Write-Log "Monitoring open ports failed: $_" "ERROR"
    exit 1
}

# ----- 11. Prevent Brute Force Attacks -----
Write-Log "[+] Enabling account lockout policy..."
try {
    net accounts /lockoutthreshold:3 /lockoutduration:30 /lockoutwindow:30 | Out-Null
    Write-Log "[+] Account lockout policy configured."
} catch {
    Write-Log "Configuring account lockout policy failed: $_" "ERROR"
    exit 1
}

# ----- 12. Remove Unnecessary Applications -----
Write-Log "[+] Removing unnecessary applications..."
try {
    Get-AppxPackage *xbox* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage *bing* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage *solitaire* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxPackage *skype* | Remove-AppxPackage -ErrorAction SilentlyContinue
    Write-Log "[+] Unnecessary applications removed."
} catch {
    Write-Log "Removing applications failed: $_" "ERROR"
    exit 1
}

# ----- 13. Harden RDP Access -----
Write-Log "[+] Hardening RDP access..."
try {
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 1 -ErrorAction Stop
    Write-Log "[+] RDP access has been disabled."
} catch {
    Write-Log "Hardening RDP access failed: $_" "ERROR"
    exit 1
}

# ----- 14. Restrict PowerShell Execution Policies -----
Write-Log "[+] Restricting PowerShell execution policies..."
try {
    Set-ExecutionPolicy RemoteSigned -Force -ErrorAction Stop
    Write-Log "[+] PowerShell execution policy set to RemoteSigned."
} catch {
    Write-Log "Setting execution policy failed: $_" "ERROR"
    exit 1
}

# ----- 15. Disable Guest Account -----
Write-Log "[+] Disabling Guest account..."
try {
    net user Guest /active:no | Out-Null
    Write-Log "[+] Guest account disabled."
} catch {
    Write-Log "Disabling Guest account failed: $_" "ERROR"
    exit 1
}

# ----- 16. Check Scoring Engine Connectivity -----
Write-Log "[+] Checking connection to scoring engine..."
try {
    Test-NetConnection -ComputerName scoring.sdc.cpp -ErrorAction Stop | Out-Null
    Write-Log "[+] Scoring engine is reachable."
} catch {
    Write-Log "Scoring engine connectivity test failed: $_" "ERROR"
    exit 1
}

# ----- 17. Prevent Credential Dumping, Force Logout, Block RDP Users -----
Write-Log "[+] Applying registry changes to prevent credential dumping and enforce logout..."
try {
    reg add "HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RunAsPPL /t REG_DWORD /d 1 /f | Out-Null
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v MaxFailedLogins /t REG_DWORD /d 3 /f | Out-Null
    # Remove all members from the Remote Desktop Users group
    $rdpUsers = Get-LocalGroupMember -Group "Remote Desktop Users" -ErrorAction SilentlyContinue
    foreach ($user in $rdpUsers) {
        Remove-LocalGroupMember -Group "Remote Desktop Users" -Member $user -ErrorAction SilentlyContinue
    }
    Write-Log "[+] Registry changes applied and Remote Desktop Users group cleaned up."
} catch {
    Write-Log "Applying registry changes failed: $_" "ERROR"
    exit 1
}

Write-Log "[+] Windows hardening script complete. Reboot recommended."
