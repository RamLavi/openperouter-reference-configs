#!/bin/bash

set -x

# $NIC (external client network) is attached to VRF $VRF.
# eth0 = underlay (192.168.10.0/24) stays in default VRF for BGP peering.
# eth1 = isolated client network (192.169.1.x) goes in VRF $VRF for L3 routing.

NIC=${NIC:-eth1}

VRF=${VRF:-red}
VRF_TABLE=${VRF_TABLE:-1100}

VTEP_CIDR=${VTEP_IP:-100.64.0.1/32}
VTEP_IP=${VTEP_IP:-100.64.0.1}

L3VNI=${L2VNI:-100}
L3VNI_BR=${L3VNI_BR:-br100}
L3VNI_TUN=${L3VNI_TUN:-vni100}

L2VNI=${L2VNI:-110}
L2VNI_BR=${L2VNI_BR:-br110}
L2VNI_TUN=${L2VNI_TUN:-vni110}
L2VNI_CIDR=${L2VNI_CIDR:-192.170.1.100/24}

# this is to avoid to loose the ipv6 address after enslaving to the vrf
sysctl -w net.ipv6.conf.all.keep_addr_on_down=1

# VTEP IP
ip addr add $VTEP_CIDR dev lo

ip link add $VRF type vrf table $VRF_TABLE

ip link set $NIC master $VRF

ip link set $VRF up
ip link add $L3VNI_BR type bridge
ip link set $L3VNI_BR master $VRF addrgenmode none
ip link set $L3VNI_BR addr aa:bb:cc:00:00:65
ip link add $L3VNI_TUN type vxlan local $VTEP_IP dstport 4789 id $L3VNI nolearning
ip link set $L3VNI_TUN master $L3VNI_BR addrgenmode none
ip link set $L3VNI_TUN type bridge_slave neigh_suppress on learning off
ip link set $L3VNI_TUN up
ip link set $L3VNI_BR up

# L2VNI (VNI 110) — for stretched L2 segment
ip link add $L2VNI_TUN type vxlan local $VTEP_IP dstport 4789 id $L2VNI nolearning
ip link add $L2VNI_BR type bridge
ip link set $L2VNI_BR master $VRF addrgenmode none
ip link set $L2VNI_TUN master $L2VNI_BR
ip link set $L2VNI_TUN type bridge_slave neigh_suppress on learning off
ip link set $L2VNI_TUN up
ip link set $L2VNI_BR up

/sbin/tini -s -- /usr/lib/frr/docker-start
