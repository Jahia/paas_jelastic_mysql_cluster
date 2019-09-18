#!/bin/bash

export PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin

#TODO: add checks
/usr/local/orchestrator/orchestrator -c set-read-only -i $1
/usr/local/orchestrator/orchestrator -c end-downtime -i $1
/usr/local/orchestrator/orchestrator -c ack-instance-recoveries -i $1 --reason "node is back"

