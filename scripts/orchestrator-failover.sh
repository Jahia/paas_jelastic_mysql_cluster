#!/bin/bash

DEAD_NODE=$ORC_FAILED_HOST
AVAILABLE_NODE=$ORC_REPLICA_HOSTS
EVENT=$ORC_FAILURE_TYPE
echo "------------------------------------------------------------------------"
echo "received $EVENT event"
if [[ $EVENT -eq "DeadCoMaster" ]]; then
    echo "setting downtime on $DEAD_NODE"
    /usr/local/orchestrator/orchestrator -c begin-downtime -i $DEAD_NODE --reason "host down"

    echo "Set $AVAILABLE_NODE writeable"
    /usr/local/orchestrator/orchestrator -c set-writeable -i $AVAILABLE_NODE
fi

