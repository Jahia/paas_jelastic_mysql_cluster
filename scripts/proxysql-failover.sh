#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin
export ORCHESTRATOR_API="$1"

OC=/usr/local/orchestrator/orchestrator
PSQL='mysql -u admin -padmin -P6032 -h 127.0.0.1'
VER=$(date +%s)
CLUSTER=$($OC -c clusters)

for h in $($OC  -c topology -i $CLUSTER|grep downtimed|cut -d" " -f2|cut -d"-" -f1); do
  echo "Setting $h to OFFLINE_SOFT"
  $PSQL -BNe "UPDATE mysql_servers SET status = 'OFFLINE_SOFT', comment = 'proxysql-oc-helper-${VER}' WHERE hostname = '$h'"

  _status=$($PSQL -BNe "SELECT DISTINCT status FROM runtime_mysql_servers WHERE hostname = '$h'")
  if [ "x${_status}" != 'xOFFLINE_SOFT' -a "x${_status}" != 'x' ]; then
    $PSQL -BNe "LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;"
  fi
done

_sql="SELECT hostname FROM mysql_servers WHERE status = 'OFFLINE_SOFT' AND comment LIKE 'proxysql-oc-helper-%' AND comment <> 'proxysql-oc-helper-${VER}'"
for h in $($PSQL -BNe "${_sql}"); do
  echo "Setting $h back to ONLINE"
  $PSQL -BNe "UPDATE mysql_servers SET status = 'ONLINE' WHERE hostname = '$h'"
  $PSQL -BNe "LOAD MYSQL SERVERS TO RUNTIME; SAVE MYSQL SERVERS TO DISK;"
done
