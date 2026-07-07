# external-client

```bash
$ podman ps | grep external-client
206284b6a9f2  registry.k8s.io/e2e-test-images/agnhost:2.45  netexec     2 hours ago  Up 2 hours  80/tcp, 5000/tcp, 8080-8081/tcp, 9376/tcp  external-client
```

## Addresses
```bash
$ podman exec -it external-client ip -color=never addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0@if2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 9000 qdisc noqueue state UP group default qlen 1000
    link/ether 72:27:70:1f:b5:ad brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 192.169.1.129/24 brd 192.169.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::7027:70ff:fe1f:b5ad/64 scope link 
       valid_lft forever preferred_lft forever
```

## Routes
```bash
$ podman exec -it external-client ip -color=never route
default via 192.169.1.1 dev eth0 proto static metric 100 
192.169.1.0/24 dev eth0 proto kernel scope link src 192.169.1.129 
```

## Neighbors
```bash
$ podman exec -it external-client ip -color=never nei
192.169.1.1 dev eth0 lladdr 46:80:c0:e5:fa:7f REACHABLE
fe80::ee94:d500:99f1:1300 dev eth0 lladdr ec:94:d5:f1:13:00 router STALE
fe80::ee94:d500:99f0:e600 dev eth0 lladdr ec:94:d5:f0:e6:00 router STALE
fe80::200:5eff:fe00:201 dev eth0 lladdr 00:00:5e:00:02:01 router STALE
```

### Bridge FDBs
```bash
$ podman exec -it external-client bridge -color=never fdb show
33:33:00:00:00:01 dev eth0 self permanent
01:00:5e:00:00:01 dev eth0 self permanent
33:33:ff:1f:b5:ad dev eth0 self permanent
```

