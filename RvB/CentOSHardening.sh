#!/usr/bin/env bash

LOGFILE="/var/log/centos_hardening.log"

log() {
    echo "[$(date)] $1" | tee -a "$LOGFILE"
}

# ----- 0. Variables -----
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
INTERNAL_NETWORK="10.10.0.0/16"
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/linux_backup.tar.gz"

# Function to check exit status
check_exit() {
    if [ $? -ne 0 ]; then
        log "[ERROR] $1 failed. Exiting."
        exit 1
    fi
}

# ----- 1. Update and Upgrade -----
log "[+] Updating and upgrading packages..."
sudo yum -y update
check_exit "yum update"

# ----- 2. Remove Unnecessary Packages -----
log "[+] Removing unnecessary packages..."
sudo yum -y remove rsh-server telnet-server xinetd cups bluetooth
check_exit "Removing packages"

# ----- 3. Ensure SELinux is Enforcing -----
log "[+] Ensuring SELinux is enforcing..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
check_exit "Updating SELinux config"
sudo setenforce 1
check_exit "Setting SELinux enforcing"

# ----- 4. Remove Unauthorized Users -----
log "[+] Removing unauthorized local accounts..."
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        log "[*] Removing user: $user"
        sudo userdel -r "$user"
    fi
done

# ----- 5. Configure Firewall (Firewalld) -----
log "[+] Configuring firewall to restrict SSH to internal network..."
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --permanent --set-default-zone=drop
sudo firewall-cmd --permanent --add-rich-rule="rule family=ipv4 source address=$INTERNAL_NETWORK accept"
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-service=dns
sudo firewall-cmd --reload

# ----- 6. Install OSSEC for Intrusion Detection -----
log "[+] Installing OSSEC HIDS..."
curl -O https://updates.atomicorp.com/channels/atomic/supported/ossec-hids-3.7.0-6213.el7.art.x86_64.rpm
check_exit "Downloading OSSEC"
sudo rpm -ivh ossec-hids-3.7.0-6213.el7.art.x86_64.rpm
check_exit "Installing OSSEC"

# ----- 7. Enable Audit Logging -----
log "[+] Configuring audit logs..."
sudo systemctl enable auditd
sudo systemctl start auditd
grep -qF "-w /etc/passwd -p wa -k passwd_changes" /etc/audit/rules.d/audit.rules || echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
grep -qF "-w /var/log/secure -p wa -k auth_logs" /etc/audit/rules.d/audit.rules || echo "-w /var/log/secure -p wa -k auth_logs" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo augenrules --load

# ----- 8. Ensure Critical Services Are Running -----
log "[+] Checking and restarting critical services..."
SERVICES=("named" "httpd")
for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        log "[*] Restarting $service..."
        sudo systemctl restart "$service"
    fi
done

# ----- 9. Backup System -----
log "[+] Creating system backup..."
if [ ! -d "$BACKUP_DIR" ]; then
    sudo mkdir -p "$BACKUP_DIR"
    check_exit "Creating backup directory"
fi
sudo tar -cvpzf "$BACKUP_FILE" --exclude="$BACKUP_DIR" / --one-file-system
check_exit "Creating backup"

# ----- 10. Monitor Open Ports -----
log "[+] Checking open ports..."
sudo netstat -tulnp

# ----- 11. Prevent Brute Force Attacks -----
log "[+] Implementing brute-force protection..."
sudo iptables -C INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set 2>/dev/null || \
    sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
sudo iptables -C INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP 2>/dev/null || \
    sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP

# ----- 12. Ensure Scoring Engine Connectivity -----
log "[+] Checking connection to scoring engine..."
curl -I http://scoring.sdc.cpp

# ----- 13. Log Password Change Requests for SSH/FTP Users -----
log "[+] Logging password change request..."
echo "[$(date)] Password changed for SSH & FTP users" | sudo tee -a /var/log/password_changes.log

# ----- 14. Harden Memory Settings -----
log "[+] Hardening memory settings..."
grep -qF "tmpfs /run/shm tmpfs defaults,noexec,nosuid" /etc/fstab || echo "tmpfs /run/shm tmpfs defaults,noexec,nosuid 0 0" | sudo tee -a /etc/fstab
grep -qF "kernel.randomize_va_space" /etc/sysctl.conf || echo "kernel.randomize_va_space = 2" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

log "[!] REMINDER: Submit password change request for FTP & SSH users."
log "[+] CentOS hardening complete. Reboot recommended."
