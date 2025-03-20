#!/usr/bin/env bash
# =============================
# CentOS 7 Hardening Script
# =============================

# ----- 1. Create System Backup Before Changes -----
echo "[+] Creating system backup..."
sudo tar -czvf /root/pre_hardening_backup.tar.gz /etc /var/www /home

# ----- 2. Update & Upgrade System -----
echo "[+] Updating system packages..."
sudo yum -y update

# ----- 3. Remove Unnecessary Packages -----
echo "[+] Removing unnecessary packages..."
sudo yum -y remove rsh-server telnet-server xinetd

# ----- 4. Configure Firewall (Firewalld) -----
echo "[+] Configuring Firewalld..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Allow DNS (TCP/UDP 53)
sudo firewall-cmd --permanent --add-port=53/tcp
sudo firewall-cmd --permanent --add-port=53/udp

# Allow HTTP (80) and HTTPS (443) for WordPress
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Allow SSH
sudo firewall-cmd --permanent --add-service=ssh

sudo firewall-cmd --reload

# ----- 5. Secure SSH -----
echo "[+] Hardening SSH..."
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart sshd

# ----- 6. Remove Unauthorized Users -----
echo "[+] Removing unauthorized users..."
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        sudo userdel -r "$user"
    fi
done

# ----- 7. Ensure SELinux is Enforcing -----
echo "[+] Ensuring SELinux is enforcing..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1

echo "[+] CentOS 7 hardening complete. Reboot recommended."
