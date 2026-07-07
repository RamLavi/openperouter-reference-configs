# external router

```bash
$ podman ps | grep frr
7516125557b5  localhost/frr-router:latest                               2 hours ago  Up 2 hours                                             frr
```

## Addresses
```bash
$ podman exec -it frr ip -color=never addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 100.64.0.1/32 scope global lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host proto kernel_lo 
       valid_lft forever preferred_lft forever
2: eth0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 12:57:16:21:93:b9 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.10.129/24 brd 192.168.10.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::1057:16ff:fe21:93b9/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: eth1@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue master red state UP group default qlen 1000
    link/ether 46:80:c0:e5:fa:7f brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.169.1.1/24 brd 192.169.1.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::4480:c0ff:fee5:fa7f/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: red: <NOARP,MASTER,UP,LOWER_UP> mtu 65575 qdisc noqueue state UP group default qlen 1000
    link/ether 0a:e9:57:4d:42:3c brd ff:ff:ff:ff:ff:ff
5: br100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
    link/ether aa:bb:cc:00:00:65 brd ff:ff:ff:ff:ff:ff
6: vni100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br100 state UNKNOWN group default qlen 1000
    link/ether 6a:28:3d:c4:ca:66 brd ff:ff:ff:ff:ff:ff
7: vni110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br110 state UNKNOWN group default qlen 1000
    link/ether de:48:a3:d1:a0:2c brd ff:ff:ff:ff:ff:ff
    inet6 fe80::dc48:a3ff:fed1:a02c/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
8: br110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
    link/ether de:48:a3:d1:a0:2c brd ff:ff:ff:ff:ff:ff
    inet 192.170.1.100/24 scope global br110
       valid_lft forever preferred_lft forever
```

## Routes
```bash
$ podman exec -it frr ip -color=never route
default via 192.168.10.1 dev eth0 proto static metric 100 
100.65.0.2 nhid 25 via 192.168.10.100 dev eth0 proto bgp metric 20 
100.65.0.4 nhid 27 via 192.168.10.101 dev eth0 proto bgp metric 20 
192.168.10.0/24 dev eth0 proto kernel scope link src 192.168.10.129 
```

## Neighbors
```bash
$ podman exec -it frr ip -color=never nei
192.170.1.3 dev br110 lladdr 02:79:38:33:33:33 extern_learn NOARP proto zebra 
100.65.0.4 dev br100 lladdr a2:c9:ec:91:98:9e extern_learn NOARP proto zebra 
192.170.1.1 dev br110 lladdr 00:f3:00:00:00:6f extern_learn NOARP proto zebra 
100.65.0.2 dev br100 lladdr ce:15:1d:3a:67:df extern_learn NOARP proto zebra 
192.168.10.101 dev eth0 lladdr 8e:37:fd:03:88:86 REACHABLE 
192.169.1.129 dev eth1 lladdr 72:27:70:1f:b5:ad REACHABLE 
192.170.1.5 dev br110 lladdr 02:79:38:55:55:55 extern_learn NOARP proto zebra 
192.168.10.100 dev eth0 lladdr 1a:bc:97:6a:53:04 STALE 
fe80::ee94:d500:99f1:1300 dev eth1 lladdr ec:94:d5:f1:13:00 router STALE 
fe80::64c1:c7ff:fe77:167d dev br110 lladdr 66:c1:c7:77:16:7d extern_learn NOARP proto zebra 
fe80::90e5:c7ff:fefe:159 dev br110 lladdr 92:e5:c7:fe:01:59 extern_learn NOARP proto zebra 
fe80::ee94:d500:99f0:e600 dev eth1 lladdr ec:94:d5:f0:e6:00 router STALE 
fe80::200:5eff:fe00:201 dev eth1 lladdr 00:00:5e:00:02:01 router STALE 
fe80::f481:c0ff:fe42:7492 dev br110 lladdr 00:f3:00:00:00:6f extern_learn NOARP proto zebra 
fe80::98b5:81ff:fe35:cc35 dev br110 lladdr 00:f3:00:00:00:6f extern_learn NOARP proto zebra 
```

### Bridge FDBs
```bash
$ podman exec -it frr bridge -color=never fdb show
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:21:93:b9 dev eth0 self permanent
01:00:5e:00:00:01 dev eth1 self permanent
33:33:00:00:00:01 dev eth1 self permanent
33:33:ff:e5:fa:7f dev eth1 self permanent
33:33:00:00:00:01 dev red self permanent
01:00:5e:00:00:01 dev red self permanent
33:33:00:00:00:01 dev br100 self permanent
01:00:5e:00:00:6a dev br100 self permanent
33:33:00:00:00:6a dev br100 self permanent
01:00:5e:00:00:01 dev br100 self permanent
aa:bb:cc:00:00:65 dev br100 vlan 1 master br100 permanent
aa:bb:cc:00:00:65 dev br100 master br100 permanent
ce:15:1d:3a:67:df dev vni100 vlan 1 extern_learn master br100 
ce:15:1d:3a:67:df dev vni100 extern_learn master br100 
a2:c9:ec:91:98:9e dev vni100 vlan 1 extern_learn master br100 
a2:c9:ec:91:98:9e dev vni100 extern_learn master br100 
6a:28:3d:c4:ca:66 dev vni100 vlan 1 master br100 permanent
6a:28:3d:c4:ca:66 dev vni100 master br100 permanent
a2:c9:ec:91:98:9e dev vni100 dst 100.65.0.4 self extern_learn 
ce:15:1d:3a:67:df dev vni100 dst 100.65.0.2 self extern_learn 
02:79:38:55:55:55 dev vni110 vlan 1 extern_learn master br110 
02:79:38:55:55:55 dev vni110 extern_learn master br110 
02:79:38:33:33:33 dev vni110 vlan 1 extern_learn master br110 
02:79:38:33:33:33 dev vni110 extern_learn master br110 
0a:af:1b:41:30:44 dev vni110 vlan 1 extern_learn master br110 
0a:af:1b:41:30:44 dev vni110 extern_learn master br110 
66:c1:c7:77:16:7d dev vni110 vlan 1 extern_learn master br110 
66:c1:c7:77:16:7d dev vni110 extern_learn master br110 
92:e5:c7:fe:01:59 dev vni110 vlan 1 extern_learn master br110 
92:e5:c7:fe:01:59 dev vni110 extern_learn master br110 
00:f3:00:00:00:6f dev vni110 vlan 1 extern_learn master br110 
00:f3:00:00:00:6f dev vni110 extern_learn master br110 
de:48:a3:d1:a0:2c dev vni110 vlan 1 master br110 permanent
de:48:a3:d1:a0:2c dev vni110 master br110 permanent
00:00:00:00:00:00 dev vni110 dst 100.65.0.4 self permanent
00:00:00:00:00:00 dev vni110 dst 100.65.0.2 self permanent
92:e5:c7:fe:01:59 dev vni110 dst 100.65.0.2 self extern_learn 
66:c1:c7:77:16:7d dev vni110 dst 100.65.0.4 self extern_learn 
0a:af:1b:41:30:44 dev vni110 dst 100.65.0.2 self extern_learn 
02:79:38:55:55:55 dev vni110 dst 100.65.0.2 self extern_learn 
02:79:38:33:33:33 dev vni110 dst 100.65.0.4 self extern_learn 
00:f3:00:00:00:6f dev vni110 dst 100.65.0.2 self extern_learn 
33:33:00:00:00:01 dev br110 self permanent
01:00:5e:00:00:6a dev br110 self permanent
33:33:00:00:00:6a dev br110 self permanent
01:00:5e:00:00:01 dev br110 self permanent
```

## Routes vrf: [red]
```bash
$ podman exec -it frr ip -color=never route show vrf red
192.169.1.0/24 dev eth1 proto kernel scope link src 192.169.1.1 
192.170.1.0/24 dev br110 proto kernel scope link src 192.170.1.100 
192.170.1.1 nhid 29 via 100.65.0.4 dev br100 proto bgp metric 20 onlink 
192.170.1.3 nhid 29 via 100.65.0.4 dev br100 proto bgp metric 20 onlink 
192.170.1.5 nhid 32 via 100.65.0.2 dev br100 proto bgp metric 20 onlink 
```

## Neighbors vrf [red]
```bash
$ podman exec -it frr ip -color=never neigh show vrf red
192.170.1.3 dev br110 lladdr 02:79:38:33:33:33 extern_learn NOARP proto zebra 
100.65.0.4 dev br100 lladdr a2:c9:ec:91:98:9e extern_learn NOARP proto zebra 
192.170.1.1 dev br110 lladdr 00:f3:00:00:00:6f extern_learn NOARP proto zebra 
100.65.0.2 dev br100 lladdr ce:15:1d:3a:67:df extern_learn NOARP proto zebra 
192.169.1.129 dev eth1 lladdr 72:27:70:1f:b5:ad STALE 
192.170.1.5 dev br110 lladdr 02:79:38:55:55:55 extern_learn NOARP proto zebra 
fe80::ee94:d500:99f1:1300 dev eth1 lladdr ec:94:d5:f1:13:00 router STALE 
fe80::64c1:c7ff:fe77:167d dev br110 lladdr 66:c1:c7:77:16:7d extern_learn NOARP proto zebra 
fe80::90e5:c7ff:fefe:159 dev br110 lladdr 92:e5:c7:fe:01:59 extern_learn NOARP proto zebra 
fe80::ee94:d500:99f0:e600 dev eth1 lladdr ec:94:d5:f0:e6:00 router STALE 
fe80::200:5eff:fe00:201 dev eth1 lladdr 00:00:5e:00:02:01 router STALE 
fe80::f481:c0ff:fe42:7492 dev br110 lladdr 00:f3:00:00:00:6f extern_learn NOARP proto zebra 
fe80::98b5:81ff:fe35:cc35 dev br110 lladdr 00:f3:00:00:00:6f extern_learn NOARP proto zebra 
```

## BGP IPv4 Summary
```bash
$ podman exec -it frr vtysh -c 'show bgp ipv4'
BGP table version is 3, local router ID is 100.64.0.1, vrf id 0
Default local pref 100, local AS 64512
Status codes:  s suppressed, d damped, h history, u unsorted, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  100.64.0.1/32    0.0.0.0                  0         32768 i
 *>  100.65.0.2/32    192.168.10.100           0             0 64514 i
 *>  100.65.0.4/32    192.168.10.101           0             0 64514 i

Displayed 3 routes and 3 total paths
```

## BGP L2VPN EVPN Summary
```bash
$ podman exec -it frr vtysh -c 'show bgp l2vpn evpn summary'
BGP router identifier 100.64.0.1, local AS number 64512 VRF default vrf-id 0
BGP table version 0
RIB entries 11, using 1672 bytes of memory
Peers 2, using 33 KiB of memory
Peer groups 1, using 64 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
*192.168.10.100 4      64514       223       226       83    0    0 01:40:52            8       20 N/A
*192.168.10.101 4      64514       224       226       83    0    0 01:40:43            8       20 N/A

Total number of neighbors 2
* - dynamic neighbor
2 dynamic neighbor(s), limit 100
```

## EVPN Type-2 Routes
```bash
$ podman exec -it frr vtysh -c 'show bgp l2vpn evpn route type 2'
BGP table version is 83, local router ID is 100.64.0.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.3:3
 *>  [2]:[0]:[48]:[00:f3:00:00:00:6f]:[128]:[fe80::98b5:81ff:fe35:cc35] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[02:79:38:55:55:55] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[02:79:38:55:55:55]:[32]:[192.170.1.5] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:ce:15:1d:3a:67:df
 *>  [2]:[0]:[48]:[0a:af:1b:41:30:44] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[92:e5:c7:fe:01:59] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[92:e5:c7:fe:01:59]:[128]:[fe80::90e5:c7ff:fefe:159] RD 10.0.0.3:3
                    100.65.0.2                             0 64514 i
                    RT:64514:110 ET:8
Route Distinguisher: 10.0.0.5:3
 *>  [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1] RD 10.0.0.5:3
                    100.65.0.4                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:a2:c9:ec:91:98:9e
 *>  [2]:[0]:[48]:[00:f3:00:00:00:6f]:[128]:[fe80::f481:c0ff:fe42:7492] RD 10.0.0.5:3
                    100.65.0.4                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[02:79:38:33:33:33] RD 10.0.0.5:3
                    100.65.0.4                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[02:79:38:33:33:33]:[32]:[192.170.1.3] RD 10.0.0.5:3
                    100.65.0.4                             0 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:a2:c9:ec:91:98:9e
 *>  [2]:[0]:[48]:[66:c1:c7:77:16:7d] RD 10.0.0.5:3
                    100.65.0.4                             0 64514 i
                    RT:64514:110 ET:8
 *>  [2]:[0]:[48]:[66:c1:c7:77:16:7d]:[128]:[fe80::64c1:c7ff:fe77:167d] RD 10.0.0.5:3
                    100.65.0.4                             0 64514 i
                    RT:64514:110 ET:8
Route Distinguisher: 100.64.0.1:3
 *>  [2]:[0]:[48]:[de:48:a3:d1:a0:2c]:[32]:[192.170.1.100] RD 100.64.0.1:3
                    100.64.0.1                         32768 i
                    ET:8 RT:64512:110 RT:64512:100 Rmac:aa:bb:cc:00:00:65

Displayed 13 prefixes (13 paths) (of requested type)
```

## EVPN Type-5 Routes
```bash
$ podman exec -it frr vtysh -c 'show bgp l2vpn evpn route type 5'
BGP table version is 3, local router ID is 100.64.0.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.3:2
 *>  [5]:[0]:[24]:[192.170.1.0] RD 10.0.0.3:2
                    100.65.0.2               0             0 64514 i
                    RT:64514:100 ET:8 Rmac:ce:15:1d:3a:67:df
Route Distinguisher: 10.0.0.5:2
 *>  [5]:[0]:[24]:[192.170.1.0] RD 10.0.0.5:2
                    100.65.0.4               0             0 64514 i
                    RT:64514:100 ET:8 Rmac:a2:c9:ec:91:98:9e
Route Distinguisher: 192.170.1.100:1
 *>  [5]:[0]:[24]:[192.169.1.0] RD 192.170.1.100:1
                    100.64.0.1               0         32768 ?
                    ET:8 RT:64512:100 Rmac:aa:bb:cc:00:00:65
 *>  [5]:[0]:[24]:[192.170.1.0] RD 192.170.1.100:1
                    100.64.0.1               0         32768 ?
                    ET:8 RT:64512:100 Rmac:aa:bb:cc:00:00:65

Displayed 4 prefixes (4 paths) (of requested type)
```

## BGP Neighbors
```bash
$ podman exec -it frr vtysh -c 'show bgp nei'
BGP neighbor is *192.168.10.100, remote AS 64514, local AS 64512, external link
  Local Role: undefined
  Remote Role: undefined
Hostname: dev-worker-0.omergi
 Member of peer-group ocp-nodes for session parameters
 Belongs to the subnet range group: 192.168.10.0/24
  BGP version 4, remote router ID 10.0.0.3, local router ID 100.64.0.1
  BGP state = Established, up for 01:40:58
  Last read 00:00:58, Last write 00:00:58
  Hold time is 180 seconds, keepalive interval is 60 seconds
  Configured hold time is 180 seconds, keepalive interval is 60 seconds
  Configured tcp-mss is 0, synced tcp-mss is 1448
  Configured conditional advertisements interval is 60 seconds
  Neighbor capabilities:
    4 Byte AS: advertised and received
    Extended Message: advertised and received
    AddPath:
      IPv4 Unicast: RX advertised and received
      L2VPN EVPN: RX advertised and received
    Paths-Limit:
      IPv4 Unicast: advertised (0)
      L2VPN EVPN: advertised (0)
    Long-lived Graceful Restart: advertised and received
      Address families by peer:
    Route refresh: advertised and received
    Enhanced Route Refresh: advertised and received
    Address Family IPv4 Unicast: advertised and received
    Address Family L2VPN EVPN: advertised and received
    Hostname Capability: advertised (name: 7516125557b5,domain name: n/a) received (name: dev-worker-0.omergi,domain name: n/a)
    Version Capability: not advertised not received
    Link-Local Next Hop Capability: not advertised not received
    Graceful Restart Capability: advertised and received
      Remote Restart timer is 120 seconds
      Address families by peer:
            Graceful Restart Capability: advertised and received
      Remote Restart timer is 120 seconds
      Peer has restarted (R-bit is set)
      Peer has restarted (N-bit is set)
      Address families by peer:
        none
  Graceful restart information:
    End-of-RIB send: IPv4 Unicast, L2VPN EVPN
    End-of-RIB received: IPv4 Unicast, L2VPN EVPN
    Local GR Mode: Helper*
    Remote GR Mode: Helper

    R bit: True
    N bit: True
    Timers:
      Configured Restart Time(sec): 120
      Received Restart Time(sec): 120
      Configured LLGR Stale Path Time(sec): 0
    IPv4 Unicast:
      F bit: False
      End-of-RIB sent: Yes
      End-of-RIB sent after update: No
      End-of-RIB received: Yes
      Timers:
        Configured Stale Path Time(sec): 360
        LLGR Stale Path Time(sec): 0
    L2VPN EVPN:
      F bit: False
      End-of-RIB sent: Yes
      End-of-RIB sent after update: No
      End-of-RIB received: Yes
      Timers:
        Configured Stale Path Time(sec): 360
        LLGR Stale Path Time(sec): 0
  Message statistics:
    Inq depth is 0
    Outq depth is 0
                         Sent       Rcvd
    Opens:                  1          1
    Notifications:          0          0
    Updates:              124        121
    Keepalives:           101        101
    Route Refresh:          0          0
    Capability:             0          0
    Total:                226        223

  Prefix statistics:
    Inbound filtered: 0
    AS-PATH loop: 55
    Originator loop: 0
    Cluster loop: 0
    Invalid next-hop: 4
    Withdrawn: 0
    Attributes discarded: 0

  Minimum time between advertisement runs is 0 seconds
  Update delay timer is 0 seconds (remaining: 0)

 For address family: IPv4 Unicast
  ocp-nodes peer-group member
  Update group 1, subgroup 1
  Packet Queue length 0
  Community attribute sent to this neighbor(all)
  1 accepted, 3 sent prefixes

 For address family: L2VPN EVPN
  ocp-nodes peer-group member
  Update group 2, subgroup 2
  Packet Queue length 0
  Local AS allowed as path origin
  NEXT_HOP is propagated unchanged to this neighbor
  Community attribute sent to this neighbor(all)
  advertise-all-vni
  8 accepted, 20 sent prefixes

  Connections established 1; dropped 0
  Last reset 01:40:59,  No AFI/SAFI activated for peer (n/a)
  External BGP neighbor may be up to 1 hops away.
Local host: 192.168.10.129, Local port: 179
Foreign host: 192.168.10.100, Foreign port: 34934
Nexthop: 192.168.10.129
Nexthop global: fe80::1057:16ff:fe21:93b9
Nexthop local: fe80::1057:16ff:fe21:93b9
BGP connection: shared network
BGP Connect Retry Timer in Seconds: 30
Estimated round trip time: 8 ms
Read thread: on  Write thread: on  FD used: 30

BGP neighbor is *192.168.10.101, remote AS 64514, local AS 64512, external link
  Local Role: undefined
  Remote Role: undefined
Hostname: dev-worker-1.omergi
 Member of peer-group ocp-nodes for session parameters
 Belongs to the subnet range group: 192.168.10.0/24
  BGP version 4, remote router ID 10.0.0.5, local router ID 100.64.0.1
  BGP state = Established, up for 01:40:49
  Last read 00:00:49, Last write 00:00:49
  Hold time is 180 seconds, keepalive interval is 60 seconds
  Configured hold time is 180 seconds, keepalive interval is 60 seconds
  Configured tcp-mss is 0, synced tcp-mss is 1448
  Configured conditional advertisements interval is 60 seconds
  Neighbor capabilities:
    4 Byte AS: advertised and received
    Extended Message: advertised and received
    AddPath:
      IPv4 Unicast: RX advertised and received
      L2VPN EVPN: RX advertised and received
    Paths-Limit:
      IPv4 Unicast: advertised (0)
      L2VPN EVPN: advertised (0)
    Long-lived Graceful Restart: advertised and received
      Address families by peer:
    Route refresh: advertised and received
    Enhanced Route Refresh: advertised and received
    Address Family IPv4 Unicast: advertised and received
    Address Family L2VPN EVPN: advertised and received
    Hostname Capability: advertised (name: 7516125557b5,domain name: n/a) received (name: dev-worker-1.omergi,domain name: n/a)
    Version Capability: not advertised not received
    Link-Local Next Hop Capability: not advertised not received
    Graceful Restart Capability: advertised and received
      Remote Restart timer is 120 seconds
      Address families by peer:
            Graceful Restart Capability: advertised and received
      Remote Restart timer is 120 seconds
      Peer has restarted (R-bit is set)
      Peer has restarted (N-bit is set)
      Address families by peer:
        none
  Graceful restart information:
    End-of-RIB send: IPv4 Unicast, L2VPN EVPN
    End-of-RIB received: IPv4 Unicast, L2VPN EVPN
    Local GR Mode: Helper*
    Remote GR Mode: Helper

    R bit: True
    N bit: True
    Timers:
      Configured Restart Time(sec): 120
      Received Restart Time(sec): 120
      Configured LLGR Stale Path Time(sec): 0
    IPv4 Unicast:
      F bit: False
      End-of-RIB sent: Yes
      End-of-RIB sent after update: Yes
      End-of-RIB received: Yes
      Timers:
        Configured Stale Path Time(sec): 360
        LLGR Stale Path Time(sec): 0
    L2VPN EVPN:
      F bit: False
      End-of-RIB sent: Yes
      End-of-RIB sent after update: No
      End-of-RIB received: Yes
      Timers:
        Configured Stale Path Time(sec): 360
        LLGR Stale Path Time(sec): 0
  Message statistics:
    Inq depth is 0
    Outq depth is 0
                         Sent       Rcvd
    Opens:                  1          1
    Notifications:          0          0
    Updates:              124        122
    Keepalives:           101        101
    Route Refresh:          0          0
    Capability:             0          0
    Total:                226        224

  Prefix statistics:
    Inbound filtered: 0
    AS-PATH loop: 55
    Originator loop: 0
    Cluster loop: 0
    Invalid next-hop: 4
    Withdrawn: 0
    Attributes discarded: 0

  Minimum time between advertisement runs is 0 seconds
  Update delay timer is 0 seconds (remaining: 0)

 For address family: IPv4 Unicast
  ocp-nodes peer-group member
  Update group 1, subgroup 1
  Packet Queue length 0
  Community attribute sent to this neighbor(all)
  1 accepted, 3 sent prefixes

 For address family: L2VPN EVPN
  ocp-nodes peer-group member
  Update group 2, subgroup 2
  Packet Queue length 0
  Local AS allowed as path origin
  NEXT_HOP is propagated unchanged to this neighbor
  Community attribute sent to this neighbor(all)
  advertise-all-vni
  8 accepted, 20 sent prefixes

  Connections established 1; dropped 0
  Last reset 01:40:49,  No AFI/SAFI activated for peer (n/a)
  External BGP neighbor may be up to 1 hops away.
Local host: 192.168.10.129, Local port: 179
Foreign host: 192.168.10.101, Foreign port: 37322
Nexthop: 192.168.10.129
Nexthop global: fe80::1057:16ff:fe21:93b9
Nexthop local: fe80::1057:16ff:fe21:93b9
BGP connection: shared network
BGP Connect Retry Timer in Seconds: 30
Estimated round trip time: 5 ms
Read thread: on  Write thread: on  FD used: 31


```

### EVPN VNI Summary
```bash
$ podman exec -it frr vtysh -c 'show evpn vni'
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF      VLAN       BRIDGE                               
110        L2   vni110                7        8        2               red             1          br110                                
100        L3   vni100                2        2        n/a             red             1          br100                                
```

### EVPN VNI [110]
```bash
$ podman exec -it frr vtysh -c 'show evpn vni 110 json'
{
  "vni":110,
  "type":"L2",
  "vlan":1,
  "bridge":"br110",
  "tenantVrf":"red",
  "vxlanInterface":"vni110",
  "vxlanIfindex":7,
  "sviInterface":"br110",
  "sviIfindex":8,
  "vtepIp":"100.64.0.1",
  "mcastGroup":"0.0.0.0",
  "advertiseGatewayMacip":"No",
  "advertiseSviMacip":"No",
  "numMacs":7,
  "numArpNd":8,
  "numRemoteVteps":2,
  "remoteVteps":[
    {
      "ip":"100.65.0.2",
      "flood":"HER"
    },
    {
      "ip":"100.65.0.4",
      "flood":"HER"
    }
  ]
}
```

### EVPN VNI [100]
```bash
$ podman exec -it frr vtysh -c 'show evpn vni 100 json'
{
  "vni":100,
  "type":"L3",
  "tenantVrf":"red",
  "vlan":1,
  "bridge":"br100",
  "localVtepIp":"100.64.0.1",
  "vxlanIntf":"vni100",
  "sviIntf":"br100",
  "state":"Up",
  "sysMac":"aa:bb:cc:00:00:65",
  "routerMac":"aa:bb:cc:00:00:65",
  "vniFilter":"none",
  "l2Vnis":[
    110
  ]
}
```

