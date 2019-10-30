#!/bin/bash

mysql -h 127.0.0.1 -P6032 -uadmin -padmin -e "DELETE FROM mysql_servers;"
mysql -e "DELETE FROM orchestrator.database_instance"

group=10
for id in $@
do
    mysql -h 127.0.0.1 -P6032 -uadmin -padmin \
        -e "INSERT INTO mysql_servers (hostgroup_id, hostname, port, max_replication_lag) VALUES ($group, 'node$id', 3306, 0);"
    group=11
done
mysql -h 127.0.0.1 -P6032 -uadmin -padmin -e "LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;"

/usr/local/orchestrator/orchestrator -c discover -i node$1 cli

