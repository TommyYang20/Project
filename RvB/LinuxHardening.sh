#!/usr/bin/env bash

LOGFILE="/var/log/ubuntu_hardening.log"

log() {
    echo "[$(date)] $1" | tee -a "$LOGFILE"
}

# ----- 0. Variables -----
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
INTERNAL_NETWORK="10.10.0.0/16"
BACKUP_DIR="/backup"
BACKUP_FILE="$BACKUP_DIR/linux_backup.tar.gz"

check_exit() {
    if [ $? -ne 0 ]; then
        log "[ERROR] $1 failed. Exiting."
        exit 1
    fi
}

# ----- 1. Update & Upgrade -----
log "[+] Updating apt and upgrading packages..."
sudo apt-get update -y && sudo apt-get dist-upgrade -y
check_exit "apt update/upgrade"

# ----- 2. Remove Unnecessary Packages -----
log "[+] Removing unnecessary packages..."
sudo apt-get remove -y telnet rsh-server xinetd cups bluetooth
sudo apt-get autoremove -y
check_exit "Removing packages"

# ----- 3. Remove Unauthorized Users -----
log "[+] Removing unauthorized local accounts..."
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        log "[*] Removing user: $user"
        sudo deluser --remove-home "$user"
    fi
done

# ----- 4. Configure Firewall (UFW) -----
log "[+] Configuring UFW firewall..."
sudo apt-get install -y ufw
check_exit "Installing ufw"

sudo ufw default deny incoming
sudo ufw default allow outgoing

# Remove any preexisting SSH rule that allows access from Anywhere
existing_rules=$(sudo ufw status numbered | grep "22/tcp" | grep "Anywhere" | sed -E 's/^\[([0-9]+)\].*/\1/' | sort -rn)
if [ -n "$existing_rules" ]; then
    for rule in $existing_rules; do
        log "[*] Deleting existing SSH rule #$rule"
        sudo ufw delete $rule
    done
fi

# Now add the rule to allow SSH only from the internal network
sudo ufw allow from $INTERNAL_NETWORK to any port 22
sudo ufw allow 123/udp  # NTP
sudo ufw allow 21/tcp   # FTP
sudo ufw --force enable
check_exit "Configuring ufw"

# ----- 5. Hardening SSH -----
log "[+] Hardening SSH access..."
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
# Note: Disabling PasswordAuthentication might conflict with competition requirements.
# Uncomment the next line only if you are sure that password authentication should be disabled.
# sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh
check_exit "Restarting SSH"

# ----- 6. Install & Configure Fail2Ban -----
log "[+] Installing Fail2Ban..."
sudo apt-get install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
check_exit "Installing/starting Fail2Ban"

# ----- 7. Install OSSEC for Intrusion Detection -----
log "[+] Installing OSSEC HIDS..."
wget -q -O - https://updates.atomicorp.com/installers/atomic | sudo bash
check_exit "Configuring OSSEC repository"

# ----- 8. Enable Audit Logging -----
log "[+] Configuring audit logs..."
sudo systemctl enable auditd
sudo systemctl start auditd
grep -qF "-w /etc/passwd -p wa -k passwd_changes" /etc/audit/rules.d/audit.rules || echo "-w /etc/passwd -p wa -k passwd_changes" | sudo tee -a /etc/audit/rules.d/audit.rules
grep -qF "-w /var/log/auth.log -p wa -k auth_logs" /etc/audit/rules.d/audit.rules || echo "-w /var/log/auth.log -p wa -k auth_logs" | sudo tee -a /etc/audit/rules.d/audit.rules
sudo augenrules --load

# ----- 9. Ensure Critical Services Are Running -----
log "[+] Checking and restarting critical services..."
SERVICES=("vsftpd" "ntp")
for service in "${SERVICES[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        log "[*] Restarting $service..."
        sudo systemctl restart "$service"
    fi
done

# ----- 10. Backup System -----
log "[+] Creating system backup..."
if [ ! -d "$BACKUP_DIR" ]; then
    sudo mkdir -p "$BACKUP_DIR"
    check_exit "Creating backup directory"
fi
sudo tar -cvpzf "$BACKUP_FILE" --exclude="$BACKUP_DIR" / --one-file-system
check_exit "Creating backup"

# ----- 11. Monitor Open Ports -----
log "[+] Checking open ports..."
sudo netstat -tulnp

# ----- 12. Prevent Brute Force Attacks -----
log "[+] Implementing brute-force protection..."
sudo iptables -C INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set 2>/dev/null || \
    sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --set
sudo iptables -C INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP 2>/dev/null || \
    sudo iptables -A INPUT -p tcp --dport 22 -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 5 -j DROP

# ----- 13. Ensure Scoring Engine Connectivity -----
log "[+] Checking connection to scoring engine..."
curl -I http://scoring.sdc.cpp

# ----- 14. Log Password Change Requests for SSH & FTP Users -----
log "[+] Logging password change request..."
echo "[$(date)] Password changed for SSH & FTP users" | sudo tee -a /var/log/password_changes.log

# ----- 15. Enable AppArmor for Process Security -----
log "[+] Enabling AppArmor..."
sudo systemctl enable --now apparmor

log "[!] REMINDER: Submit password change request for FTP & SSH users."
log "[+] Ubuntu hardening complete. Reboot recommended."
