#! /bin/bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source $SCRIPT_PATH/env.sh

# cleanup container-runtime
for c in ${CONTAINERS[@]}; do
    echo "INFO: rm container [$c]"
    podman stop $c
    podman rm $c
done
for n in ${CRI_NETWORKS[@]}; do
    echo "INFO: rm cri network [$n]"
    podman network rm $n
done

echo "INFO: rm openperrouter configs"
oc -n $NAMESPACE delete -f $UNDERLAY_MANIFEST
oc -n $NAMESPACE delete -f $VNIS_MANIFEST

# cleanup test namespace
oc delete ns $TEST_NS &
while oc get ns $TEST_NS &> /dev/null; do
  oc get ns test -o jsonpath='{.status}'
  echo "waiting for ns $TEST_NS to dispose.."
  sleep 3
done

echo "INFO: cleanup underlay macvlan devices"
declare -A node_ips
node_ips[$NODE0]=$NET1_MVLN_NODE0_IP
node_ips[$NODE1]=$NET1_MVLN_NODE1_IP
for node in "${!node_ips[@]}"; do
  ip="${node_ips[$node]}"
  oc -n $NAMESPACE debug node/$node  -q --image=nicolaka/netshoot -- bash -x -c "\
    hostname
    ip link del $NET1_MVLAN ||:
    ip link show $NET1_MVLAN ||:
    nsenter -a -t 1 ip netns exec perouter ip link del $NET1_MVLAN ||:
    nsenter -a -t 1 ip netns exec perouter ip link show $NET1_MVLAN ||:
  "
done
