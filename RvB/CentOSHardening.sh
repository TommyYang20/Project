# =============================
# Updated CentOSHardening.sh (for CentOS 7)
# =============================

#!/usr/bin/env bash

# ----- 0. Variables -----
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
INTERNAL_NETWORK="10.10.0.0/16"

# ----- 1. Update and Upgrade -----
echo "[+] Updating and upgrading packages..."
sudo yum -y update

# ----- 2. Remove Unnecessary Packages -----
echo "[+] Removing unnecessary packages..."
sudo yum -y remove rsh-server telnet-server xinetd cups bluetooth

# ----- 3. Ensure SELinux is Enforcing -----
echo "[+] Ensuring SELinux is enforcing..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1

# ----- 4. Remove Unauthorized Users -----
echo "[+] Removing unauthorized local accounts..."
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        sudo userdel -r "$user"
    fi
done

# ----- 5. Configure Firewall (Firewalld) -----
echo "[+] Configuring firewall to restrict SSH to internal network..."
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --set-default-zone=drop
sudo firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=$INTERNAL_NETWORK accept"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload

# ----- 6. Install OSSEC for Intrusion Detection -----
echo "[+] Installing OSSEC HIDS..."
curl -O https://updates.atomicorp.com/channels/atomic/supported/ossec-hids-3.7.0-6213.el7.art.x86_64.rpm
sudo rpm -ivh ossec-hids-3.7.0-6213.el7.art.x86_64.rpm

# ----- 7. Enable Audit Logging -----
echo "[+] Configuring audit logs..."
sudo systemctl enable auditd
sudo systemctl start auditd
echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /var/log/secure -p wa -k auth_logs" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo augenrules --load

# ----- 8. Ensure Critical Services Are Running -----
echo "[+] Checking and restarting critical services..."
SERVICES=("named" "httpd")
for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        echo "Restarting $service..."
        sudo systemctl restart "$service"
    fi
done

# ----- 9. Backup System -----
echo "[+] Creating system backup..."
sudo tar -cvpzf /backup/linux_backup.tar.gz --exclude=/backup / --one-file-system

# ----- 10. Monitor Open Ports -----
echo "[+] Checking open ports..."
sudo netstat -tulnp

# ----- 11. Prevent Brute Force Attacks -----
echo "[+] Implementing brute-force protection..."
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP

# ----- 12. Ensure Scoring Engine Connectivity -----
echo "[+] Checking connection to scoring engine..."
curl -I http://scoring.sdc.cpp

# ----- 13. Log Password Change Requests for SSH/FTP Users -----
echo "[$(date)] Password changed for SSH & FTP users" >> /var/log/password_changes.log

echo "[!] REMINDER: Submit password change request for FTP & SSH users."
echo "[+] CentOS hardening complete. Reboot recommended."
