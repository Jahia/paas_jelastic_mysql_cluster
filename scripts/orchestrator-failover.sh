#!/bin/bash

DEAD_NODE=$ORC_FAILED_HOST
AVAILABLE_NODE=$ORC_REPLICA_HOSTS
EVENT=$ORC_FAILURE_TYPE
LOG_FILE=/var/log/orchestrator

time=$(date +"%d-%m-%y %T")

echo "$time received $EVENT event" >> $LOG_FILE
if [[ $EVENT -eq "DeadCoMaster" ]]; then
    echo "$time setting downtime on $DEAD_NODE" >> $LOG_FILE
    /usr/local/orchestrator/orchestrator -c begin-downtime -i $DEAD_NODE --reason "host down" --duration=6w 2>> $LOG_FILE

    echo "$time Set $AVAILABLE_NODE writeable" >> $LOG_FILE
    /usr/local/orchestrator/orchestrator -c set-writeable -i $AVAILABLE_NODE 2>> $LOG_FILE
fi

