# =============================
# Updated CentOSHardening.sh (for CentOS 7)
# =============================

#!/usr/bin/env bash

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

# ----- 5. Install OSSEC for Intrusion Detection -----
echo "[+] Installing OSSEC HIDS..."
curl -O https://updates.atomicorp.com/channels/atomic/supported/ossec-hids-3.7.0-6213.el7.art.x86_64.rpm
sudo rpm -ivh ossec-hids-3.7.0-6213.el7.art.x86_64.rpm

# ----- 6. Enable Audit Logging -----
echo "[+] Configuring audit logs..."
sudo systemctl enable auditd
sudo systemctl start auditd
echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
echo "-w /var/log/auth.log -p wa -k auth_logs" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo augenrules --load

# ----- 7. Backup System -----
echo "[+] Creating system backup..."
sudo tar -cvpzf /backup/linux_backup.tar.gz --exclude=/backup / --one-file-system

# ----- 8. Monitor Open Ports -----
echo "[+] Checking open ports..."
sudo netstat -tulnp

# ----- 9. Prevent Brute Force Attacks -----
echo "[+] Implementing brute-force protection..."
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP

# ----- 10. Ensure Scoring Engine Connectivity -----
echo "[+] Checking connection to scoring engine..."
curl -I http://scoring.sdc.cpp

echo "[+] CentOS hardening script complete. Reboot recommended."
