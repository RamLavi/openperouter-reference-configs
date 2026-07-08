#! /bin/bash

set -e

SCRIPT_PATH=$(dirname "$(realpath "$0")")
source $SCRIPT_PATH/env.sh

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

echo "INFO: Build external-router container image"
(
  cd $DIR/external-router
  podman build -t $EXT_FRR_IMG -f ./Containerfile . \
    ||:
)
echo "INFO: Generate external-router frr.conf:"
(
  export ASN=$EXT_NET_ASN \
    VRF=$EXT_NET_VRF \
    L3VNI=$EXT_NET_L3VNI \
    NEI_CIDR=$NET1_CIDR \
    NEI_IP=$NET1_NODE0_IP \
    NEI2_IP=$NET1_NODE1_IP \
    VTEP_CIDR=$EXT_NET_VTEP_CIDR
  echo "\
    ASN=$ASN
    VRF=$VRF
    L3VNI=$L3VNI
    NEI_CIDR=$NEI_CIDR
    NEI_IP=$NEI_IP
    NEI2_IP2=$NEI2_IP2
    VTEP_CIDR=$VTEP_CIDR"
  envsubst <<< $(cat $FRR_CONF_TEMPLATE) > $FRR_CONF
)

echo "INFO: Run external router [$EXT_FRR_NAME]"
podman run --name $EXT_FRR_NAME \
  --rm -d --privileged --ulimit core=-1 \
  --volume $FRR_CONFIG:/etc/frr \
  --network $NET1_CRI_NET_NAME \
  --network $EXT_NET_CRI_NET_NAME \
  $EXT_FRR_IMG \
  ||:

echo "INFO: Generate NNCP for creating linux-bridge"
(
  export L2VNI_BRIDGE=$L2VNI_BRIDGE
  echo "L2VNI_BRIDGE=$L2VNI_BRIDGE"
  envsubst <<< $(cat $NNCP_TEMPLATE) > $NNCP_MANIFEST
)

echo "INFO: Gen VNI manifest:"
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

# underlay manifest generation require the external router IP.
if $(podman ps $EXT_FRR_NAME 2>&1 | grep -q Up); then
  echo "FATAL: cannot generate underlay manifest, external router is not running" && exist 1
fi
EXT_FRR_IP=$(podman exec $EXT_FRR_NAME ip -4 -o addr show dev $EXT_FRR_NET1_NIC scope global | awk '{print $4}' | cut -d/ -f1)
echo "INFO: Generate underlay manifest:"
(
  export \
    CLUSTER_ASN=$CLUSTER_NET_ASN \
    NEI_ASN=$EXT_NET_ASN \
    NEI_IP=$EXT_FRR_IP \
    NICS="\"${NET1_NODE_NIC}\""
  echo "\
    CLUSTER_ASN=$CLUSTER_ASN
    NEI_ASN=$NEI_ASN
    NEI_IP=$NEI_IP
    NICS=$NICS"
  envsubst <<< $(cat $UNDERLAY_TEMPLATE) > $UNDERLAY_MANIFEST
)

echo "INFO: Create NNCP for creating linux-bridge"
oc apply -f $NNCP_MANIFEST
echo "INFO: Create underlay"
oc -n $NAMESPACE apply -f $UNDERLAY_MANIFEST
echo "INFO: Create VNIs"
oc -n $NAMESPACE apply -f $VNIS_MANIFEST

oc wait nncp/brvni110 --for condition=Available --timeout 5m
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
) 2>&1 | tee setup.log
