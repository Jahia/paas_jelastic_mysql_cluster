#!/bin/bash

HOST=$1
USER=$2
PASSWORD=$3
COMMAND=""

check_connection() {
	mysql -h "${HOST}" -u "${USER}" --password="${PASSWORD}" -e "quit" || \
		echo -e "Can't connect to mysql server $HOST"
}
mysqlconnect () {
	local cmd
	cmd="${1}"
	mysql -h "${HOST}" -u "${USER}" --password="${PASSWORD}" -s -B -N -e "${cmd}" | sed -e 's/[[:space:]]\{1,\}/,/g' | cut -d"," -f2
}

galera_cluster_status () {
	value=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_cluster_status';")
	echo -e "Galera Cluster Status: $value"
}

galera_connected () {
	value=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_connected';")
	echo -e "Galera Cconnected Status: $value"
}

galera_cluster_size () {
	value=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_cluster_size';")
	echo -e "Number of nodes connected: $value"
}

galera_thread_count () {
	value=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_thread_count';")
	echo -e  "Galera thread count: $value"
}

galera_ready () {
	value=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_ready';")
	echo -e "OK! Galera provider is $value"
}

galera_cluster_synced () {
	node_uuid=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_local_state_uuid';")
	cluster_uuid=$(mysqlconnect "SHOW STATUS LIKE 'wsrep_cluster_state_uuid';")
	if [ "${node_uuid}" = "" ] && [ "${cluster_uuid}" = "" ];then
		echo -e "CRITICAL! Could not get UUID from node nor cluster"
	fi
	if [ "${node_uuid}" = "${cluster_uuid}" ];then
		echo -e "OK! Node synchronized with cluster"
	else
		echo -e "CRITICAL! Node not synchronized with cluster"
	fi
}

galera_cluster_status
galera_connected
galera_cluster_size
galera_thread_count
galera_ready
galera_cluster_synced

exit 0;
