# Worker-0 Results

## macvlan0 (on br-ex)

```
$ oc exec -n openshift-openperouter router-xchtz -c frr -- ip addr show macvlan0
80: macvlan0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group 4242 qlen 1000
    link/ether 16:08:27:08:41:4a brd ff:ff:ff:ff:ff:ff link-netns 67cd1e9e-6514-4560-9b26-28a32efe0a37
    inet 192.168.122.210/24 scope global macvlan0
       valid_lft forever preferred_lft forever
    inet6 fe80::1408:27ff:fe08:414a/64 scope link 
       valid_lft forever preferred_lft forever
```

Note: `macvlan0@if7` — the parent is br-ex (OVS internal interface index 7), not a physical NIC.

## OVS Topology

```
$ oc debug node/multi-homing-worker-0.ralavi.corp -- chroot /host ovs-vsctl show
    Bridge br-ex
        Port ens3
            Interface ens3
                type: system
        Port br-ex
            Interface br-ex
                type: internal
        Port patch-br-ex_multi-homing-worker-0.ralavi.corp-to-br-int
            Interface patch-br-ex_multi-homing-worker-0.ralavi.corp-to-br-int
                type: patch
                options: {peer=patch-br-int-to-br-ex_multi-homing-worker-0.ralavi.corp}
    Bridge ovsbr1
        Port ovsbr1
            Interface ovsbr1
                type: internal
        Port host-110
            Interface host-110
                type: system
        Port patch-evpn_ovn_localnet_port-to-br-int
            Interface patch-evpn_ovn_localnet_port-to-br-int
                type: patch
                options: {peer=patch-br-int-to-evpn_ovn_localnet_port}
    ovs_version: "3.5.2-72.el9fdp"
```

## Bridge Mappings

```
$ oc debug node/multi-homing-worker-0.ralavi.corp -- chroot /host ovs-vsctl get open . external_ids:ovn-bridge-mappings
"datanet:ovsbr1,physnet:br-ex"
```

## BGP L2VPN EVPN Summary

```
$ oc exec -n openshift-openperouter router-xchtz -c frr -- vtysh -c "show bgp l2vpn evpn summary"
BGP router identifier 10.0.0.2, local AS number 64514 vrf-id 0
BGP table version 0
RIB entries 11, using 2112 bytes of memory
Peers 1, using 725 KiB of memory

Neighbor         V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.122.201  4      64512        28        26        0    0    0 00:05:14           11       20 N/A

Total number of neighbors 1
```

## EVPN Type-2 Routes

```
$ oc exec -n openshift-openperouter router-xchtz -c frr -- vtysh -c "show bgp l2vpn evpn route type 2"
BGP table version is 8, local router ID is 10.0.0.2
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.2:3
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1]
                    100.65.0.1                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:3a:40:d7:b9:35:3b
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:0a]:[32]:[192.170.1.10]
                    100.65.0.1                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:3a:40:d7:b9:35:3b
Route Distinguisher: 10.0.0.3:3
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:14]:[32]:[192.170.1.20]
                    100.65.0.2                             0 64512 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:f6:81:21:43:e9:2d
Route Distinguisher: 100.64.0.1:3
 *> [2]:[0]:[48]:[9a:77:23:36:f5:5a]:[32]:[192.170.1.100]
                    100.64.0.1                             0 64512 i
                    RT:64512:100 RT:64512:110 ET:8 Rmac:aa:bb:cc:00:00:65

Displayed 13 prefixes (13 paths) (of requested type)
```
