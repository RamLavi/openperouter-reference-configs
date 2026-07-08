# Worker-1 Results

## macvlan0 (on br-ex)

```
$ oc exec -n openshift-openperouter router-qwzsj -c frr -- ip addr show macvlan0
4217: macvlan0@if7: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group 4242 qlen 1000
    link/ether e6:6b:da:a4:c9:92 brd ff:ff:ff:ff:ff:ff link-netns 34e15f3d-dacc-4783-9e3b-c7f6e5615573
    inet 192.168.122.211/24 scope global macvlan0
       valid_lft forever preferred_lft forever
    inet6 fe80::e46b:daff:fea4:c992/64 scope link 
       valid_lft forever preferred_lft forever
```

## BGP L2VPN EVPN Summary

```
$ oc exec -n openshift-openperouter router-qwzsj -c frr -- vtysh -c "show bgp l2vpn evpn summary"
BGP router identifier 10.0.0.3, local AS number 64514 vrf-id 0
BGP table version 0
RIB entries 11, using 2112 bytes of memory
Peers 1, using 725 KiB of memory

Neighbor         V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
192.168.122.201  4      64512        28        26        0    0    0 00:05:43           11       20 N/A

Total number of neighbors 1
```

## EVPN Type-2 Routes

```
$ oc exec -n openshift-openperouter router-qwzsj -c frr -- vtysh -c "show bgp l2vpn evpn route type 2"
BGP table version is 6, local router ID is 10.0.0.3
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.2:3
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:0a]:[32]:[192.170.1.10]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:3a:40:d7:b9:35:3b
Route Distinguisher: 10.0.0.3:3
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:f6:81:21:43:e9:2d
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:14]:[32]:[192.170.1.20]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:f6:81:21:43:e9:2d
Route Distinguisher: 100.64.0.1:3
 *> [2]:[0]:[48]:[9a:77:23:36:f5:5a]:[32]:[192.170.1.100]
                    100.64.0.1                             0 64512 i
                    RT:64512:100 RT:64512:110 ET:8 Rmac:aa:bb:cc:00:00:65

Displayed 13 prefixes (13 paths) (of requested type)
```

## Pod Interface

```
$ oc exec -n evpn-localnet-test test-localnet-w2 -- ip addr show net1
3: net1@if2000: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP group default qlen 1000
    link/ether 0a:58:c0:aa:01:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.170.1.20/24 brd 192.170.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fd00::a:2/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::858:c0ff:feaa:114/64 scope link 
       valid_lft forever preferred_lft forever
```
