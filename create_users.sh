#!/bin/bash

# Function to check if a user exists
user_exists() {
    local username=$1
    if getent passwd "$username" > /dev/null 2>&1; then
        return 0  # User exists
    else
        return 1  # User does not exist
    fi
}

# Function to check if a group exists
group_exists() {
    local group_name=$1
    if getent group "$group_name" > /dev/null 2>&1; then
        return 0  # Group exists
    else
        return 1  # Group does not exist
    fi
}

# Function to validate username and group name
validate_name() {
    local name=$1
    local name_type=$2  # "username" or "groupname"

    # Check if the name contains only allowed characters and starts with a letter
    if [[ ! "$name" =~ ^[a-z][a-z0-9_-]*$ ]]; then
        log_action "Error: $name_type '$name' is invalid. It must start with a lowercase letter and contain only lowercase letters, digits, hyphens, and underscores."
        return 1
    fi

    # Check if the name is no longer than 32 characters
    if [ ${#name} -gt 32 ]; then
        log_action "Error: $name_type '$name' is too long. It must be 32 characters or less."
        return 1
    fi

    return 0
}

# Function to generate a random password
generate_password() {
    openssl rand -base64 12
}

# Function to log actions to /var/log/user_management.log
log_action() {
    local log_file="/var/log/user_management.log"
    local timestamp=$(date +"%Y-%m-%d %T")
    local action="$1"
    echo "[$timestamp] $action" | sudo tee -a "$log_file" > /dev/null
}

# Check if the correct number of command line arguments is provided
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <user_info_file>"
    exit 1
fi

# Assign the file name from the command line argument
input_file=$1

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Error: File $input_file not found."
    exit 1
fi

# Check and create the log_file if it does not exist
log_file="/var/log/user_management.log"

if [ ! -f "$log_file" ]; then
    # Create the log file
    sudo touch "$log_file"
    log_action "$log_file has been created."
else
    log_action "Skipping creation of: $log_file (Already exists)"
fi

# Check and create the passwords_file if it does not exist
passwords_file="/var/secure/user_passwords.txt"

if [ ! -f "$passwords_file" ]; then
    # Create the file and set permissions
    sudo mkdir -p /var/secure/
    sudo touch "$passwords_file"
    log_action "$passwords_file has been created."
    # Set ownership permissions for passwords_file
    sudo chmod 600 "$passwords_file"
    log_action "Updated passwords_file permission to file owner"
else
    log_action "Skipping creation of: $passwords_file (Already exists)"
fi

echo "----------------------------------------"
echo "Generating Users and Groups"
echo "----------------------------------------"

# Read the file line by line and process
while IFS=';' read -r username groups; do
    # Extract the user name
    username=$(echo "$username" | xargs)

    # Validate username
    if ! validate_name "$username" "username"; then
        log_action "Invalid username: $username. Skipping."
        continue
    fi

    # Check if the user already exists
    if user_exists "$username"; then
        log_action "Skipped creation of user: $username (Already exists)"
        continue
    else
        # Generate a random password for the user
        password=$(generate_password)

        # Create the user with home directory and set password
        sudo useradd -m -s /bin/bash "$username"
        echo "$username:$password" | sudo chpasswd

        log_action "Successfully Created User: $username"
    fi

    # Ensure the user has a group with their own name, This is the default behaviour in most linux distros
    if ! group_exists "$username"; then
        sudo groupadd "$username"
        log_action "Successfully created group: $username"
        sudo usermod -aG "$username" "$username"
        log_action "User: $username added to Group: $username"
    else
        log_action "User: $username added to Group: $username"
    fi

    # Extract the groups and remove any spaces
    groups=$(echo "$groups" | tr -d ' ')

    # Split the groups by comma
    IFS=',' read -r -a group_array <<< "$groups"

    # Create the groups and add the user to each group
    for group in "${group_array[@]}"; do
        # Validate group name
        if ! validate_name "$group" "groupname"; then
            log_action "Invalid Group name: $group. Skipping Group for user $username."
            continue
        fi

        # Check if the group already exists
        if ! group_exists "$group"; then
            # Create the group if it does not exist
            sudo groupadd "$group"
            log_action "Successfully created Group: $group"
        else
            log_action "Group: $group already exists"
        fi
        # Add the user to the group
        sudo usermod -aG "$group" "$username"
    done

    # Set permissions for home directory
    sudo chmod 700 "/home/$username"
    sudo chown "$username:$username" "/home/$username"
    log_action "Updated permissions for home directory: '/home/$username' of User: $username to '$username:$username'"

    # Log the user created action
    log_action "Successfully Created user: $username with Groups: $username ${group_array[*]}"

    # Store username and password in secure file
    echo "$username,$password" | sudo tee -a "$passwords_file" > /dev/null
    log_action "Stored username and password in $passwords_file"
done < "$input_file"

# Log the script execution to standard output
echo "----------------------------------------"
echo "Script Executed Succesfully, logs have been published here: $log_file"
echo "----------------------------------------"

