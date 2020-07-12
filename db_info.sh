USER=db_user
PASS=dbuser@123
HOST=192.168.1.100
MYSQL="-u$USER -p$PASS -h$HOST"
IO=$(mysql $MYSQL -e "show slave status\G"|grep -i "Slave_IO_Running:" |awk '{print $2}')
echo $IO

#mysql -uroot -proot@123 -e "show slave status\G"|awk '{f[$1]=$2} END {print UID=f["Master_UUID:"],IO= f["Slave_IO_Running:"]}'>/var/lib/mysql-files/a.txt
#mysql -uroot -proot@123 -e" LOAD DATA INFILE '/var/lib/mysql-files/a.txt' into table zrmtest.slave fields terminated by ' ';"
#mysql -uroot -proot@123 -e "show slave status\G" | awk '{f[$1]=$2} END {print f["Slave_10_Running:"]}'
#awk'{ f[$1]=$2 }END {if (f["Slave_10_Running:"] == "Yes")
#        rslt = (f["Slave_SQL_Running:"] == "Yes" ? 3 : 2)
#    else
#        rslt = (f["Slave_SQL_Running:"] == "Yes" ? 1 : 0)
#    print rslt
#}' a.txt

#awk '{f[$1]=$2} END {print f["Slave_10_Running:"]}'  


#mysql -uroot -proot@123 -e "show slave status\G"|awk '{f[$1]=$2} END {Master_UUID=f["Master_UUID:"],Slave_IO_Running = f["Slave_IO_Running:"] print Master_UUID Slave_IO_Running}'
