#! /bin/bash

set -e

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source $SCRIPT_PATH/env.sh

echo "INFO: Build external-router container image"
(
  cd $DIR/external-router
  podman build -t $EXT_FRR_IMG -f ./Containerfile . \
    ||:
)
echo "INFO: Generate NNCP for creating linux-bridge"
(
  export \
    META_NAME=$VNI_BR_NNCP_NAME \
    L2VNI_BRIDGE=$L2VNI_BRIDGE
  echo "\
    META_NAME=$META_NAME
    L2VNI_BRIDGE=$L2VNI_BRIDGE"
  envsubst <<< $(cat $NNCP_VNI_BR_TEMPLATE) > $NNCP_VNI_BR_MANIFEST
)
echo "INFO: Generate external-router frr.conf:"
(
  export ASN=$EXT_NET_ASN \
    VRF=$EXT_NET_VRF \
    L3VNI=$EXT_NET_L3VNI \
    NEI_ASN=$CLUSTER_NET_ASN \
    NEI_CIDR=$NET1_CIDR \
    VTEP_CIDR=$EXT_NET_VTEP_CIDR
  echo "\
    ASN=$ASN
    VRF=$VRF
    L3VNI=$L3VNI
    NEI_ASN=$NEI_ASN
    NEI_CIDR=$NEI_CIDR
    VTEP_CIDR=$VTEP_CIDR"
  envsubst <<< $(cat $FRR_CONF_TEMPLATE) > $FRR_CONF
)
echo "INFO: Generate OpenPERouter VNI manifest:"
(
  export \
    VRF=$EXT_NET_VRF \
    L3VNI=$EXT_NET_L3VNI \
    L2VNI=$EXT_NET_L2VNI \
    L2VNI_GW_CIDR=$EXT_NET_L2VNI_GW_CIDR \
    L2VNI_BRIDGE=$L2VNI_BRIDGE
  echo "\
    VRF: $VRF
    L3VNI: $L3VNI
    L2VNI: $L2VNI
    L2VNI_GW_CIDR: $L2VNI_GW_CIDR
    L2VNI_BRIDGE: $L2VNI_BRIDGE"
  envsubst <<< $(cat $VNIS_TEMPLATE) > $VNIS_MANIFEST
)

echo "INFO: Expose cluster network [$NET1_CIDR] to container-runtime [$NET1_CRI_NET_NAME]"
podman network create \
    --driver macvlan \
    --opt parent=$NET1_HOST_NIC \
    --disable-dns \
    --subnet $NET1_CIDR \
    --ip-range $NET1_CRI_RANGE \
    $NET1_CRI_NET_NAME \
    ||:
echo "INFO: Expose cluster network [$NET2_CIDR] to container-runtime [$NET2_CRI_NET_NAME]"
podman network create \
    --driver macvlan \
    --opt parent=$NET2_HOST_NIC \
    --disable-dns \
    --subnet $NET2_CIDR \
    --ip-range $NET2_CRI_RANGE \
    $NET2_CRI_NET_NAME \
    ||:

echo "INFO: Create external client network [$EXT_NET_CRI_CIDR] [$EXT_NET_CRI_NET_NAME]"
podman network create \
    --driver macvlan \
    --subnet $EXT_NET_CRI_CIDR \
    $EXT_NET_CRI_NET_NAME \
    ||:

echo "INFO: Run external client container [$EXT_APP_NAME], connected to external network [$EXT_NET_CRI_NET_NAME]"
podman run --name $EXT_APP_NAME \
  --rm -d \
  --privileged\
  --network $EXT_NET_CRI_NET_NAME \
  $EXT_APP_IMG \
  netexec \
  ||:

echo "INFO: Run external router [$EXT_FRR_NAME]"
podman run --name $EXT_FRR_NAME \
  --rm -d --privileged --ulimit core=-1 \
  --volume $FRR_CONFIG:/etc/frr \
  --network $NET1_CRI_NET_NAME \
  --network $EXT_NET_CRI_NET_NAME \
  $EXT_FRR_IMG \
  ||:

# underlay manifest generation require the external router IP.
if $(podman ps $EXT_FRR_NAME 2>&1 | grep -q Up); then
  echo "FATAL: cannot generate underlay manifest, external router is not running" && exist 1
fi
EXT_FRR_IP=$(podman exec $EXT_FRR_NAME ip -4 -o addr show dev $EXT_FRR_NET1_NIC scope global | awk '{print $4}' | cut -d/ -f1)
echo "INFO: Generate OpenPERouter Underlay manifest:"
(
  export \
    CLUSTER_ASN=$CLUSTER_NET_ASN \
    NEI_ASN=$EXT_NET_ASN \
    NEI_IP=$EXT_FRR_IP \
    NICS="\"${NET1_MVLAN}\""
  echo "\
    CLUSTER_ASN=$CLUSTER_ASN
    NEI_ASN=$NEI_ASN
    NEI_IP=$NEI_IP
    NICS=$NICS"
  envsubst <<< $(cat $UNDERLAY_TEMPLATE) > $UNDERLAY_MANIFEST
)

declare -A node_ips
node_ips[$NODE0]=$NET1_MVLN_NODE0_IP
node_ips[$NODE1]=$NET1_MVLN_NODE1_IP
for node in "${!node_ips[@]}"; do
  ip="${node_ips[$node]}"
  echo "INFO: Create macvlan on node [$node] [$NET1_MVLAN] [$ip]:"
  oc -n $NAMESPACE debug node/$node  -q --image=nicolaka/netshoot -- bash -x -c "\
    hostname
    nsenter -a -t 1 ip netns exec perouter ip -br a show $NET1_MVLAN && exit 0
    ip link add link $NET1_NODE_NIC name $NET1_MVLAN type macvlan mode bridge
    ip -br a show $NET1_MVLAN
  "
done

echo "INFO: Create NNCP for creating VNI linux-bridge"
oc apply -f $NNCP_VNI_BR_MANIFEST
echo "INFO: Create underlay"
oc -n $NAMESPACE apply -f $UNDERLAY_MANIFEST

echo "INFO: Waiting for underlay settings converge.."
sleep 25

echo "INFO: Set static IP addresses for macvlan device after it was moved to per router netns.."
declare -A node_ips
node_ips[$NODE0]=$NET1_MVLN_NODE0_IP
node_ips[$NODE1]=$NET1_MVLN_NODE1_IP
for node in "${!node_ips[@]}"; do
  ip="${node_ips[$node]}"
  echo "INFO: Create macvlan on node [$node] [$NET1_MVLAN] [$ip]:"
  oc -n $NAMESPACE debug node/$node  -q --image=nicolaka/netshoot -- bash -x -c "\
    hostname
    nsenter -a -t 1 ip netns exec perouter ip -br a show $NET1_MVLAN | grep $ip && exit 0
    nsenter -a -t 1 ip netns exec perouter ip addr add $ip/$NET1_PREFIX broadcast $NET1_BRD dev $NET1_MVLAN
    nsenter -a -t 1 ip netns exec perouter ip link set dev $NET1_MVLAN up
    nsenter -a -t 1 ip netns exec perouter ip -br a show $NET1_MVLAN
  "
done

echo "INFO: Create VNIs"
oc -n $NAMESPACE apply -f $VNIS_MANIFEST

# TODO: uncomment once fix for status showing UNKNOWN bug is consumed
# oc -n $NAMESPACE wait routernodeconfigurationstatus/$NODE0 --for condition=Ready --timeout 5m
# oc -n $NAMESPACE wait routernodeconfigurationstatus/$NODE1 --for condition=Ready --timeout 5m

echo "INFO: Wait for BGP neighbor convergence.."
sleep 5
(
    set -x
    podman exec -it frr vtysh -c 'show bgp summary'
    podman exec -it frr vtysh -c 'show bgp nei'
    podman exec -it frr vtysh -c 'show bgp ipv4'
    podman exec -it frr vtysh -c 'show bgp l2vpn evpn'
) 2>&1 | tee "${SCRIPT_PATH}/setup.log"
