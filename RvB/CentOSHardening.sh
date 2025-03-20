#!/usr/bin/env bash
# =============================
# CentOS 7 Hardening Script
# =============================

# ----- 1. Update System -----
echo "[+] Updating system..."
sudo yum -y update

# ----- 2. Remove Unnecessary Packages -----
echo "[+] Removing unnecessary packages..."
sudo yum -y remove rsh-server telnet-server xinetd

# ----- 3. Ensure SELinux is Enforcing -----
echo "[+] Ensuring SELinux is enforcing..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1

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

# ----- 6. Secure WordPress -----
echo "[+] Hardening WordPress..."
# Example: remove default themes
rm -rf /var/www/html/wp-content/themes/twentyt*

# ----- 7. Remove Unauthorized Users -----
echo "[+] Removing unauthorized users..."
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        sudo userdel -r "$user"
    fi
done

# ----- 8. Enforce Strong Passwords & Change Defaults -----
echo "[+] Updating user passwords..."
for user in "${ALLOWED_USERS[@]}"; do
    echo "$user:CyberStrikeSecure!2024" | sudo chpasswd
    sudo chage -d 0 "$user"  # Force password change on next login
done

# Secure root password
echo "[+] Changing root password..."
echo "root:CyberStrikeSecure!2024" | sudo chpasswd
sudo chage -d 0 root  # Force root password change

echo "[+] CentOS 7 hardening complete. Reboot recommended."
