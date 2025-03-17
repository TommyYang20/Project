#!/usr/bin/env bash
# =============================
# harden-ubuntu.sh (for Ubuntu 22.04)
# =============================

# ----- 0. Variables -----
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
# Modify or add domain user references if these are domain accounts.

# ----- 1. Update & Upgrade -----
echo "[+] Updating apt and upgrading packages..."
sudo apt-get update -y
sudo apt-get dist-upgrade -y

# ----- 2. Remove Unnecessary Packages (example placeholders) -----
echo "[+] Removing unnecessary packages..."
sudo apt-get remove -y telnet rsh-server xinetd
sudo apt-get autoremove -y

# ----- 3. Ensure Only Authorized Local User Accounts -----
echo "[+] Removing unauthorized local accounts..."
# We'll check /etc/passwd for normal user shells.
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing user: $user"
        # Uncomment to actually remove:
        # sudo deluser --remove-home "$user"
    fi
done

# ----- 4. Configure Firewall (ufw) -----
echo "[+] Configuring ufw firewall..."
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH
sudo ufw allow 22/tcp

# Allow NTP (UDP 123)
sudo ufw allow 123/udp

# Allow FTP (vsftpd) – typically 21/tcp, plus passive ports if configured
sudo ufw allow 21/tcp
# If you set a passive port range in vsftpd.conf, allow those as well.

sudo ufw enable

# ----- 5. Hardening SSHD -----
# E.g. Disable root login, enforce key-based auth if possible
echo "[+] Hardening SSH Daemon..."
sudo sed -i 's/^PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Adjust to "no" if your domain environment allows key-based or other secure methods.

sudo systemctl restart ssh

# ----- 6. Hardening vsftpd -----
echo "[+] Hardening vsftpd..."
# Example changes in /etc/vsftpd.conf:
sudo sed -i 's/^anonymous_enable=.*/anonymous_enable=NO/' /etc/vsftpd.conf
sudo sed -i 's/^#chroot_local_user=.*/chroot_local_user=YES/' /etc/vsftpd.conf

# Make sure TLS is configured if possible
# e.g. 
# echo "ssl_enable=YES" | sudo tee -a /etc/vsftpd.conf
# echo "rsa_cert_file=/etc/ssl/certs/ssl-cert-snakeoil.pem" | sudo tee -a /etc/vsftpd.conf
# echo "rsa_private_key_file=/etc/ssl/private/ssl-cert-snakeoil.key" | sudo tee -a /etc/vsftpd.conf

sudo systemctl restart vsftpd

# ----- 7. Secure NTP (chrony or ntpd) -----
# If using ntpd or chrony, ensure it’s restricted. Example for ntpd:
# echo "restrict default nomodify nopeer noquery notrap" | sudo tee -a /etc/ntp.conf
# systemctl restart ntp

# ----- 8. Install & Configure Fail2ban (optional but helpful) -----
echo "[+] Installing and configuring fail2ban..."
sudo apt-get install -y fail2ban
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# Create a jail.local if needed
# echo "[sshd]" | sudo tee -a /etc/fail2ban/jail.local
# echo "enabled = true" | sudo tee -a /etc/fail2ban/jail.local

echo "[+] Ubuntu hardening complete. Reboot recommended."
