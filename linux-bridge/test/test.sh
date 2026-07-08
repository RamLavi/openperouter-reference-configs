#! /bin/bash

set -e

SCRIPT_PATH=$(dirname "$(realpath "$0")")
DIR=$(dirname $SCRIPT_PATH)
source $SCRIPT_PATH/env.sh

echo "INFO: Generate workloads manifests:"
(
  export VM1_NAME=$VM1_NAME \
    VM1_IP=$VM1_IP \
    VM2_NAME=$VM2_NAME \
    VM2_IP=$VM2_IP \
    VMS_GW=$VMS_GW \
    SSH_PUBLIC_KEY="$(base64 $VMS_PUBLIC_KEY -w 20000)"
  echo "\
    VM1_NAME=$VM1_NAME
    VM1_IP=$VM1_IP
    VM2_NAME=$VM2_NAME
    VM2_IP=$VM2_IP
    VMS_GW=$VMS_GW
    SSH_PUBLIC_KEY=$SSH_PUBLIC_KEY"
  envsubst <<< $(cat $WORKLOADS_TEMPLATE) > $WORKLOADS_MANIFEST
)

echo "INFO: Create test namespace"
oc create ns $TEST_NS ||:
echo "INFO: Create linux-bridge NAD"
oc -n $TEST_NS apply -f ${DIR}/03-linux-bridge-nad.yaml
echo "INFO: Create test workloads"
oc -n $TEST_NS apply -f ${DIR}/04-workloads.yaml

echo "INFO: Waiting for VM readiness"
oc -n $TEST_NS wait vmi/$VM1_NAME --for condition=AgentConnected --timeout 10m
oc -n $TEST_NS wait vmi/$VM2_NAME --for condition=AgentConnected --timeout 10m

# its safe to expect for single IP address because VM is connected to single network
VM1_IP=$(oc -n $TEST_NS get vmi $VM1_NAME -o jsonpath='{.status.interfaces[*].ipAddress}')

podman exec $EXT_APP_NAME ping -c 3 -W 2 $VM1_IP ||
  (echo "FAIL: no connectivity from [external client] to VM [$VM1_NAME]")
