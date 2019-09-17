#!/bin/bash

DEAD_NODE=$ORC_FAILED_HOST
AVAILABLE_NODE=$ORC_REPLICA_HOSTS
EVENT=$ORC_FAILURE_TYPE
echo "------------------------------------------------------------------------"
echo "received $EVENT event"

echo "-------"

echo "ORC_FAILURE_TYPE                      $ORC_FAILURE_TYPE"
echo "ORC_FAILURE_DESCRIPTION               $ORC_FAILURE_DESCRIPTION"
echo "ORC_FAILED_HOST                       $ORC_FAILED_HOST"
echo "ORC_FAILED_PORT                       $ORC_FAILED_PORT"
echo "ORC_FAILURE_CLUSTER                   $ORC_FAILURE_CLUSTER"
echo "ORC_FAILURE_CLUSTER_ALIAS             $ORC_FAILURE_CLUSTER_ALIAS"
echo "ORC_FAILURE_CLUSTER_DOMAIN            $ORC_FAILURE_CLUSTER_DOMAIN"
echo "ORC_COUNT_REPLICAS                    $ORC_COUNT_REPLICAS"
echo "ORC_IS_DOWNTIMED                      $ORC_IS_DOWNTIMED"
echo "ORC_AUTO_MASTER_RECOVERY              $ORC_AUTO_MASTER_RECOVERY"
echo "ORC_AUTO_INTERMEDIATE_MASTER_RECOVERY $ORC_AUTO_INTERMEDIATE_MASTER_RECOVERY"
echo "ORC_ORCHESTRATOR_HOST                 $ORC_ORCHESTRATOR_HOST"
echo "ORC_IS_SUCCESSFUL                     $ORC_IS_SUCCESSFUL"
echo "ORC_LOST_REPLICAS                     $ORC_LOST_REPLICAS"
echo "ORC_REPLICA_HOSTS                     $ORC_REPLICA_HOSTS"
echo "ORC_COMMAND                           $ORC_COMMAND "
echo "ORC_SUCCESSOR_HOST                    $ORC_SUCCESSOR_HOST"
echo "ORC_SUCCESSOR_PORT                    $ORC_SUCCESSOR_PORT"
echo "ORC_SUCCESSOR_ALIAS                   $ORC_SUCCESSOR_ALIAS"



#if [[ $EVENT -eq "DeadCoMaster" ]]; then
#    echo "ensure $DEAD_NODE is in read only"
#    /usr/local/orchestrator/orchestrator -c set-read-only -i $DEAD_NODE
#    echo "setting $AVAILABLE_NODE writable"
#    /usr/local/orchestrator/orchestrator -c set-writable -i $AVAILABLE_NODE
#fi

