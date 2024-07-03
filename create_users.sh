#!/bin/bash

# Ensure the secure directory exists
sudo mkdir -p /var/secure
sudo touch /var/secure/user_passwords.txt

LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Ensure log and password files exist
sudo touch "$LOG_FILE"
sudo touch "$PASSWORD_FILE"

# Set permissions to secure the password file
sudo chmod 600 "$PASSWORD_FILE"

while IFS=';' read -r username groups || [ -n "$username" ]; do
    # Remove whitespace from username and groups
    username=$(echo "$username" | tr -d '[:space:]')
    groups=$(echo "$groups" | tr -d '[:space:]')

    # Debugging line to understand how each line is processed
    echo "Processing: username=$username, groups=$groups"

    # Check if the line is empty or starts with a comment
    if [[ -z "$username" ]]; then
        echo "$(date) - Empty username. Skipping line." | sudo tee -a "$LOG_FILE"
        continue
    fi

    # Extract groups into an array
    IFS=',' read -ra group_array <<< "$groups"

    # Check if the user already exists
    if id "$username" &>/dev/null; then
        echo "$(date) - User '$username' already exists. Skipping creation." | sudo tee -a "$LOG_FILE"
        continue
    fi

    # Create personal group for the user if it doesn't exist
    if ! getent group "$username" &>/dev/null; then
        echo "$(date) - Creating group '$username'." | sudo tee -a "$LOG_FILE"
        sudo groupadd "$username"
    fi

    # Create additional groups if they don't exist
    for group in "${group_array[@]}"; do
        if ! getent group "$group" &>/dev/null; then
            echo "$(date) - Creating group '$group'." | sudo tee -a "$LOG_FILE"
            sudo groupadd "$group"
        fi
    done

    # Create user with home directory and assign to groups
    echo "$(date) - Creating user '$username'." | sudo tee -a "$LOG_FILE"
    sudo useradd -m -g "$username" -G "$(IFS=','; echo "${group_array[*]}")" "$username"

    # Generate a random password
    password=$(openssl rand -base64 12)

    # Set the user's password
    echo "$username:$password" | sudo chpasswd

    # Save the password to the password file
    echo "$username,$password" | sudo tee -a "$PASSWORD_FILE"

    echo "$(date) - User '$username' created and assigned to groups: ${group_array[*]}." | sudo tee -a "$LOG_FILE"
done < "$1"

echo "$(date) - Script execution completed." | sudo tee -a "$LOG_FILE"

