#! /bin/bash

########################################
#        Back up of Redmine            #
#                                      #                  
#        By: Zhongjun CHEN             #
#  Contact: zhongjun@it-consultis.com  #
#                                      #
#     ALL RIGHTS RESERVED BY ITC       #
########################################


CURRENT_TIME=`date +%Y-%m_%d-%H-%M-%S`
[ ! -d $HOME/Redmine ] && mkdir -p $HOME/Redmine; chmod 777 $HOME/Redmine
HOSTNAME=`hostname`
MAIL_TO="zhongjun@it-consultis.com"
MAIL_FROM=${HOSTNAME}@it-consultis.com
USER_MYSQL="root"
PASSWD_MYSQL="zhongjun"
DATABASE_NAME="test"
SCRIPT_LOG=$HOME/Redmine/Redmine_backup-${CURRENT_TIME}.log
TEMP_FILE=`mktemp $HOME/Redmine/$$.XXXX`
find $HOME/Redmine -mtime +30 > $TEMP_FILE
TEMP_ERR=`mktemp $HOME/Redmine/$$.XXXX`

(
echo "## Begin back up Redmine ##"
mysqldump -u $USER_MYSQL -p${PASSWD_MYSQL} $DATABASE_NAME >  $HOME/Redmine/Redmine_backup-${CURRENT_TIME}.sql

if [ "$?" != "0" ]; then
    echo "##Backup Redmine Failed!##"
    echo "Backup Redmine Failed on $HOSTNAME on $CURRENT_TIME" | mail -s "Backup Redmine Failed" $MAIL_TO
else
    echo "##Backup files successul!##"
    echo 
fi

echo "Purging outdate backup files of Redmine(which backup 30 days before)"
echo 

if cat $TEMP_FILE | head -1 > /dev/null; then
    echo "## Deleting...  ##"
    while read LINE
    do
        echo "Delete file: $LINE"
        rm $HOME/Redmine/$LINE
        if [ "$?" != "0" ]; then
            echo "##Delete old files failed, notify SA##"
            echo "Delete backup file: $LINE failed" >> $TEMP_ERR
        else
            echo "##Delete old files success##"
        fi
    done < $TEMP_FILE
    echo "Send mail to Notify SA about delet files fail"
    cat $TEMP_ERR | mail -s "Redmine backup fail Notification" $MAIL_TO
else
    echo "##No old files Exsits! ##"
fi


) | tee $SCRIPT_LOG


