#! /bin/bash

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source $SCRIPT_PATH/env.sh

# cleanup container-runtime
for c in ${CONTAINERS[@]}; do
    podman stop $c
    podman rm $c
done
for n in ${CRI_NETWORKS[@]}; do
    podman network rm $n
done

# cleanup cluster
oc -n $NAMESPACE delete -f $UNDERLAY_MANIFEST
oc -n $NAMESPACE delete -f $VNIS_MANIFEST

# cleanup test namespace
oc delete ns $TEST_NS &
while oc get ns $TEST_NS &> /dev/null; do
  oc get ns test -o jsonpath='{.status}'
  echo "waiting for ns $TEST_NS to dispose.."
  sleep 3
done

# TODO: rm this workaround for NIC wont return to root netns bug
for n in ${NODE_VMS[@]}; do
    kcli ssh -i /root/.ssh/kcli $n -- bash -x <<< '\
for nic in ens4 ens5; do \
sudo ip netns exec perouter ip link set $nic down; \
sudo ip netns exec perouter ip link set $nic netns 1; \
sudo ip link set $nic up; \
ip addr show $nic; \
done \
'
done

# cleanup nncp
# oc patch nncp brvni110 --type=json -p '[{"op":"replace","path":"/spec/desiredState/interfaces/0/state","value":"absent"}]'
# oc -n $TEST_NS wait nncp/brvni110 --for condition=Available --timeout 5m
# oc delete -f $NNCP_MANIFEST
