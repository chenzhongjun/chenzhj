 #! /bin/bash

 ########################################
 #        Back up of Redmine            #
 #                                      #                  
 #        By: Zhongjun CHEN             #
 #  Contact: zhongjun@it-consultis.com  #
 #                                      #
 #     ALL RIGHTS RESERVED BY ITC       #
 ########################################


 CURRENT_TIME=`date +%Y-%m-%d-%H:%M:%S`
 [ ! -d $HOME/Redmine ] && mkdir -p $HOME/Redmine; chmod 777 $HOME/Redmine
 echo $BACKFUPFILE_PATH
 HOSTNAME=`hostname`
 MAIL_TO="zhongjun@it-consultis.com"
 MAIL_FROM="${HOSTNAME}@it-consultis.com"
 USER_MYSQL="root"
 PASSWD_MYSQL="zhongjun"
 DATABASE_NAME="test"
 SCRIPT_LOG=$HOME/Redmine/Redmine_backup-${CURRENT_TIME}.log
 echo "$SCRIPT_LOG"
 FLAG=`find $HOME/Redmine -mtime +30 | head -1`
 echo "Flag is: $FLAG" 
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
 
 if [ $FLAG ]; then
     echo "## Lots of files to delete ##"
     find $HOME/Redmine -mtime +30 -exec rm {} \;
     if [ "$?" != "0" ]; then
         echo "##Delete old files failed, notify SA##"
         echo "Delete files failed on $HOSTNAME on $CURRENT_TIME" | mail -s "Redmine backup fail Notification" $MAIL_TO
     else
         echo "##Delete old files success##"
     fi
 else
     echo "##No old files Exsits! ##"
 fi
 
 
 ) | tee $SCRIPT_LOG


