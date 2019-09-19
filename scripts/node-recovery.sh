#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

if [ "$1" != "-n" ] || [ $# -ne 2 ];then
    echo "usage: node-recovery -n nodeXXXX"
    exit 1
fi

NODE_ID="$2"

# Get how many nodes are currently downtimed and are not in read only or the node we are trying to recover
downtimed=$(/usr/local/orchestrator/orchestrator -c topology -i $NODE_ID|grep -v -e downtimed -e ",ro," -e "$NODE_ID"|wc -l)
if [[ $downtimed -ne 0 ]]; then # set in read only if there is already online nodes (which are not in downtime)
    /usr/local/orchestrator/orchestrator -c set-read-only -i $NODE_ID
fi
/usr/local/orchestrator/orchestrator -c end-downtime -i $NODE_ID
/usr/local/orchestrator/orchestrator -c ack-instance-recoveries -i $NODE_ID --reason "node is back"

