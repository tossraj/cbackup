#!/bin/bash

function printTable()
{
    local -r delimiter="${1}"
    local -r data="$(removeEmptyLines "${2}")"
    if [[ "${delimiter}" != '' && "$(isEmptyString "${data}")" = 'false' ]]
    then
        local -r numberOfLines="$(wc -l <<< "${data}")"
        if [[ "${numberOfLines}" -gt '0' ]]
        then
            local table=''
            local i=1
            for ((i = 1; i <= "${numberOfLines}"; i = i + 1))
            do
                local line=''
                line="$(sed "${i}q;d" <<< "${data}")"
                local numberOfColumns='0'
                numberOfColumns="$(awk -F "${delimiter}" '{print NF}' <<< "${line}")"
                if [[ "${i}" -eq '1' ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
                table="${table}\n"
                local j=1
                for ((j = 1; j <= "${numberOfColumns}"; j = j + 1))
                do
                    table="${table}$(printf '#| %s' "$(cut -d "${delimiter}" -f "${j}" <<< "${line}")")"
                done
                table="${table}#|\n"
                if [[ "${i}" -eq '1' ]] || [[ "${numberOfLines}" -gt '1' && "${i}" -eq "${numberOfLines}" ]]
                then
                    table="${table}$(printf '%s#+' "$(repeatString '#+' "${numberOfColumns}")")"
                fi
            done
            if [[ "$(isEmptyString "${table}")" = 'false' ]]
            then
                echo -e "${table}" | column -s '#' -t | awk '/^\+/{gsub(" ", "-", $0)}1'
            fi
        fi
    fi
}

function removeEmptyLines()
{
    local -r content="${1}"
    echo -e "${content}" | sed '/^\s*$/d'
}

function repeatString()
{
    local -r string="${1}"
    local -r numberToRepeat="${2}"
    if [[ "${string}" != '' && "${numberToRepeat}" =~ ^[1-9][0-9]*$ ]]
    then
        local -r result="$(printf "%${numberToRepeat}s")"
        echo -e "${result// /${string}}"
    fi
}

function isEmptyString()
{
    local -r string="${1}"
    if [[ "$(trimString "${string}")" = '' ]]
    then
        echo 'true' && return 0
    fi
    echo 'false' && return 1
}

function trimString()
{
    local -r string="${1}"
    sed 's,^[[:blank:]]*,,' <<< "${string}" | sed 's,[[:blank:]]*$,,'
}

function create_users () {
    cd /var/cpanel/users
    for user in *;
    do grep $user /etc/trueuserowners;
    grep $user /etc/userdomains; >> abc.log
    echo '────────────────────────────────────────'; done
}

#Print the help text
function helptext () {
    optin=$1
    if [[ "$optin" == "optn" ]]
    then
        tput bold
        tput setaf 1
        echo "Invalid Option!";
        tput sgr0
    fi
    
    tput bold
    tput setaf 2
        printf "\ncPanel backup Create and upload, Check, Restore from remote server:\n"
        printf "\tcbackup [option...] << username >> [option-2...]\n\n"
        printf "Options controlling type:\n"
    printf -- "\t-a username                   Backup single cPanel user\n"
        printf -- "\t--all                         Backup all cPanel users\n"
    printf -- "\t-a username --check           Check all backup list from remote\n"
    printf -- "\t-a username --restore path    Restore backup with remote path (Ex: /disk/hostname/date/file.tar.gz) \n"
    printf -- "\t-a username --download path   Download backup with remote path (Ex: /disk/hostname/date/file.tar.gz) \n"
        printf -- "\t-h                            Show Help\n"
        printf -- "\t--help                        Show Help\n"
        printf "Options extra:\n"
        printf -- "\t-h, --help                    Show help\n"
    tput sgr0
    exit 0
}

function getusername () {
    path=$1
    tput bold
    tput setaf 12
    echo $path
    tput sgr0
}

function getcbackupconfdata () {
    FIND=$1
    value_of_prop1=`grep $FIND /etc/cbackup/cbackup.conf| cut -f2 -d "=" | cut -f2 -d ">"`
    echo $value_of_prop1;
}

source /etc/cbackup/cbackup.conf
HOSTNAME=$(hostname -f)
VERSION="0.1.0";
HOST=$remotehost;
USER=$remoteuser;
PASS=$psswd;
PORT=$port;
RCPT=$recipient;
RPTH=$remotepath;
LDTE=$(date +"%Y-%m-%d");
LLOG="/var/log/cbackup/cbackup-"$LDTE"-move.log";
SITO=$USER"@"$HOST":"$RPTH;
month=$(date +%d-%m-20%y);
SCSL="/var/log/cbackup/success-CPANEL-"$LDTE"-user.log";
MYSQLSCSL="/var/log/cbackup/success-MYSQL-"$LDTE".log";

function totalcount () {
    cd /var/cpanel/users
    COUNT=$(ls | wc -l);
    echo $COUNT
}

if [[ $1 == "--all" ]];
then
    CNT=$(totalcount);
elif [[ $1 == "-a" ]];
then
    CNT="1";
elif [[ $1 == * ]];
then
    CNT="0";
fi

function userbackup () {
    usr=$1
    COUNTER=$((COUNTER));
    if [ ! -f abc.txt ]; then touch $SCSL $LLOG; else echo 'exists'; fi
    if grep -q "success cpmove-"$usr".tar.gz" /var/log/cbackup/success-*;
    then
        tput bold
        tput setaf 2
        echo "("$((COUNTER++))"/"$CNT")" $(getusername $usr) cPanel backup already exists ...
        tput sgr0
    else
        rm -rf /$HOSTNAME/*;
        mkdir -p /$HOSTNAME/$month;
        if [[ "$HOST" == "localhost" ]] || [[ "$HOST" == "127.0.0.1" ]]
        then            
            /scripts/pkgacct $usr $RPTH/$HOSTNAME/$month;
        else
            /scripts/pkgacct $usr /$HOSTNAME/$month;
            # ls -l --block-size=M /$HOSTNAME/$month/;
            echo $(date +"[%Y-%m-%d %T %z]")" The backup is ready to be uploaded..."
            echo $(date +"[%Y-%m-%d %T %z]")" Backup upload process in progress..."
        fi
        if [[ "$HOST" == "localhost" ]] || [[ "$HOST" == "127.0.0.1" ]]
        then
            cp -R /$HOSTNAME $RPTH;
            echo $(date +"[%Y-%m-%d %T %z]")" Backup file has been successfully created at the given path..."
        else
            sshpass -p $PASS scp -r /$HOSTNAME $SITO;
            echo $(date +"[%Y-%m-%d %T %z]")" Backup file uploaded successfully..."
        fi
        tput bold
        tput setaf 2
        echo "("$((COUNTER++))"/"$CNT")" $(getusername $usr) cPanel backup created successfully...
        tput sgr0
        if [[ $(ls /$HOSTNAME/$month/) == *.tar.gz ]];
        then
            sTYP="Backup success"
        else
            sTYP="Backup ..ERROR"
        fi
        echo $(date +"[%Y-%m-%d %T %z]") $sTYP $(ls /$HOSTNAME/$month/) >> $SCSL;
    fi
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
}

#Parses all users through cPanel's users file
function all () {
    tput bold
    tput setaf 12
    echo "Please wait Searching cPanel accounts ....."
    tput sgr0
    tput bold
    tput setaf 12
    echo "Found "$CNT" cPanel users" .....
    echo "Creating user domain profile ....."
    if [ ! -f /$HOSTNAME/$month/user-domain-profile-$month.txt ]; then mkdir -p /$HOSTNAME/$month/ && touch /$HOSTNAME/$month/user-domain-profile-$month.txt; fi
    create_users &>> /$HOSTNAME/$month/user-domain-profile-$month.txt;
    echo "User domain profile created successfully ....."
    sshpass -p $PASS scp -r /$HOSTNAME $SITO;
    echo "User domain profile uploaded successfully ....."
    echo "backup process start ....."
    echo "For trace log : "$LLOG
    tput sgr0
    if [[ $(wget -q -t 1 --spider --dns-timeout 3 --connect-timeout 10  $HOST:$PORT; echo $?) -eq 0 ]];
    then
        echo -e "cPanel User Backup...\nThe backup process is running for all cPanel users at "$HOSTNAME" ...\nIf you want to see runningprocess\n\nTry this cmd on shell \n---------------------------------------------------------------\ntail -f "$LLOG"\n---------------------------------------------------------------\n\nAn email will come shortly after the backup is complete\nPlease wait for the next update...\nIf you do not get the next mail after log time then,\nyou can trace running process or leave a mail toe shiv@onliveinfotech.com\n\nOnlive Server auto backup program v"$VERSION | mail -s "Auto backup start..." $RCPT;
        cd /var/cpanel/users
        for users in *
        do
            userbackup $users
        done
        echo -e "cPnael user backup\nThe backup process is now complete on "$HOSTNAME"\nYou can see the log which is attached in the mail\nFor get success log\n\nTry this cmd on shell \n---------------------------------------------------------------\nless "$SCSL"\n---------------------------------------------------------------\n\nOnlive Server backup system v"$VERSION | mail -s "Auto backup done..." $RCPT;
    else
        echo -e "[Error] The backup process failed due to a network error... \nExiting..."
        echo -e "cPanel User Backup...\nThe backup process failed due to a network error... "$HOSTNAME" ...\n\nOnlive Server auto backup program v"$VERSION | mail -s "Auto backup start..." $RCPT;
        exit 0
    fi
}

function check() {
    tput bold
    tput setaf 12
    echo "Please wait connecting to backup server ....."
    tput sgr0
    tput bold
    tput setaf 12
    echo "Searching ... backup of "$1"" .....
    tput sgr0
    ussr=$1;
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - ;
    printTable ' ' "$(echo "SIZE DATE PATH\n"; sshpass -p $PASS ssh $USER"@"$HOST 'find / -type f -name "cpmove-'$ussr'.tar.gz" -exec ls -l --block-size="M" --full-time --sort="time" {} \;' |  awk '{print $5,$6,$9}')";
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - ;
}

function restore() {
    tput bold
    tput setaf 12
    echo "Please wait connecting to backup server ....."
    echo "Backup is downloading from backup server ....."
    tput sgr0
    bkppath=$1;
    usrname=$2;
    sshpass -p $PASS scp $USER"@"$HOST":"$bkppath .;
    tput bold
    tput setaf 12
    echo "Backup downloaded successfully ....."
    echo "Starting restoration ....."
    tput sgr0
    /scripts/restorepkg --force $usrname ./$(basename "${bkppath%*}");
    rm -f ./$(basename "${bkppath%*}");
}

function download() {
    tput bold
    tput setaf 12
    echo "Please wait connecting to backup server ....."
    echo "Backup is downloading from backup server ....."
    tput sgr0
    bkppath=$1;
    usrname=$2;
    sshpass -p $PASS scp $USER"@"$HOST":"$bkppath .;
    tput bold
    tput setaf 12
    echo "Backup downloaded successfully ....."
    tput sgr0
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - ;
    ls -l | grep "$(basename "${bkppath%*}")";
}

function search () {
    tput bold
    tput setaf 12
    echo "Please wait connecting to backup server ....."
    echo "Your keyword is searching from backup server ....."
    tput sgr0
    key=$1;
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - ;
    sshpass -p $PASS ssh $USER"@"$HOST 'find / -type f -name "user-domain-profile-*.txt" -exec cat {} \; | grep "'$key'" | sort --unique';
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' - ;
}

function mysql_user_export_log () {
    username=$1; filename=$2; dirname=$3;
    if [ -f "$dirname/$filename" ];
    then
        sTYP="MYSQL Backup success for "$username": "$filename;
    else
        sTYP="MYSQL Backup ..ERROR for "$username": "$filename;
    fi
    echo $(date +"[%Y-%m-%d %T %z]") $sTYP >> $MYSQLSCSL;
}

function mysql_user_db () {
    usr=$1
    if [[ ! -f $MYSQLSCSL ]]; then touch $MYSQLSCSL; fi
    if [[ ! $2 == 'force' ]]; then chklog="MYSQL Backup success for "$usr; else chklog="none"; fi
    if grep -qF "$chklog" /var/log/cbackup/success-MYSQL-*;
    then
        tput bold
        tput setaf 2
        echo "("$((COUNTER++))"/"$CNT")" $(getusername $usr) "MYSQL backup already exists ..."
        tput sgr0
    else
        rm -rf /$HOSTNAME/*;
        mysqlc=$(uapi --user=$usr Mysql list_databases | grep 'database: ' | cut -d ":" -f 2 | sed 's/[[:space:]]//g' | wc -l);
        echo $(date +"[%Y-%m-%d %T %z]")" Total ("$mysqlc") databases of user "$usr" found";
        mysql=$(uapi --user=$usr Mysql list_databases | grep 'database: ' | cut -d ":" -f 2 | sed 's/[[:space:]]//g');
        if [[ "$HOST" == "localhost" ]] || [[ "$HOST" == "127.0.0.1" ]]
        then
            dirname=$RPTH/$HOSTNAME/mysql/$month/$usr;
            mkdir -p $dirname;
            for DB in $mysql; do
                mysqldump $DB > "$RPTH/$HOSTNAME/mysql/$month/$usr/$DB.sql";
                mysql_user_export_log $usr "$DB.sql" $dirname;
                echo $(date +"[%Y-%m-%d %T %z]")" Created successfully $DB.sql..."
            done
        else
            dirname=/$HOSTNAME/mysql/$month/$usr;
            mkdir -p $dirname;
            for DB in $mysql; do
                mysqldump $DB > "/$HOSTNAME/mysql/$month/$usr/$DB.sql";
                mysql_user_export_log $usr "$DB.sql" $dirname;
                echo $(date +"[%Y-%m-%d %T %z]")" Created successfully $DB.sql..."
            done
        fi
        # ls -l --block-size=M /$HOSTNAME/$month/;
        echo $(date +"[%Y-%m-%d %T %z]")" The backup is ready to be uploaded..."
        echo $(date +"[%Y-%m-%d %T %z]")" Backup upload process in progress..."
        if [[ "$HOST" == "localhost" ]] || [[ "$HOST" == "127.0.0.1" ]]
        then
            # cp -R /$HOSTNAME $RPTH;
            echo $(date +"[%Y-%m-%d %T %z]")" The backup file has been successfully generated at the given path..."
        else
            sshpass -p $PASS scp -r /$HOSTNAME $SITO;
            echo $(date +"[%Y-%m-%d %T %z]")" Backup file uploaded successfully..."
        fi
        tput bold
        tput setaf 2
        echo "("$((COUNTER++))"/"$CNT")" $(getusername $usr) "MYSQL backup for cPanel user created successfully..."
        tput sgr0
    fi
    printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -;
}

# Parses all users through cPanel's users file
function mysql_all_db () {
    frc=$1
    tput bold
    tput setaf 12
    echo "Please wait Searching databases ....."
    tput sgr0
    tput bold
    tput setaf 12
    echo "Extracting MySQL Database ....."
    echo "MYSQL backup process start ....."
    tput sgr0

    if [[ $(wget -q -t 1 --spider --dns-timeout 3 --connect-timeout 10  $HOST:$PORT; echo $?) -eq 0 ]];
    then
        echo -e "MYSQL extraction in progress...\nMYSQL extraction process is running for all cPanel users at "$HOSTNAME" ...\n---------------------------------------------------------------\ntail -f "$LLOG"\n---------------------------------------------------------------\n\nAn email will come shortly after the backup is complete\nPlease wait for the next update...\nIf you do not get the next mail after log time then,\nyou can trace running process or leave a mail toe shiv@onliveinfotech.com\n\nOnlive Server auto backup program v"$VERSION | mail -s "Auto backup start..." $RCPT;
        cd /var/cpanel/users
        for users in *
        do
            if [[ $frc == 'force' ]]
            then
                mysql_user_db $users force
            else
                mysql_user_db $users
            fi
        done
        echo -e "MYSQL extraction\nThe MYSQL backup process is now completed on "$HOSTNAME"\nYou can see the log which is attached in the mail\nFor get success log\n\nTry this cmd on shell \n---------------------------------------------------------------\nless "$MYSQLSCSL"\n---------------------------------------------------------------\n\nOnlive Server backup system v"$VERSION | mail -s "Auto backup done..." $RCPT;
    else
        echo -e "[Error] The MYSQL backup process failed due to a network error... \nExiting..."
        echo -e "MYSQL Backup process...\nThe backup process failed due to a network error... "$HOSTNAME" ...\n\nOnlive Server auto backup program v"$VERSION | mail -s "Auto backup start..." $RCPT;
        exit 0
    fi
}

#Main function, switches options passed to it
case "$1" in
    -h) helptext;;
    --help) helptext;;
    --all) 
        case "$2" in
            "") all &>> $LLOG | tail -f $LLOG;;
            --sql) 
            case "$3" in 
                "") mysql_all_db;;
                --force) mysql_all_db force;;
                *) helptext optn;;
            esac;;
            *) helptext optn;;
        esac;;    
    --search) search $2;;
    --account)
        case "$3" in
        "") userbackup "$2" &>> $LLOG | tail -f $LLOG;;
        --check) check $2;;
        --sql) 
            case "$4" in
            "") mysql_user_db $2;;
            --force) mysql_user_db $2 force;;
            *) helptext optn;;
            esac;;
        --restore) restore $4 $2;;
        --download) download $4 $2;;
        * ) helptext optn;;
        esac;;
    -a)
        case "$3" in
        "") userbackup "$2" &>> $LLOG | tail -f $LLOG;;
        --check) check $2;;
        --sql) 
            case "$4" in
            "") mysql_user_db $2;;
            --force) mysql_user_db $2 force;;
            *) helptext optn;;
            esac;;
        --restore) restore $4 $2;;
        --download) download $4 $2;;
        * ) helptext optn;;
        esac;;
    *) helptext optn;;
esac
