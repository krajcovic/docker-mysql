#!/bin/bash

set -e

TIMEOUT=30

#docker stop $(docker ps -a -q -f name=mysql56)
#docker rm $(docker ps -a -q -f name=mysql56)

echo "=> Building mysql  image"
docker build -t krajcovic/mysql .

echo "=> Testing if mysql is running on MariaDB $TIMEOUT"
docker run -d -p 23306:3306 -e MYSQL_USER="user" -e MYSQL_PASS="test" --name mysql56running krajcovic/mysql; sleep $TIMEOUT
mysqladmin -uuser -ptest -h127.0.0.1 -P23306 ping | grep -c "mysqld is alive"

echo "=> Testing replication on mysql MariaDB $TIMEOUT"
docker run -d -e MYSQL_USER=user -e MYSQL_PASS=test -e REPLICATION_MASTER=true -e REPLICATION_USER=repl -e REPLICATION_PASS=repl -p 23307:3306 --name mysql56master krajcovic/mysql; sleep $TIMEOUT
docker run -d -e MYSQL_USER=user -e MYSQL_PASS=test -e REPLICATION_SLAVE=true -e MYSQL_PORT_3306_TCP_ADDR=172.17.0.1 -e MYSQL_PORT_3306_TCP_PORT=23307 -p 23308:3306 --name mysql56slave --link mysql56master krajcovic/mysql; sleep $TIMEOUT
docker logs mysql56master | grep "repl:repl"
mysql -uuser -ptest -h127.0.0.1 -P23307 -e "show master status\G;" | grep "mysql-bin.*"
mysql -uuser -ptest -h127.0.0.1 -P23308 -e "show slave status\G;" | grep "Slave_IO_Running.*Yes"
mysql -uuser -ptest -h127.0.0.1 -P23308 -e "show slave status\G;" | grep "Slave_SQL_Running.*Yes"

echo "=> Testing volume on mysql MariaDB"
mkdir vol56
docker run --name mysql56.1 -d -p 23309:3306 -e MYSQL_USER="user" -e MYSQL_PASS="test" -v $(pwd)/vol56:/var/lib/mysql krajcovic/mysql; sleep $TIMEOUT
mysqladmin -uuser -ptest -h127.0.0.1 -P23309 ping | grep -c "mysqld is alive"
docker stop mysql56.1
docker run  -d -p 23310:3306 -v $(pwd)/vol56:/var/lib/mysql krajcovic/mysql; sleep $TIMEOUT
mysqladmin -uuser -ptest -h127.0.0.1 -P23310 ping | grep -c "mysqld is alive"

echo "=>Done"