
# =============================
# Updated LinuxHandening.sh (for Ubuntu 22.04)
# =============================

#!/usr/bin/env bash

# ----- 0. Variables -----
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
INTERNAL_NETWORK="10.10.0.0/16"

# ----- 1. Update & Upgrade -----
echo "[+] Updating apt and upgrading packages..."
sudo apt-get update -y && sudo apt-get dist-upgrade -y

# ----- 2. Remove Unnecessary Packages -----
echo "[+] Removing unnecessary packages..."
sudo apt-get remove -y telnet rsh-server xinetd cups bluetooth
sudo apt-get autoremove -y

# ----- 3. Remove Unauthorized Users -----
echo "[+] Removing unauthorized local accounts..."
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        sudo deluser --remove-home "$user"
    fi
done

# ----- 4. Configure Firewall (UFW) -----
echo "[+] Configuring UFW firewall..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow from $INTERNAL_NETWORK to any port 22
sudo ufw allow 123/udp  # NTP
sudo ufw allow 21/tcp  # FTP
sudo ufw enable

# ----- 5. Hardening SSH -----
echo "[+] Hardening SSH access..."
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# ----- 6. Install & Configure Fail2Ban -----
echo "[+] Installing Fail2Ban..."
sudo apt-get install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# ----- 7. Install OSSEC for Intrusion Detection -----
echo "[+] Installing OSSEC HIDS..."
wget -qO - https://updates.atomicorp.com/channels/atomic/supported/ossec-hids-3.7.0.deb | sudo dpkg -i -

# ----- 8. Enable Audit Logging -----
echo "[+] Configuring audit logs..."
sudo systemctl enable auditd
sudo systemctl start auditd
echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /var/log/auth.log -p wa -k auth_logs" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo augenrules --load

# ----- 9. Ensure Critical Services Are Running -----
echo "[+] Checking and restarting critical services..."
SERVICES=("vsftpd" "ntp")
for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        echo "Restarting $service..."
        sudo systemctl restart "$service"
    fi
done

# ----- 10. Backup System -----
echo "[+] Creating system backup..."
sudo tar -cvpzf /backup/linux_backup.tar.gz --exclude=/backup / --one-file-system

# ----- 11. Monitor Open Ports -----
echo "[+] Checking open ports..."
sudo netstat -tulnp

# ----- 12. Prevent Brute Force Attacks -----
echo "[+] Implementing brute-force protection..."
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP

# ----- 13. Ensure Scoring Engine Connectivity -----
echo "[+] Checking connection to scoring engine..."
curl -I http://scoring.sdc.cpp

# ----- 14. Log Password Change Requests for SSH/FTP Users -----
echo "[$(date)] Password changed for SSH & FTP users" >> /var/log/password_changes.log

echo "[!] REMINDER: Submit password change request for FTP & SSH users."
echo "[+] Ubuntu hardening complete. Reboot recommended."
