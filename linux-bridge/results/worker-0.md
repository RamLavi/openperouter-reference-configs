# worker-0

```bash
$ oc -n openshift-openperouter get po router-lf7fw -o wide
NAME           READY   STATUS    RESTARTS        AGE     IP               NODE                  NOMINATED NODE   READINESS GATES
router-lf7fw   2/2     Running   1 (6h32m ago)   6h34m   192.168.122.57   dev-worker-0.omergi   <none>           <none>
```

## Addresses
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- ip -color=never addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 100.65.0.2/32 scope global lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
77: red: <NOARP,MASTER,UP,LOWER_UP> mtu 65575 qdisc noqueue state UP group default 
    link/ether 8a:85:4f:24:7b:b5 brd ff:ff:ff:ff:ff:ff
78: br-pe-100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65486 qdisc noqueue master red state UP group default 
    link/ether ce:15:1d:3a:67:df brd ff:ff:ff:ff:ff:ff
79: vni100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65486 qdisc noqueue master br-pe-100 state UNKNOWN group default 
    link/ether ce:15:1d:3a:67:df brd ff:ff:ff:ff:ff:ff
80: br-pe-110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master red state UP group default 
    link/ether 00:f3:00:00:00:6f brd ff:ff:ff:ff:ff:ff
    inet 192.170.1.1/24 brd 192.170.1.255 scope global br-pe-110
       valid_lft forever preferred_lft forever
    inet6 fe80::98b5:81ff:fe35:cc35/64 scope link 
       valid_lft forever preferred_lft forever
81: vni110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65486 qdisc noqueue master br-pe-110 state UNKNOWN group default 
    link/ether 46:85:e3:76:61:df brd ff:ff:ff:ff:ff:ff
1694: ens4mvln@if3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group 4242 qlen 1000
    link/ether 1a:bc:97:6a:53:04 brd ff:ff:ff:ff:ff:ff link-netns 0f899232-1344-4fc9-bd59-282a234d5ef6
    inet 192.168.10.100/24 brd 192.168.10.255 scope global ens4mvln
       valid_lft forever preferred_lft forever
    inet6 fe80::18bc:97ff:fe6a:5304/64 scope link 
       valid_lft forever preferred_lft forever
1695: pe-110@if1696: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master br-pe-110 state UP group default 
    link/ether 26:5f:b7:79:f3:ca brd ff:ff:ff:ff:ff:ff link-netns 0f899232-1344-4fc9-bd59-282a234d5ef6
    inet6 fe80::245f:b7ff:fe79:f3ca/64 scope link 
       valid_lft forever preferred_lft forever
```

## Routes
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- ip -color=never route
100.64.0.1 nhid 8 via 192.168.10.129 dev ens4mvln proto bgp metric 20 
100.65.0.4 nhid 10 via 192.168.10.101 dev ens4mvln proto bgp metric 20 
192.168.10.0/24 dev ens4mvln proto kernel scope link src 192.168.10.100 
```

## Neighbors
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- ip -color=never nei
192.170.1.1 dev br-pe-110 lladdr 26:5f:b7:79:f3:ca extern_learn NOARP proto zebra 
100.64.0.1 dev br-pe-100 lladdr aa:bb:cc:00:00:65 extern_learn NOARP proto zebra 
192.170.1.100 dev br-pe-110 lladdr de:48:a3:d1:a0:2c extern_learn NOARP proto zebra 
192.170.1.3 dev br-pe-110 lladdr 02:79:38:33:33:33 extern_learn NOARP proto zebra 
192.170.1.100 dev br-pe-100 lladdr de:48:a3:d1:a0:2c extern_learn NOARP proto zebra 
192.170.1.5 dev br-pe-110 lladdr 02:79:38:55:55:55 STALE 
100.65.0.4 dev br-pe-100 lladdr a2:c9:ec:91:98:9e extern_learn NOARP proto zebra 
192.168.10.129 dev ens4mvln lladdr 12:57:16:21:93:b9 REACHABLE 
192.168.10.101 dev ens4mvln lladdr 8e:37:fd:03:88:86 REACHABLE 
fe80::b8af:56ff:fe2f:a902 dev br-pe-110 lladdr a6:9d:bf:40:35:c3 STALE 
fe80::90e5:c7ff:fefe:159 dev br-pe-110 lladdr 92:e5:c7:fe:01:59 STALE 
fe80::fc54:ff:fe1f:2f5f dev ens4mvln lladdr fe:54:00:1f:2f:5f STALE 
fe80::1057:16ff:fe21:93b9 dev ens4mvln lladdr 12:57:16:21:93:b9 STALE 
fe80::64c1:c7ff:fe77:167d dev br-pe-110 lladdr 66:c1:c7:77:16:7d extern_learn NOARP proto zebra 
fe80::dc48:a3ff:fed1:a02c dev br-pe-110 lladdr de:48:a3:d1:a0:2c STALE 
```

### Bridge FDBs
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- bridge -color=never fdb show
33:33:00:00:00:01 dev red self permanent
01:00:5e:00:00:01 dev red self permanent
33:33:00:00:00:01 dev br-pe-100 self permanent
33:33:00:00:00:02 dev br-pe-100 self permanent
01:00:5e:00:00:6a dev br-pe-100 self permanent
33:33:00:00:00:6a dev br-pe-100 self permanent
01:00:5e:00:00:01 dev br-pe-100 self permanent
a2:c9:ec:91:98:9e dev vni100 vlan 1 extern_learn master br-pe-100 
a2:c9:ec:91:98:9e dev vni100 extern_learn master br-pe-100 
aa:bb:cc:00:00:65 dev vni100 vlan 1 extern_learn master br-pe-100 
aa:bb:cc:00:00:65 dev vni100 extern_learn master br-pe-100 
de:48:a3:d1:a0:2c dev vni100 vlan 1 extern_learn master br-pe-100 
de:48:a3:d1:a0:2c dev vni100 extern_learn master br-pe-100 
ce:15:1d:3a:67:df dev vni100 vlan 1 master br-pe-100 permanent
ce:15:1d:3a:67:df dev vni100 master br-pe-100 permanent
a2:c9:ec:91:98:9e dev vni100 dst 100.65.0.4 self extern_learn 
de:48:a3:d1:a0:2c dev vni100 dst 100.64.0.1 self extern_learn 
aa:bb:cc:00:00:65 dev vni100 dst 100.64.0.1 self extern_learn 
33:33:00:00:00:01 dev br-pe-110 self permanent
33:33:00:00:00:02 dev br-pe-110 self permanent
01:00:5e:00:00:6a dev br-pe-110 self permanent
33:33:00:00:00:6a dev br-pe-110 self permanent
01:00:5e:00:00:01 dev br-pe-110 self permanent
33:33:ff:35:cc:35 dev br-pe-110 self permanent
33:33:ff:00:00:00 dev br-pe-110 self permanent
02:79:38:33:33:33 dev vni110 vlan 1 extern_learn master br-pe-110 
02:79:38:33:33:33 dev vni110 extern_learn master br-pe-110 
66:c1:c7:77:16:7d dev vni110 vlan 1 extern_learn master br-pe-110 
66:c1:c7:77:16:7d dev vni110 extern_learn master br-pe-110 
00:f3:00:00:00:6f dev vni110 vlan 1 extern_learn master br-pe-110 permanent
00:f3:00:00:00:6f dev vni110 extern_learn master br-pe-110 permanent
de:48:a3:d1:a0:2c dev vni110 vlan 1 extern_learn master br-pe-110 
de:48:a3:d1:a0:2c dev vni110 extern_learn master br-pe-110 
46:85:e3:76:61:df dev vni110 vlan 1 master br-pe-110 permanent
46:85:e3:76:61:df dev vni110 master br-pe-110 permanent
00:00:00:00:00:00 dev vni110 dst 100.65.0.4 self permanent
00:00:00:00:00:00 dev vni110 dst 100.64.0.1 self permanent
66:c1:c7:77:16:7d dev vni110 dst 100.65.0.4 self extern_learn 
de:48:a3:d1:a0:2c dev vni110 dst 100.64.0.1 self extern_learn 
02:79:38:33:33:33 dev vni110 dst 100.65.0.4 self extern_learn 
00:f3:00:00:00:6f dev vni110 dst 100.65.0.4 self extern_learn 
33:33:00:00:00:01 dev ens4mvln self permanent
33:33:00:00:00:02 dev ens4mvln self permanent
01:00:5e:00:00:01 dev ens4mvln self permanent
33:33:ff:6a:53:04 dev ens4mvln self permanent
33:33:ff:00:00:00 dev ens4mvln self permanent
02:79:38:55:55:55 dev pe-110 master br-pe-110 
0a:af:1b:41:30:44 dev pe-110 master br-pe-110 
92:e5:c7:fe:01:59 dev pe-110 master br-pe-110 
26:5f:b7:79:f3:ca dev pe-110 vlan 1 master br-pe-110 permanent
26:5f:b7:79:f3:ca dev pe-110 master br-pe-110 permanent
33:33:00:00:00:01 dev pe-110 self permanent
33:33:00:00:00:02 dev pe-110 self permanent
01:00:5e:00:00:01 dev pe-110 self permanent
33:33:ff:79:f3:ca dev pe-110 self permanent
33:33:ff:00:00:00 dev pe-110 self permanent
```

## Routes vrf: [red]
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- ip -color=never route show vrf red
192.169.1.0/24 nhid 12 via 100.64.0.1 dev br-pe-100 proto bgp metric 20 onlink 
192.170.1.0/24 dev br-pe-110 proto kernel scope link src 192.170.1.1 
192.170.1.3 nhid 14 via 100.65.0.4 dev br-pe-100 proto bgp metric 20 onlink 
192.170.1.100 nhid 12 via 100.64.0.1 dev br-pe-100 proto bgp metric 20 onlink 
```

## Neighbors vrf [red]
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- ip -color=never neigh show vrf red
192.170.1.1 dev br-pe-110 lladdr 26:5f:b7:79:f3:ca extern_learn NOARP proto zebra 
100.64.0.1 dev br-pe-100 lladdr aa:bb:cc:00:00:65 extern_learn NOARP proto zebra 
192.170.1.100 dev br-pe-110 lladdr de:48:a3:d1:a0:2c extern_learn NOARP proto zebra 
192.170.1.3 dev br-pe-110 lladdr 02:79:38:33:33:33 extern_learn NOARP proto zebra 
192.170.1.100 dev br-pe-100 lladdr de:48:a3:d1:a0:2c extern_learn NOARP proto zebra 
192.170.1.5 dev br-pe-110 lladdr 02:79:38:55:55:55 STALE 
100.65.0.4 dev br-pe-100 lladdr a2:c9:ec:91:98:9e extern_learn NOARP proto zebra 
fe80::b8af:56ff:fe2f:a902 dev br-pe-110 lladdr a6:9d:bf:40:35:c3 STALE 
fe80::90e5:c7ff:fefe:159 dev br-pe-110 lladdr 92:e5:c7:fe:01:59 STALE 
fe80::64c1:c7ff:fe77:167d dev br-pe-110 lladdr 66:c1:c7:77:16:7d extern_learn NOARP proto zebra 
fe80::dc48:a3ff:fed1:a02c dev br-pe-110 lladdr de:48:a3:d1:a0:2c STALE 
```

## BGP IPv4 Summary
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show bgp ipv4'
BGP table version is 3, local router ID is 10.0.0.3, vrf id 0
Default local pref 100, local AS 64514
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

    Network          Next Hop            Metric LocPrf Weight Path
 *> 100.64.0.1/32    192.168.10.129           0             0 64512 i
 *  100.65.0.2/32    192.168.10.129                         0 64512 64514 i
 *>                  0.0.0.0                  0         32768 i
 *> 100.65.0.4/32    192.168.10.101                         0 64512 64514 i

Displayed  3 routes and 4 total paths
```

## BGP L2VPN EVPN Summary
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show bgp l2vpn evpn summary'
BGP router identifier 10.0.0.3, local AS number 64514 vrf-id 0
BGP table version 0
RIB entries 11, using 2112 bytes of memory
Peers 1, using 725 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.10.129  4      64512       227       224        0    0    0 01:41:11           10       18 N/A

Total number of neighbors 1
```

## EVPN Type-2 Routes
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show bgp l2vpn evpn route type 2'
BGP table version is 83, local router ID is 10.0.0.3
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
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[128]:[fe80::98b5:81ff:fe35:cc35]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[02:79:38:55:55:55]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[02:79:38:55:55:55]:[32]:[192.170.1.5]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:ce:15:1d:3a:67:df
 *> [2]:[0]:[48]:[0a:af:1b:41:30:44]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[92:e5:c7:fe:01:59]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[92:e5:c7:fe:01:59]:[128]:[fe80::90e5:c7ff:fefe:159]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
Route Distinguisher: 10.0.0.5:3
 *> [2]:[0]:[48]:[02:79:38:33:33:33]
                    100.65.0.4                             0 64512 64514 i
                    RT:64514:110 ET:8
 *> [2]:[0]:[48]:[02:79:38:33:33:33]:[32]:[192.170.1.3]
                    100.65.0.4                             0 64512 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:a2:c9:ec:91:98:9e
 *> [2]:[0]:[48]:[66:c1:c7:77:16:7d]
                    100.65.0.4                             0 64512 64514 i
                    RT:64514:110 ET:8
 *> [2]:[0]:[48]:[66:c1:c7:77:16:7d]:[128]:[fe80::64c1:c7ff:fe77:167d]
                    100.65.0.4                             0 64512 64514 i
                    RT:64514:110 ET:8
Route Distinguisher: 100.64.0.1:3
 *> [2]:[0]:[48]:[de:48:a3:d1:a0:2c]:[32]:[192.170.1.100]
                    100.64.0.1                             0 64512 i
                    RT:64512:100 RT:64512:110 ET:8 Rmac:aa:bb:cc:00:00:65

Displayed 11 prefixes (11 paths) (of requested type)
```

## EVPN Type-5 Routes
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show bgp l2vpn evpn route type 5'
BGP table version is 3, local router ID is 10.0.0.3
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
 *> [5]:[0]:[24]:[192.170.1.0]
                    100.65.0.2               0         32768 i
                    ET:8 RT:64514:100 Rmac:ce:15:1d:3a:67:df
Route Distinguisher: 10.0.0.5:2
 *> [5]:[0]:[24]:[192.170.1.0]
                    100.65.0.4                             0 64512 64514 i
                    RT:64514:100 ET:8 Rmac:a2:c9:ec:91:98:9e
Route Distinguisher: 192.170.1.100:1
 *> [5]:[0]:[24]:[192.169.1.0]
                    100.64.0.1               0             0 64512 ?
                    RT:64512:100 ET:8 Rmac:aa:bb:cc:00:00:65
 *> [5]:[0]:[24]:[192.170.1.0]
                    100.64.0.1               0             0 64512 ?
                    RT:64512:100 ET:8 Rmac:aa:bb:cc:00:00:65

Displayed 4 prefixes (4 paths) (of requested type)
```

## BGP Neighbors
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show bgp nei'
BGP neighbor is 192.168.10.129, remote AS 64512, local AS 64514, external link
  Local Role: undefined
  Remote Role: undefined
Hostname: 7516125557b5
  BGP version 4, remote router ID 100.64.0.1, local router ID 10.0.0.3
  BGP state = Established, up for 01:41:13
  Last read 00:00:13, Last write 00:00:13
  Hold time is 180 seconds, keepalive interval is 60 seconds
  Configured hold time is 180 seconds, keepalive interval is 60 seconds
  Configured conditional advertisements interval is 60 seconds
  Neighbor capabilities:
    4 Byte AS: advertised and received
    Extended Message: advertised and received
    AddPath:
      IPv4 Unicast: RX advertised and received
      L2VPN EVPN: RX advertised and received
    Long-lived Graceful Restart: advertised and received
      Address families by peer:
    Route refresh: advertised and received(new)
    Enhanced Route Refresh: advertised and received
    Address Family IPv4 Unicast: advertised and received
    Address Family L2VPN EVPN: advertised and received
    Hostname Capability: advertised (name: dev-worker-0.omergi,domain name: n/a) received (name: 7516125557b5,domain name: n/a)
    Graceful Restart Capability: advertised and received
      Remote Restart timer is 120 seconds
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
    IPv4 Unicast:
      F bit: False
      End-of-RIB sent: Yes
      End-of-RIB sent after update: No
      End-of-RIB received: Yes
      Timers:
        Configured Stale Path Time(sec): 360
  Message statistics:
    Inq depth is 0
    Outq depth is 0
                         Sent       Rcvd
    Opens:                  1          1
    Notifications:          0          0
    Updates:              121        124
    Keepalives:           102        102
    Route Refresh:          0          0
    Capability:             0          0
    Total:                224        227
  Minimum time between advertisement runs is 0 seconds

 For address family: IPv4 Unicast
  Update group 1, subgroup 1
  Packet Queue length 0
  Local AS allowed in path, 3 occurrences
  Community attribute sent to this neighbor(all)
  3 accepted prefixes

 For address family: L2VPN EVPN
  Update group 2, subgroup 2
  Packet Queue length 0
  Local AS allowed in path, 3 occurrences
  NEXT_HOP is propagated unchanged to this neighbor
  Community attribute sent to this neighbor(all)
  advertise-all-vni
  10 accepted prefixes

  Connections established 1; dropped 0
  Last reset 01:41:35,  Waiting for peer OPEN
  External BGP neighbor may be up to 1 hops away.
Local host: 192.168.10.100, Local port: 34934
Foreign host: 192.168.10.129, Foreign port: 179
Nexthop: 192.168.10.100
Nexthop global: fe80::18bc:97ff:fe6a:5304
Nexthop local: fe80::18bc:97ff:fe6a:5304
BGP connection: shared network
BGP Connect Retry Timer in Seconds: 120
Estimated round trip time: 0 ms
Read thread: on  Write thread: on  FD used: 21


```

### EVPN VNI Summary
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show evpn vni'
VNI        Type VxLAN IF              # MACs   # ARPs   # Remote VTEPs  Tenant VRF                           
110        L2   vni110                7        8        2               red                                  
100        L3   vni100                2        2        n/a             red                                  
```

### EVPN VNI [110]
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show evpn vni 110 json'
{
  "vni":110,
  "type":"L2",
  "vrf":"red",
  "vxlanInterface":"vni110",
  "ifindex":81,
  "sviInterface":"br-pe-110",
  "sviIfindex":80,
  "vtepIp":"100.65.0.2",
  "mcastGroup":"0.0.0.0",
  "advertiseGatewayMacip":"No",
  "advertiseSviMacip":"No",
  "numMacs":7,
  "numArpNd":8,
  "numRemoteVteps":[
    "100.64.0.1",
    "100.65.0.4"
  ]
}
```

### EVPN VNI [100]
```bash
$ oc -n openshift-openperouter exec -it router-lf7fw -- vtysh -c 'show evpn vni 100 json'
{
  "vni":100,
  "type":"L3",
  "localVtepIp":"100.65.0.2",
  "vxlanIntf":"vni100",
  "sviIntf":"br-pe-100",
  "state":"Up",
  "vrf":"red",
  "sysMac":"ce:15:1d:3a:67:df",
  "routerMac":"ce:15:1d:3a:67:df",
  "vniFilter":"none",
  "l2Vnis":[
    110
  ]
}
```

