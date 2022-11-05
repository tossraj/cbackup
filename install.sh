#!/bin/sh
HostN=$(hostname -f)

if [ -d "/$HostN/" ]; then
    echo "[OK] Backup dir updated ..."
else 
    mkdir -p /$HostN/;
fi

if [ -d "/etc/cbackup/" ]; then
    echo "[OK] Config dir updated ..."
else 
    mkdir -p /etc/cbackup/;
fi

if [ -d "/var/log/cbackup/" ]; then
    echo "[OK] Log dir updated ..."
else 
    mkdir -p /var/log/cbackup/;
fi

wget -q http://onliveinfotech.com/all-backup/cbackup.sh
chmod +x cbackup.sh
mv cbackup.sh /usr/local/bin/cbackup
echo "[OK] backup script updated ..."

if [ -f "/etc/cbackup/cbackup.conf" ]; then
    echo "[OK] Config file updated ..."
else 
    wget -q http://onliveinfotech.com/all-backup/cbackup.conf;
    mv cbackup.conf /etc/cbackup/;
fi
echo "[OK] Backup package updated successfully..."
