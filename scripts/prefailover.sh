#!/bin/bash

# Variable exposed by Orchestrator
OldMaster=$ORC_FAILED_HOST
PROXYSQL_HOST="127.0.0.1"
PROXYSQL_USER="admin"
PROXYSQL_PWD="admin"
PROXYSQL_PORT="6032"
WRITER_GROUP="10"

# stop accepting connections to old master
(
echo 'UPDATE mysql_servers SET STATUS="OFFLINE_SOFT" WHERE hostname="'"$OldMaster"'";'
echo "LOAD MYSQL SERVERS TO RUNTIME;"
) | mysql -vvv -u${PROXYSQL_USER} -p${PROXYSQL_PWD} -h ${PROXYSQL_HOST} -P${PROXYSQL_PORT}

# wait while connections are still active and we are in the grace period
CONNUSED=`mysql -u${PROXYSQL_USER} -p${PROXYSQL_PWD} -h ${PROXYSQL_HOST} -P${PROXYSQL_PORT} -e 'SELECT IFNULL(SUM(ConnUsed),0) FROM stats_mysql_connection_pool WHERE status="OFFLINE_SOFT" AND srv_host="'"$OldMaster"'"' -B -N 2> /dev/null`
TRIES=0
while [ $CONNUSED -ne 0 -a $TRIES -ne 20 ]
do
  CONNUSED=`mysql -u${PROXYSQL_USER} -p${PROXYSQL_PWD} -h ${PROXYSQL_HOST} -P${PROXYSQL_PORT} -e 'SELECT IFNULL(SUM(ConnUsed),0) FROM stats_mysql_connection_pool WHERE status="OFFLINE_SOFT" AND srv_host="'"$OldMaster"'"' -B -N 2> /dev/null`
  TRIES=$(($TRIES+1))
  if [ $CONNUSED -ne "0" ]; then
    sleep 0.05
  fi
done

