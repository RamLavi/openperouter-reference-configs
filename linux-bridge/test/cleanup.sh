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

# TODO: rm this workaround for NIC wont return to root netns bug
for n in ${NODE_VMS[@]}; do
    kcli ssh -i /root/.ssh/kcli $n -- bash -x <<< '\
for nic in ens4 ens5; do \
ip link show $nic && continue; \
sudo ip netns exec perouter ip link set $nic down; \
sudo ip netns exec perouter ip link set $nic netns 1; \
sudo ip link set $nic up; \
ip addr show $nic; \
done \
'
done

echo "INFO: cleanup vni br nncp"
oc patch nncp $VNI_BR_NNCP_NAME --type=json -p '[{"op":"replace","path":"/spec/desiredState/interfaces/0/state","value":"absent"}]'
oc wait nncp $VNI_BR_NNCP_NAME --for condition=Available --timeout 5m
oc delete nncp $VNI_BR_NNCP_NAME
