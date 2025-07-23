# cbackup

**cbackup** is a Bash script to manage cPanel user backups and MySQL backups.  
It can backup all users, backup a single user, backup only MySQL databases, download/restore backups, and upload them to a remote server automatically.

---

## Features

- Create full backup of all cPanel users
- Create backup for a single cPanel user
- Backup MySQL databases for all or specific users
- Automatically upload backups to remote server
- Check if backups exist remotely
- Download or restore backups from remote server
- Search user or domain in backup records

---

## Dependencies

This script requires `sshpass` to work with remote servers.

To install sshpass:

```bash
# On Debian/Ubuntu
sudo apt install sshpass

# On CentOS/RHEL
sudo yum install sshpass
````

Also make sure `mail` is installed if you want email notifications.

---

## Configuration

Before using the script, update the config file at:

```
/etc/cbackup/cbackup.conf
```

Example config:

```
remotehost=>your.remote.server
remoteuser=>your_ssh_username
psswd=>your_ssh_password
port=>22
recipient=>admin@example.com
remotepath=>/your/remote/path
```

---

## Installation

```bash
git clone https://github.com/tossraj/cbackup.git
cd cbackup
chmod +x install.sh
./install.sh
```

---

## Usage Examples

Backup a single cPanel user:

```
cbackup -a username
```

Backup all users:

```
cbackup --all
```

Check if backup exists for a user:

```
cbackup -a username --check
```

Backup MySQL for a user:

```
cbackup -a username --sql
```

Force MySQL backup for a user even if it already exists:

```
cbackup -a username --sql --force
```

Backup MySQL for all users:

```
cbackup --all --sql
```

Force MySQL backup for all users:

```
cbackup --all --sql --force
```

Download a backup file from remote:

```
cbackup -a username --download /remote/path/to/backup.tar.gz
```

Restore a backup file from remote:

```
cbackup -a username --restore /remote/path/to/backup.tar.gz
```

Search by domain or username:

```
cbackup --search example.com
```

Show help:

```
cbackup -h
```

---

## Logs

Backup logs are saved in:

* `/var/log/cbackup/cbackup-<date>-move.log`
* `/var/log/cbackup/success-CPANEL-<date>-user.log`
* `/var/log/cbackup/success-MYSQL-<date>.log`

---

## Notes

* Make sure you have connected to your remote server at least once via SSH manually to accept the SSH key.
* You can schedule this script using `cron` for automatic backups.

```

Let me know if you want a `cron` example or `install.sh` instructions included.
```
