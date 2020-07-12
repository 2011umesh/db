USER=db_user
PASS=dbuser@123
#sh /home/dbuser/script/rep.sh
mysql -u$USER -p$PASS -Dzrmtest -h 192.168.1.102 -e"call zrmtest.sp_moniter();"
sleep 3
