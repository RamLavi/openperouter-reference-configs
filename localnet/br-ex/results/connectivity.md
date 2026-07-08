# Connectivity Results

## Test Pods

```
$ oc get pods -n evpn-localnet-test -o wide
NAME               READY   STATUS    RESTARTS   AGE   IP            NODE                                NOMINATED NODE   READINESS GATES
test-localnet-w1   1/1     Running   0          3d    10.133.0.9    multi-homing-worker-0.ralavi.corp   <none>           <none>
test-localnet-w2   1/1     Running   0          3d    10.134.0.82   multi-homing-worker-1.ralavi.corp   <none>           <none>
```

## Pod Interfaces

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ip addr show net1
3: net1@if72: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc noqueue state UP group default qlen 1000
    link/ether 0a:58:c0:aa:01:0a brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.170.1.10/24 brd 192.170.1.255 scope global net1
       valid_lft forever preferred_lft forever
    inet6 fd00::a:1/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::858:c0ff:feaa:10a/64 scope link 
       valid_lft forever preferred_lft forever

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

## Primary Network (cross-worker pod-to-pod)

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ping -c 3 -W 2 10.134.0.82
PING 10.134.0.82 (10.134.0.82) 56(84) bytes of data.
64 bytes from 10.134.0.82: icmp_seq=1 ttl=62 time=7.41 ms
64 bytes from 10.134.0.82: icmp_seq=2 ttl=62 time=3.82 ms
64 bytes from 10.134.0.82: icmp_seq=3 ttl=62 time=1.25 ms

--- 10.134.0.82 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 1.252/4.158/7.407/2.524 ms
```

## Cross-Worker Localnet — IPv4 (pod-to-pod via EVPN/VXLAN on 192.170.1.0/24)

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ping -c 3 -W 2 192.170.1.20
PING 192.170.1.20 (192.170.1.20) 56(84) bytes of data.
64 bytes from 192.170.1.20: icmp_seq=1 ttl=64 time=3.85 ms
64 bytes from 192.170.1.20: icmp_seq=2 ttl=64 time=1.30 ms
64 bytes from 192.170.1.20: icmp_seq=3 ttl=64 time=1.06 ms

--- 192.170.1.20 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2004ms
rtt min/avg/max/mdev = 1.058/2.070/3.848/1.261 ms
```

## Cross-Worker Localnet — IPv6 (pod-to-pod via EVPN/VXLAN on fd00::a:x/64)

```
$ oc exec -n evpn-localnet-test test-localnet-w1 -- ping6 -c 3 -W 2 fd00::a:2
PING fd00::a:2 (fd00::a:2) 56 data bytes
64 bytes from fd00::a:2: icmp_seq=1 ttl=64 time=3.56 ms
64 bytes from fd00::a:2: icmp_seq=2 ttl=64 time=1.17 ms
64 bytes from fd00::a:2: icmp_seq=3 ttl=64 time=0.937 ms

--- fd00::a:2 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2003ms
rtt min/avg/max/mdev = 0.937/1.890/3.562/1.186 ms
```

## Stretched L2 — External FRR to Pod (via br110/VNI 110 VXLAN tunnel)

```
$ podman exec frr ping -c 2 -W 3 -I br110 192.170.1.10
PING 192.170.1.10 (192.170.1.10): 56 data bytes
64 bytes from 192.170.1.10: seq=0 ttl=64 time=2.600 ms
64 bytes from 192.170.1.10: seq=1 ttl=64 time=0.655 ms

--- 192.170.1.10 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.655/1.627/2.600 ms

$ podman exec frr ping -c 2 -W 3 -I br110 192.170.1.20
PING 192.170.1.20 (192.170.1.20): 56 data bytes
64 bytes from 192.170.1.20: seq=0 ttl=64 time=2.043 ms
64 bytes from 192.170.1.20: seq=1 ttl=64 time=0.623 ms

--- 192.170.1.20 ping statistics ---
2 packets transmitted, 2 packets received, 0% packet loss
round-trip min/avg/max = 0.623/1.333/2.043 ms
```

## L3 Routing — External Client to Pod (cross-subnet via L3VNI)

```
$ podman exec external-client ping -c 3 -W 5 192.170.1.10
PING 192.170.1.10 (192.170.1.10): 56 data bytes
64 bytes from 192.170.1.10: seq=0 ttl=62 time=0.593 ms
64 bytes from 192.170.1.10: seq=1 ttl=62 time=0.716 ms
64 bytes from 192.170.1.10: seq=2 ttl=62 time=0.566 ms

--- 192.170.1.10 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.566/0.625/0.716 ms

$ podman exec external-client ping -c 3 -W 5 192.170.1.20
PING 192.170.1.20 (192.170.1.20): 56 data bytes
64 bytes from 192.170.1.20: seq=0 ttl=62 time=0.826 ms
64 bytes from 192.170.1.20: seq=1 ttl=62 time=0.573 ms
64 bytes from 192.170.1.20: seq=2 ttl=62 time=0.691 ms

--- 192.170.1.20 ping statistics ---
3 packets transmitted, 3 packets received, 0% packet loss
round-trip min/avg/max = 0.573/0.696/0.826 ms
```
