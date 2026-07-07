# worker-1

```bash
$ oc -n openshift-openperouter get po router-d88bs -o wide
NAME           READY   STATUS    RESTARTS   AGE   IP                NODE                  NOMINATED NODE   READINESS GATES
router-d88bs   2/2     Running   0          9d    192.168.122.212   dev-worker-1.omergi   <none>           <none>
```

## Addresses
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- ip -color=never addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet 100.65.0.4/32 scope global lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
3: ens4: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group 4242 qlen 1000
    link/ether 52:54:00:bb:9a:41 brd ff:ff:ff:ff:ff:ff
    altname enp0s4
    inet 192.168.10.245/24 brd 192.168.10.255 scope global dynamic ens4
       valid_lft 1840sec preferred_lft 1840sec
    inet6 fe80::82d0:4494:9089:a800/64 scope link 
       valid_lft forever preferred_lft forever
    inet6 fe80::5054:ff:febb:9a41/64 scope link 
       valid_lft forever preferred_lft forever
190: red: <NOARP,MASTER,UP,LOWER_UP> mtu 65575 qdisc noqueue state UP group default 
    link/ether ba:3a:e1:ea:1e:29 brd ff:ff:ff:ff:ff:ff
191: br-pe-100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65486 qdisc noqueue master red state UP group default 
    link/ether 36:01:82:b4:ae:c5 brd ff:ff:ff:ff:ff:ff
192: vni100: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65486 qdisc noqueue master br-pe-100 state UNKNOWN group default 
    link/ether 36:01:82:b4:ae:c5 brd ff:ff:ff:ff:ff:ff
193: br-pe-110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master red state UP group default 
    link/ether 00:f3:00:00:00:6f brd ff:ff:ff:ff:ff:ff
    inet 192.170.1.1/24 brd 192.170.1.255 scope global br-pe-110
       valid_lft forever preferred_lft forever
    inet6 fe80::88b3:1aff:fe9a:482b/64 scope link 
       valid_lft forever preferred_lft forever
194: vni110: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 65486 qdisc noqueue master br-pe-110 state UNKNOWN group default 
    link/ether 16:42:58:4e:38:47 brd ff:ff:ff:ff:ff:ff
7697: pe-110@if7698: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master br-pe-110 state UP group default 
    link/ether 32:4b:27:39:4a:40 brd ff:ff:ff:ff:ff:ff link-netns 07e1142e-83c4-45a2-a592-86d312f0632f
    inet6 fe80::304b:27ff:fe39:4a40/64 scope link 
       valid_lft forever preferred_lft forever
```

## Routes
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- ip -color=never route
192.168.10.0/24 dev ens4 proto kernel scope link src 192.168.10.245 
```

## BGP IPv4 Summary
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- vtysh -c 'show bgp ipv4'
BGP table version is 1, local router ID is 10.0.0.5, vrf id 0
Default local pref 100, local AS 64514
Status codes:  s suppressed, d damped, h history, * valid, > best, = multipath,
               i internal, r RIB-failure, S Stale, R Removed
Nexthop codes: @NNN nexthop's vrf id, < announce-nh-self
Origin codes:  i - IGP, e - EGP, ? - incomplete
RPKI validation codes: V valid, I invalid, N Not found

    Network          Next Hop            Metric LocPrf Weight Path
 *> 100.65.0.4/32    0.0.0.0                  0         32768 i

Displayed  1 routes and 1 total paths
```

## BGP L2VPN EVPN Summary
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- vtysh -c 'show bgp l2vpn evpn summary'
BGP router identifier 10.0.0.5, local AS number 64514 vrf-id 0
BGP table version 0
RIB entries 3, using 576 bytes of memory
Peers 1, using 725 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.169.1.3     4      64512         0         0        0    0    0    never       Active        0 N/A

Total number of neighbors 1
```

## EVPN Type-2 Routes
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- vtysh -c 'show bgp l2vpn evpn route type 2'
BGP table version is 18, local router ID is 10.0.0.5
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.5:3
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:36:01:82:b4:ae:c5
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[128]:[fe80::88b3:1aff:fe9a:482b]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[02:79:38:3e:18:4a]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[02:79:38:3e:18:4a]:[32]:[192.170.0.5]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:36:01:82:b4:ae:c5
 *> [2]:[0]:[48]:[12:ee:8b:59:b1:0a]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[52:4a:cd:04:a0:9c]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[5a:04:6d:aa:91:4e]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[66:ed:d6:03:6a:11]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[66:ed:d6:03:6a:11]:[128]:[fe80::64ed:d6ff:fe03:6a11]
                    100.65.0.4                         32768 i
                    ET:8 RT:64514:110

Displayed 9 prefixes (9 paths) (of requested type)
```

## EVPN Type-5 Routes
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- vtysh -c 'show bgp l2vpn evpn route type 5'
BGP table version is 3, local router ID is 10.0.0.5
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.5:2
 *> [5]:[0]:[24]:[192.170.1.0]
                    100.65.0.4               0         32768 i
                    ET:8 RT:64514:100 Rmac:36:01:82:b4:ae:c5

Displayed 1 prefixes (1 paths) (of requested type)
```

## BGP Neighbors
```bash
$ oc -n openshift-openperouter exec -it router-d88bs -- vtysh -c 'show bgp nei'
BGP neighbor is 192.169.1.3, remote AS 64512, local AS 64514, external link
  Local Role: undefined
  Remote Role: undefined
  BGP version 4, remote router ID 0.0.0.0, local router ID 10.0.0.5
  BGP state = Active
  Last read 00:29:14, Last write never
  Hold time is 180 seconds, keepalive interval is 60 seconds
  Configured hold time is 180 seconds, keepalive interval is 60 seconds
  Configured conditional advertisements interval is 60 seconds
  Graceful restart information:
    Local GR Mode: Helper*

    Remote GR Mode: NotApplicable

    R bit: False
    N bit: False
    Timers:
      Configured Restart Time(sec): 120
      Received Restart Time(sec): 0
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
  Minimum time between advertisement runs is 0 seconds

 For address family: IPv4 Unicast
  Not part of any update group
  Local AS allowed in path, 3 occurrences
  Community attribute sent to this neighbor(all)
  0 accepted prefixes

 For address family: L2VPN EVPN
  Not part of any update group
  Local AS allowed in path, 3 occurrences
  NEXT_HOP is propagated unchanged to this neighbor
  Community attribute sent to this neighbor(all)
  advertise-all-vni
  0 accepted prefixes

  Connections established 0; dropped 0
  Last reset 00:29:14,  No path to specified Neighbor
  External BGP neighbor may be up to 1 hops away.
BGP Connect Retry Timer in Seconds: 120
Next connect timer due in 47 seconds
Read thread: off  Write thread: off  FD used: -1


```

