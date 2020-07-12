#mysql -udb_user -pdbuser@123 -h 192.168.1.100 -P3306 -e"insert into zrmtest.stu(name,dt) values('192.168.1.100',now());"
mysql -udb_user -pdbuser@123 -h 192.168.1.102 -P3306 -e"insert into zrmtest.u(name,dt) values('192.168.1.102',now());"
mysql -udb_user -pdbuser@123 -h 192.168.1.101 -P3306 -e"insert into zrmtest.u(name,dt) values('192.168.1.101',now());"
