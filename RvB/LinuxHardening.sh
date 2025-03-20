#!/usr/bin/env bash
# =============================
# Ubuntu 22.04 Hardening Script
# =============================

# ----- 1. Update & Upgrade -----
echo "[+] Updating system..."
sudo apt-get update -y
sudo apt-get dist-upgrade -y

# ----- 2. Remove Unnecessary Packages -----
echo "[+] Removing unnecessary packages..."
sudo apt-get remove -y telnet rsh-server xinetd
sudo apt-get autoremove -y

# ----- 3. Configure Firewall (UFW) -----
echo "[+] Configuring UFW..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 443/tcp  # HTTPS
sudo ufw allow 53/udp   # DNS
sudo ufw allow 123/udp  # NTP
sudo ufw allow from 10.10.0.0/16 to any port 22  # Restrict SSH
sudo ufw allow from 10.10.0.0/16 to any port 21  # Restrict FTP
sudo ufw enable

# Reload and Verify Firewall Rules
echo "[+] Reloading UFW and verifying status..."
sudo ufw reload
sudo ufw status verbose

# ----- 4. Secure SSH -----
echo "[+] Hardening SSH..."
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh

# ----- 5. Secure FTP (vsftpd) -----
echo "[+] Hardening vsftpd..."
sudo sed -i 's/^anonymous_enable=.*/anonymous_enable=NO/' /etc/vsftpd.conf
sudo sed -i 's/^#chroot_local_user=.*/chroot_local_user=YES/' /etc/vsftpd.conf
sudo systemctl restart vsftpd

# ----- 6. Remove Unauthorized Users -----
echo "[+] Removing unauthorized users..."
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        sudo deluser --remove-home "$user"
    fi
done

echo "[+] Ubuntu hardening complete. Reboot recommended."
