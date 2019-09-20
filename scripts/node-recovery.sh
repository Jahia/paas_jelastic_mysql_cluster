#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

if [ "$1" != "-n" ] || [ $# -ne 2 ];then
    echo "usage: node-recovery -n nodeXXXX"
    exit 1
fi

NODE_ID="$2"
LOG_FILE=/var/log/orchestrator



# Get how many nodes are currently downtimed and are not in read only or the node we are trying to recover
downtimed=$(/usr/local/orchestrator/orchestrator -c topology -i $NODE_ID|grep -v -e downtimed -e ",ro," -e "$NODE_ID"|wc -l)
if [[ $downtimed -ne 0 ]]; then # set in read only if there is already online nodes (which are not in downtime)
    echo "Set $NODE_ID to read-only" >> $LOG_FILE
    /usr/local/orchestrator/orchestrator -c set-read-only -i $NODE_ID 2>> $LOG_FILE
fi
echo "End $NODE_ID downtime" >> $LOG_FILE
/usr/local/orchestrator/orchestrator -c end-downtime -i $NODE_ID 2>> $LOG_FILE
echo "Ack $NODE_ID recovery" >> $LOG_FILE
# Ack node recovery. If not done, next down events about this node won't be triggered
/usr/local/orchestrator/orchestrator -c ack-instance-recoveries -i $NODE_ID --reason "node is back" 2>> $LOG_FILE

