 cat dump_table.sh
PATH1='/home/dbuser/TABLE_BKUP/'
NOW1=$(date +"%Y%m%d%H%M%S")
LOGFILE=${PATH1}LOGS/backup.log
PASS=dbuser@123
DUSER=db_user
HOST1='192.168.1.101'
echo "###########${NOW1} ##############" >> ${LOGFILE}
for DB in $(mysql -u$DUSER -p$PASS -Ns -P3306 -h$HOST1 -e"show databases;" 2>/dev/null|grep -Ev "(mysql|information_schema|sys|performance_schema|ibdata157)")
do
for TB in $(mysql -u$DUSER -p$PASS -h$HOST1  -P3306 -e"use $DB;show tables;" 2>/dev/null|grep -Ev "(Tables_in_)")
do
echo "Backup of ${DB}.${TB} started at `date +"%Y-%m-%d %H:%M:%S"`" >> ${LOGFILE}
mysqldump -u$DUSER -p$PASS -P3306 -h$HOST1  --set-gtid-purged=OFF --triggers --routines --events $DB $TB 2>/dev/null|gzip>$PATH1$DB-$TB-$NOW1.sql.gz
echo "Backup of ${DB}.${TB} completed at `date +"%Y-%m-%d %H:%M:%S"`" >> ${LOGFILE}
done
done
