###Only Sudo Access

#!/bin/bash

# Define variables
USER="rakesh"

# Enable password authentication for the specific user in SSH config
echo -e "\nMatch User $USER\nPasswordAuthentication yes" >> /etc/ssh/sshd_config

# Grant sudo privileges to the user
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers      # "ALL" ---with password root change from user or "NOPASSWD: ALL"  ---without password root change from user (any doubt check below in next script)

# Reload SSH service
systemctl reload sshd.service

echo "User $USER is now configured with sudo access and password authentication."





####USER Creation with sudo access

#!/bin/bash

# Define username and password
USER="rakesh"
PASSWORD="YourSecurePassword"  # Change this to a secure password

# Create the user if not exists
id "$USER" &>/dev/null || useradd -m -s /bin/bash "$USER"

# Set password for the user
echo "$USER:$PASSWORD" | chpasswd

# Enable password authentication for the specific user in SSH config
echo -e "\nMatch User $USER\nPasswordAuthentication yes" >> /etc/ssh/sshd_config

# Grant sudo privileges to the user
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers

# Reload SSH service
systemctl reload sshd.service

echo "User $USER created, password set, sudo access granted, and SSH configured."



####For multiple users

#!/bin/bash

# Create users, set passwords, and grant sudo access
for user in rakesh2 madhu1 sai1; do
    useradd -m -s /bin/bash "$user"
    echo "$user:$user@1234" | chpasswd
    echo "$user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    echo -e "\nMatch User $user\nPasswordAuthentication yes" >> /etc/ssh/sshd_config
done

# Reload SSH
systemctl reload sshd

echo "Users created and configured!"