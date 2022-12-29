# cbackup
Manage cPanel user backup and MYSQL backup userwise
* Create all user backup
* Create backup for single user
* Create MYSQL backup for all user and for single user
* Find user databases and download and restore from remote server
* Auto upload on remote server
* find user, reseller by username and domain name

## Dependency

This plugin requires a SSHPASS script to work.

First install [SSHPASS](#) and then install this plugin and once connect menually ssh

## Installing 

```bash
git clone https://github.com/tossraj/cbackup.git
```
```bash
cd cbackup
```
```bash
chmod +x install.sh
```
```bash
./install.sh
```
## Uses

`cbackup -a cpaneluser` for backup single user.

`cbackup -a cpaneluser --check` check cPanel user backup to remote server.

`cbackup -h` or `cbackup --help` for for help or view all options.
