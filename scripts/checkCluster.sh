#!/bin/bash

HOST=$1
USER=$2
PASSWORD=$3
TYPE=$4

check_connection() {
#	mysql -h "${HOST}" -u "${USER}" --password="${PASSWORD}" -e "quit" || \
	mysql -h "${HOST}" -u "${USER}" --password="${PASSWORD}" -e "quit" 2>/dev/null
	if [ $? -eq 0 ]; then
		echo -e "SUCCESS: Connection to mysql server $HOST is success"
	else
		echo -e "ERROR: Can't connect to mysql server $HOST"
	fi
}
mysqlgalera () {
	local cmd
	cmd="${1}"
	mysql -h "${HOST}" -u "${USER}" --password="${PASSWORD}" -s -B -N -e "${cmd}" | sed -e 's/[[:space:]]\{1,\}/,/g' | cut -d"," -f2
}

mysqlslave () {
        local cmd
        cmd="${1}"
        mysql -h "${HOST}" -u "${USER}" --password="${PASSWORD}" -s -B -N -e "${cmd}"
}

slave_io_status () {
        value=$(mysqlslave "SHOW SLAVE STATUS \G;" | grep "Slave_IO_Running" | awk '{ print $2 }')
        echo -e "Slave IO Status: $value"
}

slave_sql_status () {
        value=$(mysqlslave "SHOW SLAVE STATUS \G;" | grep "Slave_SQL_Running" | awk '{ print $2 }')
        echo -e "Slave SQL Status: $value"
}

galera_cluster_status () {
	value=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_cluster_status';")
	echo -e "Galera Cluster Status: $value"
}

galera_connected () {
	value=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_connected';")
	echo -e "Galera Cconnected Status: $value"
}

galera_cluster_size () {
	value=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_cluster_size';")
	echo -e "Number of nodes connected: $value"
}

galera_thread_count () {
	value=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_thread_count';")
	echo -e  "Galera thread count: $value"
}

galera_ready () {
	value=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_ready';")
	echo -e "Galera provider is $value"
}

galera_cluster_synced () {
	node_uuid=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_local_state_uuid';")
	cluster_uuid=$(mysqlgalera "SHOW STATUS LIKE 'wsrep_cluster_state_uuid';")
	if [ "${node_uuid}" = "" ] && [ "${cluster_uuid}" = "" ];then
		echo -e "CRITICAL! Could not get UUID from node nor cluster"
	fi
	if [ "${node_uuid}" = "${cluster_uuid}" ];then
		echo -e "OK! Node synchronized with cluster"
	else
		echo -e "CRITICAL! Node not synchronized with cluster"
	fi
}

multi_cluster_status () {
	value=$(mysqlgalera "SELECT COUNT(*) FROM performance_schema.replication_group_members;")
	echo -e "MULTI MGR: Number of nodes connected: $value"
	value=$(mysqlgalera "SELECT COUNT(*) FROM performance_schema.replication_group_members where member_role='PRIMARY';")
        echo -e "MULTI MGR: Number of PRIMARY nodes connected: $value"
}

single_cluster_status () {
        value=$(mysqlgalera "SELECT COUNT(*) FROM performance_schema.replication_group_members;")
        echo -e "SINGLE MGR: Number of nodes connected: $value"
        value=$(mysqlgalera "SELECT COUNT(*) FROM performance_schema.replication_group_members where member_role='PRIMARY';")
        echo -e "SINGLE MGR: Number of PRIMARY nodes connected: $value"
        value=$(mysqlgalera "SELECT COUNT(*) FROM performance_schema.replication_group_members where member_role='SECONDARY' ;")
        echo -e "SINGLE MGR: Number of SECONDARY nodes connected: $value"
}

if [ "${TYPE}" == "PROXY" ]; then
	echo "-------- PROXYSQL - BEGIN CHECK STATUS FOR $TYPE TOPOLOGY"
	check_connection
	echo "-------- PROXYSQL - END CHECK STATUS FOR $TYPE TOPOLOGY"
fi

if [ "${TYPE}" == "slave" ]; then
	slave_io_status
	slave_sql_status
fi

if [ "${TYPE}" == "galera" ]; then
	galera_cluster_status
	galera_connected
	galera_cluster_size
	galera_thread_count
	galera_ready
	galera_cluster_synced
fi

if [ "${TYPE}" == "single" ]; then
	echo single
fi
if [ "${TYPE}" == "multi" ]; then
	multi_cluster_status
fi

exit 0;
