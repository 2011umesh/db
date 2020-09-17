#/bin/bash
mysql_user=root
mysql_pass="your password"
mysql_host=localhost
mysql_port=3306
mysql_socket=/var/lib/mysql/mysql.sock

cmd=mysql
[ -n "$mysql_host"  ] && cmd="$cmd --host=$mysql_host"
[ -n "$mysql_port"  ] && cmd="$cmd --port=$mysql_port"
[ -n "$mysql_socket"  ] && cmd="$cmd --socket=$mysql_socket"
[ -n "$mysql_user"  ] && cmd="$cmd --user=$mysql_user"
[ -n "$mysql_pass"  ] && cmd="$cmd --password=$mysql_pass"
#echo $cmd
while(true);
do
Last_SQL_Error=`$cmd -e "show slave status\G" | grep "Last_SQL_Error:" | awk 'BEGIN{FS=":"}{print $2}' | tr -d ' '`
#Last_SQL_Error=""
if [ -z "$Last_SQL_Error" ]; then
break
fi
Master_UUID=`$cmd -e "show slave status\G" | grep "Master_UUID" | awk 'BEGIN{FS=":"}{print $2}'`
Executed_Gtid_Set=`$cmd -e "show slave status\G" | grep "Executed_Gtid_Set" | grep $Master_UUID  | awk 'BEGIN{FS=" "}{print $2}'`
Executed_id_Last=`echo $Executed_Gtid_Set |  awk 'BEGIN{FS=":"}{print $NF}' |  awk 'BEGIN{FS="-"}{print $2}'`
Executed_Gtid_Last=${Master_UUID}:${Executed_id_Last}
Executed_id_Next=`echo $Executed_id_Last + 1 | bc`
GTID_NEXT=${Master_UUID}:${Executed_id_Next}
$cmd << EOF
stop slave;
SET GTID_NEXT='$GTID_NEXT';
BEGIN;
COMMIT;
SET GTID_NEXT='AUTOMATIC';
start slave;
EOF
echo $Last_SQL_Error
echo $Executed_Gtid_Set
echo $GTID_NEXT
sleep 1
done
