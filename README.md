# User Management Script

This bash script, `create_users.sh`, creates users and groups based on input from a text file. It sets up home directories, generates random passwords, logs actions, and stores passwords securely.

## Features

- Create users and groups from a text file
- Generate random passwords
- Log actions to `/var/log/user_management.log`
- Store passwords securely in `/var/secure/user_passwords.txt`

## Usage

Ensure the script has execute permissions:

```bash
chmod +x create_users.sh
```

Run the script with the input file as an argument:

```bash
sudo ./create_users.sh input_file.txt
```

## Script Details
- Creates the necessary directories and files if they do not exist.
- Sets permissions to secure the password file.
- Reads the input file line by line.
- Skips empty lines and comments.
- Creates users and assigns them to the specified groups.
- Generates random passwords and assigns them to the users.
- Logs all actions and stores passwords securely.
