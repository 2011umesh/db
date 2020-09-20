#/bin/sh/
ENKEY=`cat /home/dbuser/script/key.support | base64 2>/dev/null`
#echo $ENKEY
clear
echo -e '\E[36m' "HOST            RGTID1    EGTID1     RGTID2   EGTID2    SBM      SQL  IO   SQLE"
 ID=(11 12 10)
 for I in `seq 0 2`
 do
MYSQLKEY="mysql -ubkup -pbkup -h192.168.1.101 -Dzrmtest -Ns -e"
UA=`$MYSQLKEY "call sp_fetchucode('$ENKEY','${ID[$I]}');" 2>/dev/null`
PA=`$MYSQLKEY "call sp_fetchvcode('$ENKEY','${ID[$I]}');" 2>/dev/null`
HOST=`$MYSQLKEY "select ip from zrmtest.db where ipid=${ID[$I]}" 2>/dev/null`
#echo " $HOST  $ENKEY  $UA   $PA" 1
#clear
#echo " $ENKEY  $UA   $PA"
#i=1
#while(i==1)
#do
REP=`mysql -u$UA -p$PA -h$HOST -e"show slave status\G" 2>/dev/null`
RGTID=`echo "$REP"|grep -A3 Retrieved_Gtid_Set:|rev|cut -d- -f1|rev|cut -d, -f1`
SBM=`echo "$REP"|grep -i Seconds_Behind_Master:|awk '{print $2}'`
#echo $RGTID
RG1=`echo $RGTID|awk '{print $1}'`
RG2=`echo $RGTID|awk '{print $2}'`
EG1=`echo $RGTID|awk '{print $3}'`
EG2=`echo $RGTID|awk '{print $4}'`
SQL=`echo "$REP"|grep -i Slave_SQL_Running:|awk '{print $2}'`
IO=`echo "$REP"|grep -i Slave_IO_Running:|awk '{print $2}'`
#SQLE=`echo "$REP"|grep -i Last_SQL_Error:|awk '{print $2}'`
SQLE=`echo -e '\E[37m' "$REP"|grep -i Last_SQL_Error:|awk 'BEGIN{FS=":"}{print $2}' | tr -d ' '`

   if [ "$EG2" == 'Auto_Position:' ];
   then
   EG2="NA"
   EE="$RG2"
   RG2="$EG1"
   EG1="$EE"
   fi
#echo -e '\E[36m' "RGTID1    EGTID1     RGTID2   EGTID2       SBM   SQL  IO   SQLE"
echo -e '\E[34m' "$HOST    $RG1      $EG1        $RG2       $EG2       $SBM       $SQL    $IO   \E[33m$SQLE"
done
#done
PROGRESS="";
   for i in {1..26}
   do
        PROGRESS=${PROGRESS}."."
        echo -ne "$PROGRESS\r"
        sleep 0.1;
   done
sh /home/dbuser/script/skip_slave.sh
#done
