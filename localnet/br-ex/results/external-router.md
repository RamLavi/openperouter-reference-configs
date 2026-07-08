# External Router Results

## FRR Container Interfaces

```
$ FRR_PID=$(podman inspect frr --format '{{.State.Pid}}') && nsenter -t $FRR_PID -n ip addr show
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    inet 127.0.0.1/8 scope host lo
    inet 100.64.0.1/32 scope global lo
2: eth0@if1272: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet 192.168.122.201/24 brd 192.168.122.255 scope global eth0
3: eth1@if4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue master red state UP group default qlen 1000
    inet 192.169.1.2/24 brd 192.169.1.255 scope global eth1
4: red: <NOARP,MASTER,UP,LOWER_UP> mtu 65575 qdisc noqueue state UP group default qlen 1000
5: br100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
6: vni100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br100 state UNKNOWN group default qlen 1000
7: vni110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br110 state UNKNOWN group default qlen 1000
8: br110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
    inet 192.170.1.100/24 scope global br110
```

Note: eth0 (192.168.122.x, cluster network) is in the **default VRF**. eth1 (192.169.1.x, isolated client network) is in **VRF red**.

## VRF Red Routes

```
$ podman exec frr ip route show vrf red
192.169.1.0/24 dev eth1 proto kernel scope link src 192.169.1.2
192.170.1.0/24 dev br110 proto kernel scope link src 192.170.1.100
192.170.1.1 nhid 27 via 100.65.0.2 dev br100 proto bgp metric 20 onlink
192.170.1.10 nhid 31 via 100.65.0.1 dev br100 proto bgp metric 20 onlink
192.170.1.20 nhid 27 via 100.65.0.2 dev br100 proto bgp metric 20 onlink
```

## BGP L2VPN EVPN Summary

```
$ podman exec frr vtysh -c "show bgp l2vpn evpn summary"
BGP router identifier 100.64.0.1, local AS number 64512 VRF default vrf-id 0
BGP table version 0
RIB entries 11, using 1672 bytes of memory
Peers 2, using 33 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor         V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
*192.168.122.210 4      64514        26        28        8    0    0 00:05:15            9       22 N/A
*192.168.122.211 4      64514        26        28        8    0    0 00:05:43            9       22 N/A

Total number of neighbors 2
* - dynamic neighbor
2 dynamic neighbor(s), limit 100
```

## EVPN Type-2 Routes

```
$ podman exec frr vtysh -c "show bgp l2vpn evpn route type 2"
BGP table version is 8, local router ID is 100.64.0.1
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.2:3
 *>  [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1] RD 10.0.0.2:3
                    100.65.0.1                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:3a:40:d7:b9:35:3b
 *>  [2]:[0]:[48]:[0a:58:c0:aa:01:0a]:[32]:[192.170.1.10] RD 10.0.0.2:3
                    100.65.0.1                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:3a:40:d7:b9:35:3b
Route Distinguisher: 10.0.0.3:3
 *>  [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:f6:81:21:43:e9:2d
 *>  [2]:[0]:[48]:[0a:58:c0:aa:01:14]:[32]:[192.170.1.20] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:f6:81:21:43:e9:2d
Route Distinguisher: 100.64.0.1:3
 *>  [2]:[0]:[48]:[9a:77:23:36:f5:5a]:[32]:[192.170.1.100] RD 100.64.0.1:3
                    100.64.0.1                         32768 i
                    ET:8 RT:64512:110 RT:64512:100 Rmac:aa:bb:cc:00:00:65

Displayed 15 prefixes (15 paths) (of requested type)
```
