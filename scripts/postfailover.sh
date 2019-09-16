#!/bin/bash

OldMaster=$ORC_FAILED_HOST
NewMaster=$ORC_SUCCESSOR_HOST
PROXYSQL_HOST="127.0.0.1"
PROXYSQL_USER="admin"
PROXYSQL_PWD="admin"
PROXYSQL_PORT="6032"
WRITER_GROUP="10"

# remove old master from writers hostgroup
  (
  echo 'DELETE FROM mysql_servers WHERE hostgroup_id=10 AND hostname="'"$OldMaster"'";'
  echo 'LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;'
  ) | mysql -vvv -u${PROXYSQL_USER} -p${PROXYSQL_PWD} -h ${PROXYSQL_HOST} -P${PROXYSQL_PORT}

# promote the new master by adding to the writers hostgroup
  (
  echo 'INSERT INTO mysql_servers(hostgroup_id,hostname,port,status) values (10, "'"$NewMaster"'", 3306, "ONLINE");'
  echo 'LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;'
  ) | mysql -vvv -u${PROXYSQL_USER} -p${PROXYSQL_PWD} -h ${PROXYSQL_HOST} -P${PROXYSQL_PORT}

# if graceful then set old master ONLINE in read hostgroup and start replication
if [ "$ORC_COMMAND" == "graceful-master-takeover" ]
then
  (
  echo 'UPDATE mysql_servers SET status="ONLINE" WHERE hostgroup_id=11 AND hostname="'"$OldMaster"'";'
  echo 'LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;'
  ) | mysql -vvv -u${PROXYSQL_USER} -p${PROXYSQL_PWD} -h ${PROXYSQL_HOST} -P${PROXYSQL_PORT}

fi

