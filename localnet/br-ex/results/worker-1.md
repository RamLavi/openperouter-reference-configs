# Worker-1 Results

## BGP L2VPN EVPN Summary

```
$ oc exec -n openshift-openperouter router-85tns -c frr -- vtysh -c "show bgp l2vpn evpn summary"
BGP router identifier 10.0.0.3, local AS number 64514 vrf-id 0
BGP table version 0
RIB entries 9, using 1728 bytes of memory
Peers 1, using 725 KiB of memory

Neighbor        V         AS   MsgRcvd   MsgSent   TblVer  InQ OutQ  Up/Down State/PfxRcd   PfxSnt Desc
10.100.11.4     4      64512        21        21        0    0    0 00:03:49            8       17 N/A

Total number of neighbors 1
```

## EVPN Type-2 Routes

```
# oc exec -n openshift-openperouter router-85tns -c frr -- vtysh -c "show bgp l2vpn evpn route type 2"
BGP table version is 7, local router ID is 10.0.0.3
Status codes: s suppressed, d damped, h history, * valid, > best, i - internal
Origin codes: i - IGP, e - EGP, ? - incomplete
EVPN type-1 prefix: [1]:[EthTag]:[ESI]:[IPlen]:[VTEP-IP]:[Frag-id]
EVPN type-2 prefix: [2]:[EthTag]:[MAClen]:[MAC]:[IPlen]:[IP]
EVPN type-3 prefix: [3]:[EthTag]:[IPlen]:[OrigIP]
EVPN type-4 prefix: [4]:[ESI]:[IPlen]:[OrigIP]
EVPN type-5 prefix: [5]:[EthTag]:[IPlen]:[IP]

   Network          Next Hop            Metric LocPrf Weight Path
                    Extended Community
Route Distinguisher: 10.0.0.2:3
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:0a]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:110 ET:8
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:0a]:[32]:[192.170.1.10]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:100 RT:64514:110 ET:8 Rmac:4e:55:1a:61:2b:35
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:0a]:[128]:[fe80::858:c0ff:feaa:10a]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:110 ET:8
 *> [2]:[0]:[48]:[2a:46:53:2f:a0:4e]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:110 ET:8
 *> [2]:[0]:[48]:[b6:9c:5a:f8:b9:2c]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:110 ET:8
 *> [2]:[0]:[48]:[b6:9c:5a:f8:b9:2c]:[128]:[fe80::b49c:5aff:fef8:b92c]
                    100.65.0.1                             0 64512 64514 i
                    RT:64514:110 ET:8
Route Distinguisher: 10.0.0.3:3
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[32]:[192.170.1.1]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:76:9d:b9:fb:a3:ea
 *> [2]:[0]:[48]:[00:f3:00:00:00:6f]:[128]:[fe80::b8d5:a0ff:fe1e:7b42]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:14]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[0a:58:c0:aa:01:14]:[32]:[192.170.1.20]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110 RT:64514:100 Rmac:76:9d:b9:fb:a3:ea
 *> [2]:[0]:[48]:[ba:dc:74:75:10:4b]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[d2:43:2d:36:c9:c2]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
 *> [2]:[0]:[48]:[d2:43:2d:36:c9:c2]:[128]:[fe80::d043:2dff:fe36:c9c2]
                    100.65.0.2                         32768 i
                    ET:8 RT:64514:110
Route Distinguisher: 100.64.0.1:3
 *> [2]:[0]:[48]:[da:4b:69:61:f5:f1]:[32]:[192.170.1.100]
                    100.64.0.1                             0 64512 i
                    RT:64512:100 RT:64512:110 ET:8 Rmac:aa:bb:cc:00:00:65

Displayed 14 prefixes (14 paths) (of requested type)

```

## Pod Interface

```
$ oc exec -n evpn-localnet-test test-localnet-w2 -- ip addr show net1
3: net1@if45: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP group default qlen 1000
    link/ether 0a:58:c0:aa:01:14 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.170.1.20/24 brd 192.170.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fd00::a:2/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::858:c0ff:feaa:114/64 scope link 
       valid_lft forever preferred_lft forever
```
