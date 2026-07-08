#! /bin/bash

# provider networks
NET1_HOST_NIC="net1"
NET1_CIDR="192.168.10.0/24"
NET1_PREFIX="24"
NET1_BRD="192.168.10.255"
NET1_NODE_NIC="ens4"
NET1_MVLAN="ens4mvln"

NET2_HOST_NIC="net2"
NET2_CIDR="192.168.20.0/24"
NET2_NODE_NIC="ens5"

# cluster nodes
NODE0_HOSTNAME="dev-worker-0"
NODE0="dev-worker-0.omergi"
NET1_NODE0_IP="192.168.10.31"
NET2_NODE0_IP="192.168.20.67"

NET1_MVLN_NODE0_IP="192.168.10.100"

NODE1_HOSTNAME="dev-worker-1"
NODE1="dev-worker-1.omergi"
NET1_NODE1_IP="192.168.10.245"
NET2_NODE1_IP="192.168.20.14"

NET1_MVLN_NODE1_IP="192.168.10.101"

# cluster nodes ASN
CLUSTER_NET_ASN=64514

# external router
EXT_NET_ASN=64512
EXT_NET_VTEP_CIDR="100.64.0.1/32"

# stretched network
EXT_NET_VRF="red"
EXT_NET_L3VNI=100
EXT_NET_L2VNI=110
EXT_NET_L2VNI_GW_CIDR="192.170.1.1/24"

# bridge used for connecting VMs to EVPN
VNI_BR_NNCP_NAME="linux-bridge-perouter-vni-110"
VNI_BR_NAD_NAME="evpn-l2vni-110"
L2VNI_BRIDGE="brvni110"

# container runtime networks
NET1_CRI_NET_NAME="net1-ex"
NET1_CRI_RANGE="192.168.10.128/25" # second half of the original CIDR

NET2_CRI_NET_NAME="net2-ex"
NET2_CRI_RANGE="192.168.20.128/25" # second half of the original CIDR

# stretched network, on external container runtime end
EXT_NET_CRI_NET_NAME="ext"
EXT_NET_CRI_CIDR="192.169.1.0/24"

# external client container
EXT_APP_NAME="external-client"
EXT_APP_IMG="registry.k8s.io/e2e-test-images/agnhost:2.45"

SCRIPT_PATH=$(dirname "$(realpath "$0")")
DIR=$(dirname $SCRIPT_PATH)

# external router container
EXT_FRR_NAME="frr"
EXT_FRR_IMG="frr-router"
FRR_CONFIG="${DIR}/external-router/frrconfigs"

# external router network interface names
EXT_FRR_NET1_NIC="eth0" # underlay
EXT_FRR_EXT_NET_NIC="eth1" # external client network

# templates and manifests paths
TMPL_DIR="${DIR}/templates"

FRR_CONF_TEMPLATE="${TMPL_DIR}/frr.conf"
FRR_CONF="${FRR_CONFIG}/frr.conf"

NNCP_VNI_BR_TEMPLATE="${TMPL_DIR}/vni-linux-bridge-nncp.yaml"
NNCP_VNI_BR_MANIFEST="${DIR}/00-vni-linux-bridge-nncp.yaml"

NAD_VNI_BR_TEMPLATE="${TMPL_DIR}/vni-linux-bridge-nad.yaml"
NAD_VNI_BR_MANIFEST="${DIR}/03-vni-linux-bridge-nad.yaml"

UNDERLAY_TEMPLATE="${TMPL_DIR}/openperouter-underlay.yaml"
UNDERLAY_MANIFEST="${DIR}/01-openperouter-underlay.yaml"

VNIS_TEMPLATE="${TMPL_DIR}/openperouter-vnis.yaml"
VNIS_MANIFEST="${DIR}/02-openperouter-vnis.yaml"

WORKLOADS_TEMPLATE="${TMPL_DIR}/workloads.yaml"
WORKLOADS_MANIFEST="${DIR}/04-workloads.yaml"

# openperouter system namespace
NAMESPACE="openshift-openperouter"

# tests namespace
TEST_NS="test-evpn-linux-bridge"

# VMs
VM1_NAME="vm1"
VM1_IP="192.170.1.3/24"
VM2_NAME="vm2"
VM2_IP="192.170.1.5/24"
VMS_GW="192.170.1.1"
VMS_PUBLIC_KEY="$(realpath ~/.ssh/kcli.pub)"
VMS_KEY="$(realpath ~/.ssh/kcli)"

# aggregated entities for teardown
NODE_VMS=($NODE0_HOSTNAME $NODE1_HOSTNAME)
CONTAINERS=($EXT_FRR_NAME $EXT_APP_NAME)
CRI_NETWORKS=($NET1_CRI_NET_NAME $NET2_CRI_NET_NAME $EXT_NET_CRI_NET_NAME)
NODE_NICS=($NET1_NODE_NIC $NET2_NODE_NIC)

NET1_NODE0_IP=$NET1_MVLN_NODE0_IP
NET1_NODE1_IP=$NET1_MVLN_NODE1_IP
