#! /bin/bash

set -e

SCRIPT_PATH=$(dirname "$(realpath "$0")")
DIR=$(dirname $SCRIPT_PATH)
source $SCRIPT_PATH/env.sh

echo "INFO: Create test namespace"
oc create ns $TEST_NS ||:
echo "INFO: Create linux-bridge NAD"
oc -n $TEST_NS apply -f ${DIR}/03-linux-bridge-nad.yaml
echo "INFO: Create test workloads"
oc -n $TEST_NS apply -f ${DIR}/04-workloads.yaml

# restart VMs to ensure NAD changes take effect
#virtctl -n $TEST_NS restart vm1
#virtctl -n $TEST_NS restart vm2
echo "INFO: Waiting for VM readiness"
oc -n $TEST_NS wait vmi/vm1 --for condition=AgentConnected --timeout 10m
oc -n $TEST_NS wait vmi/vm2 --for condition=AgentConnected --timeout 10m

# its safe to expect for single IP address because VM is connected to single network
VM1_IP=$(oc -n $TEST_NS get vmi vm1 -o jsonpath='{.status.interfaces[*].ipAddress}')

podman exec $EXT_APP_NAME ping -c 3 -W 2 $VM1_IP ||
  (echo "FATAL: no connectivity between external client and VM [vm1]" && exit 1)
