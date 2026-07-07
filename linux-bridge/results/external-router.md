# external router

```bash
$ podman ps | grep frr
c7bc6c31138a  localhost/frr-router:latest                               28 minutes ago  Up 28 minutes                                             frr
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
2: eth1@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
    link/ether 0e:a3:82:a7:9b:77 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.168.10.129/24 brd 192.168.10.255 scope global eth1
       valid_lft forever preferred_lft forever
    inet6 fe80::ca3:82ff:fea7:9b77/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
3: eth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP group default qlen 1000
    link/ether 92:23:ca:08:e3:c0 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.169.1.3/24 brd 192.169.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::9023:caff:fe08:e3c0/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
4: red: <NOARP,MASTER,UP,LOWER_UP> mtu 65575 qdisc noqueue state UP group default qlen 1000
    link/ether 9e:41:06:bc:49:4c brd ff:ff:ff:ff:ff:ff
5: br100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
    link/ether aa:bb:cc:00:00:65 brd ff:ff:ff:ff:ff:ff
6: vni100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br100 state UNKNOWN group default qlen 1000
    link/ether 36:27:57:6c:63:0a brd ff:ff:ff:ff:ff:ff
7: vni110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br110 state UNKNOWN group default qlen 1000
    link/ether 32:04:ae:65:a4:45 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3004:aeff:fe65:a445/64 scope link proto kernel_ll 
       valid_lft forever preferred_lft forever
8: br110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master red state UP group default qlen 1000
    link/ether 32:04:ae:65:a4:45 brd ff:ff:ff:ff:ff:ff
```

## Routes
```bash
$ podman exec -it frr ip -color=never route
default via 192.169.1.1 dev eth0 proto static metric 100 
192.169.1.0/24 dev eth0 proto kernel scope link src 192.169.1.3 
```

## BGP IPv4 Summary
```bash
$ podman exec -it frr vtysh -c 'show bgp ipv4'
BGP table version is 1, local router ID is 100.64.0.1, vrf id 0
Default local pref 100, local AS 64512
Status codes:  s suppressed, d damped, h history, u unsorted, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

     Network          Next Hop            Metric LocPrf Weight Path
 *>  100.64.0.1/32    0.0.0.0                  0         32768 i

Displayed 1 routes and 1 total paths
```

## BGP L2VPN EVPN Summary
```bash
$ podman exec -it frr vtysh -c 'show bgp l2vpn evpn summary'
BGP router identifier 100.64.0.1, local AS number 64512 VRF default vrf-id 0
BGP table version 0
RIB entries 3, using 456 bytes of memory
Peers 2, using 33 KiB of memory
Peer groups 2, using 128 bytes of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.10.31   4      64514         0         0        0    0    0    never       Active        0 N/A
192.168.10.245  4      64514         0         0        0    0    0    never       Active        0 N/A

Total number of neighbors 2
```

## EVPN Type-2 Routes
```bash
$ podman exec -it frr vtysh -c 'show bgp l2vpn evpn route type 2'
No EVPN prefixes (of requested type) exist
```

## EVPN Type-5 Routes
```bash
$ podman exec -it frr vtysh -c 'show bgp l2vpn evpn route type 5'
BGP table version is 1, local router ID is 100.64.0.1
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 192.168.10.129:1
 *>  [5]:[0]:[24]:[192.168.10.0] RD 192.168.10.129:1
                    100.64.0.1               0         32768 ?
                    ET:8 RT:64512:100 Rmac:aa:bb:cc:00:00:65

Displayed 1 prefixes (1 paths) (of requested type)
```

## BGP Neighbors
```bash
$ podman exec -it frr vtysh -c 'show bgp nei'
BGP neighbor is 192.168.10.31, remote AS 64514, local AS 64512, external link
  Local Role: undefined
  Remote Role: undefined
  BGP version 4, remote router ID 0.0.0.0, local router ID 100.64.0.1
  BGP state = Active
  Last read 00:28:58, Last write never
  Hold time is 180 seconds, keepalive interval is 60 seconds
  Configured hold time is 180 seconds, keepalive interval is 60 seconds
  Configured tcp-mss is 0, synced tcp-mss is 0
  Configured conditional advertisements interval is 60 seconds
  Graceful restart information:
    Local GR Mode: Helper*
    Remote GR Mode: NotApplicable

    R bit: False
    N bit: False
    Timers:
      Configured Restart Time(sec): 120
      Received Restart Time(sec): 0
      Configured LLGR Stale Path Time(sec): 0
  Message statistics:
    Inq depth is 0
    Outq depth is 0
                         Sent       Rcvd
    Opens:                  0          0
    Notifications:          0          0
    Updates:                0          0
    Keepalives:             0          0
    Route Refresh:          0          0
    Capability:             0          0
    Total:                  0          0

  Prefix statistics:
    Inbound filtered: 0
    AS-PATH loop: 0
    Originator loop: 0
    Cluster loop: 0
    Invalid next-hop: 0
    Withdrawn: 0
    Attributes discarded: 0

  Minimum time between advertisement runs is 0 seconds
  Update delay timer is 0 seconds (remaining: 0)

 For address family: IPv4 Unicast
  Not part of any update group
  Community attribute sent to this neighbor(all)
  0 accepted prefixes

 For address family: L2VPN EVPN
  Not part of any update group
  Local AS allowed as path origin
  NEXT_HOP is propagated unchanged to this neighbor
  Community attribute sent to this neighbor(all)
  advertise-all-vni
  0 accepted prefixes

  Connections established 0; dropped 0
  Last reset 00:28:58,  No path to specified Neighbor (n/a)
  External BGP neighbor may be up to 1 hops away.
BGP Connect Retry Timer in Seconds: 120
Next connect timer due in 32 seconds
Read thread: off  Write thread: off  FD used: -1

BGP neighbor is 192.168.10.245, remote AS 64514, local AS 64512, external link
  Local Role: undefined
  Remote Role: undefined
  BGP version 4, remote router ID 0.0.0.0, local router ID 100.64.0.1
  BGP state = Active
  Last read 00:28:58, Last write never
  Hold time is 180 seconds, keepalive interval is 60 seconds
  Configured hold time is 180 seconds, keepalive interval is 60 seconds
  Configured tcp-mss is 0, synced tcp-mss is 0
  Configured conditional advertisements interval is 60 seconds
  Graceful restart information:
    Local GR Mode: Helper*
    Remote GR Mode: NotApplicable

    R bit: False
    N bit: False
    Timers:
      Configured Restart Time(sec): 120
      Received Restart Time(sec): 0
      Configured LLGR Stale Path Time(sec): 0
  Message statistics:
    Inq depth is 0
    Outq depth is 0
                         Sent       Rcvd
    Opens:                  0          0
    Notifications:          0          0
    Updates:                0          0
    Keepalives:             0          0
    Route Refresh:          0          0
    Capability:             0          0
    Total:                  0          0

  Prefix statistics:
    Inbound filtered: 0
    AS-PATH loop: 0
    Originator loop: 0
    Cluster loop: 0
    Invalid next-hop: 0
    Withdrawn: 0
    Attributes discarded: 0

  Minimum time between advertisement runs is 0 seconds
  Update delay timer is 0 seconds (remaining: 0)

 For address family: IPv4 Unicast
  Not part of any update group
  Community attribute sent to this neighbor(all)
  0 accepted prefixes

 For address family: L2VPN EVPN
  Not part of any update group
  Local AS allowed as path origin
  NEXT_HOP is propagated unchanged to this neighbor
  Community attribute sent to this neighbor(all)
  advertise-all-vni
  0 accepted prefixes

  Connections established 0; dropped 0
  Last reset 00:28:58,  No path to specified Neighbor (n/a)
  External BGP neighbor may be up to 1 hops away.
BGP Connect Retry Timer in Seconds: 120
Next connect timer due in 32 seconds
Read thread: off  Write thread: off  FD used: -1


```

