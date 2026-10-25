# 2026-10-25 14:28:10 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface vlan
add interface=ether4 name=vlan10 vlan-id=10
add interface=ether3 name=vlan20 vlan-id=20
/interface vrrp
add authentication=simple interface=vlan10 name=vrrp10 version=2 vrid=10
add authentication=simple interface=vlan20 name=vrrp20 priority=150 version=2 \
    vrid=20
/routing ospf instance
add name=ospf1 router-id=7.7.7.7
/routing ospf area
add instance=ospf1 name=backbone
/user group
add name=superadmin policy="local,telnet,ssh,ftp,reboot,read,write,policy,test\
    ,winbox,password,web,sniff,sensitive,api,romon,rest-api"
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=7.7.7.7 comment="Loopback / Router-ID" interface=lo network=\
    7.7.7.7
add address=10.30.2.2/30 comment=DIST-2-CORE-1 interface=ether1 network=\
    10.30.2.0
add address=10.30.4.2/30 comment=DIST-2-CORE-2 interface=ether2 network=\
    10.30.4.0
add address=192.168.10.3/24 interface=vlan10 network=192.168.10.0
add address=192.168.20.3/24 interface=vlan20 network=192.168.20.0
add address=192.168.10.1 comment="VIP VLAN10 USERS" interface=vrrp10 network=\
    192.168.10.1
add address=192.168.20.1 comment="VIP VLAN20 SERVERS" interface=vrrp20 \
    network=192.168.20.1
/ip dhcp-client
add interface=ether1 name=client1
/ip service
set ftp disabled=yes
set ssh available-from=10.0.0.0/8,192.168.0.0/16
set telnet disabled=yes
set www disabled=yes
set winbox available-from=10.0.0.0/8,192.168.0.0/16
set api disabled=yes
set api-ssl disabled=yes
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 interfaces=ether1,ether2
add area=backbone interfaces=vlan10,vlan20 passive
add area=backbone interfaces=lo passive
/system identity
set name=DIST-2