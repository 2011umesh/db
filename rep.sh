#!/bin/bash
RED=$(tput setaf 1)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
RST=$(tput setaf 7)
BLC=$(tput setaf 0)
 USER=db_user
 PASS=dbuser@123
 HOST=(192.168.1.102 192.168.1.101 192.168.1.100)
 for I in `seq 0 2`
 do
 #mysql -u$USER -p$PASS -e "show databases\G"
 H=${HOST[$I]}
 REP=`mysql -u$USER -p$PASS -h${HOST[$I]} -e"show slave status\G" 2> /dev/null`
 SQL=$(echo "$REP" | grep -i "Slave_SQL_Running:" |awk '{print $2}')
 IO=$(echo "$REP" | grep -i "Slave_IO_Running:" |awk '{print $2}')
 MIP=$(echo "$REP"| grep -i "Master_Host:" |awk '{print $2}')
 RDB=$(echo "$REP" | grep -i "Replicate_Do_DB:" |awk '{print $2}')
 SBM=$(echo "$REP" | grep -i "Seconds_Behind_Master:" |awk '{print $2}')
 LIE=$(echo "$REP" | grep -i "Last_IO_Error:" |awk '{print $2}')
 LSE=$(echo "$REP" | grep -i "Last_SQL_Error:" |awk '{print $2}')
 HOSTN=`mysql -u$USER -p$PASS -h${HOST[$I]} -Ns -e"select VARIABLE_VALUE from  INFORMATION_SCHEMA.GLOBAL_VARIABLES where VARIABLE_NAME='hostname';" 2> /dev/null`

 TC=`mysqladmin -u $USER -p$PASS -h${HOST[$I]} extended status 2>/dev/null | grep Threads_connected | awk '{print $4}'`
 TR=`mysqladmin -u $USER -p$PASS -h${HOST[$I]} extended status 2>/dev/null| grep Threads_running | awk '{print $4}'`
 TL=$(mysql -u $USER -p$PASS -h${HOST[$I]} -e 'show processlist' 2>/dev/null | grep -c Locked)
 THD=`mysqladmin -u$USER -p$PASS -h${HOST[$I]} ping 2>/dev/null`


 if [ "$THD" == "mysqld is alive" ];
 then
     THD="UP";
 else
     THD="DOWN";
 fi

 if [[ "$SQL" == "Yes" && "$IO" == "Yes" ]]; 
 then 
   rs="RUNNING" ;
 else 
   rs="ERROR";
 fi

 if [ "$RDB" == ' ' ];
 then
   RDB="ALL DB";
 fi
# echo "$H $HOSTN $SQL $IO $rs $MIP $RDB $THD $SBM $LIE $LSE $TC $TR $TL "
 mysql -u$USER -p$PASS -Dzrmtest -h 192.168.1.101 -e"call sp_system('$H','$HOSTN','$THD','$rs','$MIP','$RDB','$SBM','$LSE','$LIE','$TC','$TR','$TL');" 2>/dev/null
 mysql -u$USER -p$PASS -Dzrmtest -h 192.168.1.102 -e"call sp_system('$H','$HOSTN','$THD','$rs','$MIP','$RDB','$SBM','$LSE','$LIE','$TC','$TR','$TL');" 2>/dev/null 
done
#mysql -uroot -proot@123 -e "call zrmtest.sp_moniter();"
sleep 4; 
sh /home/dbuser/script/rep.sh
