# User Management Script

This script automates the process of creating and managing users and groups on a Linux system. It reads user information from a specified input file, validates the usernames and group names, creates users and groups if they do not already exist, assigns users to the specified groups, and logs all actions performed.

## Table of Contents

- [User Management Script](#user-management-script)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Usage](#usage)
  - [File Formats](#file-formats)
    - [Input File (`users_info.txt`)](#input-file-users_infotxt)
    - [Log File (`/var/log/user_management.log`)](#log-file-varloguser_managementlog)
    - [Password File (`/var/secure/user_passwords.txt`)](#password-file-varsecureuser_passwordstxt)
    - [Verification](#verification)
  - [Logging](#logging)
  - [Permissions](#permissions)
  - [Troubleshooting](#troubleshooting)

## Features

- Validates usernames and group names to ensure they meet system requirements.
- Checks if users and groups already exist to avoid duplicates.
- Creates new users and groups if they do not exist.
- Assigns users to specified groups.
- Generates secure random passwords for new users.
- Logs all actions performed for auditing purposes.
- Maintains a secure file with user credentials.

## Prerequisites

- A Linux-based system with `sudo` privileges.
- `openssl` installed for password generation.
- The script must be executed with sufficient permissions to create users, groups, and modify system files.

## Installation

1. Clone the repository or download the script file.
2. Ensure the script has execute permissions:
   ```bash
   chmod +x create_users.sh
   ```

## Usage

1. Prepare the `users_info.txt` file with the following format:
   ```
   username;group1,group2,group3
   john_doe;admin,developers
   jane_smith;staff,guests
   ```
2. Run the script with the input file as an argument:
   ```bash
   ./create_users.sh users_info.txt
   ```
3. Upon successful execution, the script will output a message indicating completion and the location of the log file.

## File Formats

### Input File (`users_info.txt`)

- Each line represents a user and their associated groups, separated by a semicolon (`;`).
- Example:
  ```
  john_doe;admin,developers
  jane_smith;staff,guests
  ```

### Log File (`/var/log/user_management.log`)

- Contains timestamped logs of all actions performed by the script.
- Example:
  ```
  [2024-07-01 12:00:00] Successfully Created User: john_doe
  [2024-07-01 12:00:01] Successfully created group: admin
  ```

### Password File (`/var/secure/user_passwords.txt`)

- Stores usernames and their generated passwords.
- Example:
  ```
  john_doe,randomPassword123
  jane_smith,anotherRandomPassword456
  ```

### Verification

1. Check the Log File `/var/log/user_management.log`

```sh
sudo cat /var/log/user_management.log
```

2. Verify User Creation

```sh
getent passwd <username>
```

3. Alternatively, you can list all users to see if the new users are included:

```sh
cut -d: -f1 /etc/passwd
```

4. Verify Group Creation and Membership

```sh
getent group <groupname>
groups <username>
```

5. Check the Passwords File `(/var/secure/user_passwords.txt)`

```sh
sudo cat /var/secure/user_passwords.txt
```

6. Verify that this file contains the correct entries:

```sh
sudo cat /var/secure/user_passwords.txt
```

7. Check Permissions and Ownership

```sh
ls -ld /home/<username>
```

8. Test Login with the Generated Password

```sh
su - <username>
```

## Logging

- All actions are logged to `/var/log/user_management.log`.
- Ensure the log file exists and has the appropriate permissions for the script to write to it.
- Logs are appended with a timestamp for each action.

## Permissions

- The script must be run with `sudo` to have the necessary permissions to create users and groups.
- The password file `/var/secure/user_passwords.txt` is created with restricted permissions (`600`) to ensure security.

## Troubleshooting

1. **File Not Found Error**:
   - Ensure the input file (`users_info.txt`) is in the correct location and specified correctly when running the script.
2. **Permission Denied Error**:
   - Run the script with `sudo` to ensure it has the necessary permissions.
3. **User or Group Already Exists**:
   - The script will log these occurrences and skip creating duplicate users or groups.
