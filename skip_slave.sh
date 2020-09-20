#/bin/sh/
   ENKEY=`cat /home/dbuser/script/key.support | base64 2>/dev/null`
   ID=$1
   if [ -z $ID ]
   then
   echo -e '\E[35m' "ID Should not be Balnk"
   else
   MYSQLKEY="mysql -ubkup -pbkup -h192.168.1.101 -Dzrmtest -Ns -e"
   UA=`$MYSQLKEY "call sp_fetchucode('$ENKEY','$ID');" 2>/dev/null`
   PA=`$MYSQLKEY "call sp_fetchvcode('$ENKEY','$ID');" 2>/dev/null`
   HOST=`$MYSQLKEY "select ip from zrmtest.db where ipid=$ID" 2>/dev/null`
   i=1
   while(i==1)
   do
   clear
   REP=`mysql -u$UA -p$PA -h$HOST -e"show slave status\G" 2>/dev/null`
   M=`echo "$REP"| grep "Master_UUID" | awk 'BEGIN{FS=":"}{print $2}'`
   GTID=`echo "$REP"|grep -A3 Retrieved_Gtid_Set:` #|cut -d: -f1 # awk 'BEGIN{FS=":"}{print $1}'
   G1=`echo $GTID|awk 'BEGIN{FS=":"}{print $2}'`
   #G2=`echo $GTID|awk '{print $2}'`
   RGTID=`echo "$REP"|grep -A3 Retrieved_Gtid_Set:|rev|cut -d- -f1|rev|cut -d, -f1`
   #echo "$M  $G1"
   SBM=`echo "$REP"|grep -i Seconds_Behind_Master:|awk '{print $2}'`
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

   echo -e '\E[36m' "RGTID1    EGTID1     RGTID2   EGTID2              SBM$ID   SQL   IO    SQLE"
   echo -e '\E[34m' "$RG1      $EG1        $RG2    $EG2                 $SBM   $SQL   $IO  \E[33m$SQLE"
#   echo "$RG1  $EG1                      $RG2    $EG2"
   if [ -z "$SQLE" ];
   then
   break
   else
  # break

   if [ "$RG1">"$EG1" ]; then
   NG1=`echo $EG1 +1 | bc`
   GTID_NEXT1=${G1}:${NG1}
#   echo "GTID_NEXT1 = $GTID_NEXT1"
   fi
   if [ "$RG2">"$EG2" ]; then
   NG2=`echo $EG2 + 1 | bc`
   MGTID=${M}:${NG2}
#   echo "Master_gtid = $MGTID"
   fi
#   echo "GTID_NEXT1 = $GTID_NEXT1     Master_gtid = $MGTID"
#   mysql -u$UA -p$PA -h$HOST -e"stop slave;SET GTID_NEXT='$MGTID';BEGIN;COMMIT;SET GTID_NEXT='AUTOMATIC'; start slave;" 2>/dev/null
  mysql -u$UA -p$PA -h$HOST -e"stop slave;SET GTID_NEXT='$GTID_NEXT1';BEGIN;COMMIT;SET GTID_NEXT='AUTOMATIC'; start slave;" 2>/dev/nul
   break
   fi

   PROGRESS="";
   for i in {1..26}
   do
        PROGRESS=${PROGRESS}."."
        echo -ne "$PROGRESS\r"
        sleep 0.1;
   done  # FOR LOOP CLOSE
   done  # WHILE LOOP CLOSE
   fi

