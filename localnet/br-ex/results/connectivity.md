# Connectivity Results

## Test Pods

```
$ oc get pods -n evpn-localnet-test -o wide
NAME               READY   STATUS    RESTARTS   AGE     IP            NODE                                NOMINATED NODE   READINESS GATES
test-localnet-w1   1/1     Running   0          2d20h   10.134.0.24   multi-homing-worker-0.ralavi.corp   <none>           <none>
test-localnet-w2   1/1     Running   0          2d20h   10.133.0.31   multi-homing-worker-1.ralavi.corp   <none>           <none>
```

## Pod Interfaces

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ip addr show net1
3: net1@if38: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP group default qlen 1000
    link/ether 0a:58:c0:aa:01:0a brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.170.1.10/24 brd 192.170.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fd00::a:1/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::858:c0ff:feaa:10a/64 scope link 
       valid_lft forever preferred_lft forever

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

## Primary Network (cross-worker pod-to-pod)

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ping -c 3 -W 2 10.133.0.31
PING 10.133.0.31 (10.133.0.31) 56(84) bytes of data.
64 bytes from 10.133.0.31: icmp_seq=1 ttl=62 time=6.24 ms
64 bytes from 10.133.0.31: icmp_seq=2 ttl=62 time=2.89 ms
64 bytes from 10.133.0.31: icmp_seq=3 ttl=62 time=1.02 ms

--- 10.133.0.31 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2002ms
rtt min/avg/max/mdev = 1.016/3.382/6.240/2.160 ms
```

## Cross-Worker Localnet — IPv4 (pod-to-pod via EVPN/VXLAN on 192.170.1.0/24)

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ping -c 3 -W 2 192.170.1.20
PING 192.170.1.20 (192.170.1.20) 56(84) bytes of data.
64 bytes from 192.170.1.20: icmp_seq=1 ttl=64 time=3.11 ms
64 bytes from 192.170.1.20: icmp_seq=2 ttl=64 time=0.799 ms
64 bytes from 192.170.1.20: icmp_seq=3 ttl=64 time=0.616 ms

--- 192.170.1.20 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2062ms
rtt min/avg/max/mdev = 0.616/1.508/3.110/1.135 ms
```

## Cross-Worker Localnet — IPv6 (pod-to-pod via EVPN/VXLAN on fd00::a:x/64)

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ping6 -c 3 -W 2 fd00::a:2
PING fd00::a:2 (fd00::a:2) 56 data bytes
64 bytes from fd00::a:2: icmp_seq=1 ttl=64 time=2.69 ms
64 bytes from fd00::a:2: icmp_seq=2 ttl=64 time=1.09 ms
64 bytes from fd00::a:2: icmp_seq=3 ttl=64 time=0.484 ms

--- fd00::a:2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.484/1.421/2.690/0.930 ms
```

## Stretched L2 — External FRR to Pod (via br110/VNI 110 VXLAN tunnel)

The external FRR (192.170.1.100) pings pods directly on the same L2 segment via
br110/VNI 110. TTL=64 confirms same-L2 (no L3 hop).

```
$ podman exec frr ping -c 3 -W 3 -I br110 192.170.1.10
PING 192.170.1.10 (192.170.1.10): 56 data bytes
64 bytes from 192.170.1.10: seq=0 ttl=64 time=2.448 ms
64 bytes from 192.170.1.10: seq=1 ttl=64 time=0.297 ms
64 bytes from 192.170.1.10: seq=2 ttl=64 time=0.568 ms

--- 192.170.1.10 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.297/1.104/2.448 ms

$ podman exec frr ping -c 3 -W 3 -I br110 192.170.1.20
PING 192.170.1.20 (192.170.1.20): 56 data bytes
64 bytes from 192.170.1.20: seq=0 ttl=64 time=3.639 ms
64 bytes from 192.170.1.20: seq=1 ttl=64 time=0.330 ms
64 bytes from 192.170.1.20: seq=2 ttl=64 time=0.407 ms

--- 192.170.1.20 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.330/1.458/3.639 ms
```

## L3 Routing — External Client to Pod (cross-subnet via L3VNI)

```
$ podman exec external-client ping -c 3 -W 5 192.170.1.10
PING 192.170.1.10 (192.170.1.10): 56 data bytes
64 bytes from 192.170.1.10: seq=0 ttl=62 time=0.331 ms
64 bytes from 192.170.1.10: seq=1 ttl=62 time=0.585 ms
64 bytes from 192.170.1.10: seq=2 ttl=62 time=0.550 ms

--- 192.170.1.10 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.331/0.488/0.585 ms

$ podman exec external-client ping -c 3 -W 5 192.170.1.20
PING 192.170.1.20 (192.170.1.20): 56 data bytes
64 bytes from 192.170.1.20: seq=0 ttl=62 time=2.132 ms
64 bytes from 192.170.1.20: seq=1 ttl=62 time=0.595 ms
64 bytes from 192.170.1.20: seq=2 ttl=62 time=0.570 ms

--- 192.170.1.20 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.570/1.099/2.132 ms
```
