#!/usr/bin/env bash
# =============================
# harden-centos.sh (for CentOS 7)
# =============================

# ----- 1. Update and Upgrade -----
echo "[+] Updating and upgrading packages..."
sudo yum -y update

# ----- 2. Remove Unnecessary Packages (example placeholders) -----
echo "[+] Removing unnecessary packages..."
sudo yum -y remove rsh-server telnet-server xinetd

# ----- 3. Ensure SELinux is Enforcing -----
echo "[+] Ensuring SELinux is enforcing..."
sudo sed -i 's/^SELINUX=.*/SELINUX=enforcing/' /etc/selinux/config
setenforce 1

# ----- 4. Configure Firewalld (or iptables) -----
echo "[+] Configuring firewalld..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

# Default zone to drop inbound except known services
sudo firewall-cmd --set-default-zone=public

# Allow DNS (TCP/UDP 53)
sudo firewall-cmd --permanent --add-port=53/tcp
sudo firewall-cmd --permanent --add-port=53/udp

# Allow HTTP (80) and HTTPS (443) for WordPress
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Allow SSH
sudo firewall-cmd --permanent --add-service=ssh

sudo firewall-cmd --reload

# ----- 5. Hardening SSH (sshd) -----
echo "[+] Hardening SSH..."
sudo sed -i 's/^#PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
# Adjust to your domain or key-based environment if needed.

sudo systemctl restart sshd

# ----- 6. Secure DNS (BIND) Example-----
# Typically in /etc/named.conf or /etc/named/ named.conf.local
# Make sure recursion is disabled if you only serve authoritative zones:
# recursion no; 
# or use ACLs to restrict recursion to internal subnets only.

# ----- 7. Secure WordPress -----
# This is largely done at the application level:
# - Keep WP updated (core, themes, plugins).
# - Remove default "admin" user, use strong passwords.
# - Restrict wp-login.php access if possible.

# Example: remove default themes:
# rm -rf /var/www/html/wp-content/themes/twentyt*

# ----- 8. Remove Unwanted User Accounts -----
ALLOWED_USERS=("johncyberstrike" "joecyberstrike" "janecyberstrike")
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    if [[ ! " ${ALLOWED_USERS[@]} " =~ " ${user} " ]]; then
        echo "Removing unauthorized user: $user"
        # sudo userdel -r "$user"
    fi
done

echo "[+] CentOS 7 hardening script complete. A reboot is recommended."
