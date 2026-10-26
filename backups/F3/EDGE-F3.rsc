# 2026-10-26 05:59:44 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface list
add name=WAN
/routing bgp instance
add as=65000 disabled=no name=bgp1 router-id=3.3.3.3
/routing ospf instance
add name=ospf1 originate-default=if-installed router-id=3.3.3.3
/routing ospf area
add instance=ospf1 name=backbone
/user group
add name=superadmin policy="local,telnet,ssh,ftp,reboot,read,write,policy,test\
    ,winbox,password,web,sniff,sensitive,api,romon,rest-api"
/ip neighbor discovery-settings
set discover-interface-list=none
/interface list member
add interface=ether1 list=WAN
add interface=ether2 list=WAN
/ip address
add address=3.3.3.3 comment="Loopback / Router-ID" interface=lo network=\
    3.3.3.3
add address=10.100.1.2/30 comment="WAN ISP-1" interface=ether1 network=\
    10.100.1.0
add address=10.200.1.2/30 comment="WAN ISP-2" interface=ether2 network=\
    10.200.1.0
add address=10.10.1.1/30 comment=EDGE-CORE-1 interface=ether3 network=\
    10.10.1.0
add address=10.10.2.1/30 comment=EDGE-CORE-2 interface=ether4 network=\
    10.10.2.0
/ip dhcp-client
add interface=ether1 name=client1
/ip firewall address-list
add address=10.10.0.0/16 list=MGMT
add address=10.20.0.0/16 list=MGMT
add address=10.30.0.0/16 list=MGMT
add address=192.168.0.0/16 list=MGMT
add address=192.168.0.0/16 list=SPOOF
add address=172.16.0.0/12 list=SPOOF
/ip firewall filter
add action=accept chain=input comment=est/rel connection-state=\
    established,related,untracked
add action=drop chain=input comment="drop invalid" connection-state=invalid
add action=accept chain=input comment="BGP ISP-1" dst-port=179 in-interface=\
    ether1 protocol=tcp src-address=10.100.1.1
add action=accept chain=input comment="BGP ISP-2" dst-port=179 in-interface=\
    ether2 protocol=tcp src-address=10.200.1.1
add action=accept chain=input comment="OSPF CORE-1" in-interface=ether3 \
    protocol=ospf
add action=accept chain=input comment="OSPF CORE-2" in-interface=ether4 \
    protocol=ospf
add action=accept chain=input comment=ICMP protocol=icmp
add action=accept chain=input comment="gestion solo desde interno" dst-port=\
    22,8291 in-interface-list=!WAN protocol=tcp src-address-list=MGMT
add action=drop chain=input comment="drop resto desde WAN" in-interface-list=\
    WAN
add action=accept chain=forward comment=est/rel connection-state=\
    established,related,untracked
add action=drop chain=forward comment="drop invalid" connection-state=invalid
add action=drop chain=forward comment="anti-spoof: privadas desde WAN" \
    in-interface-list=WAN src-address-list=SPOOF
add action=drop chain=forward comment="nada nuevo desde WAN hacia la LAN" \
    connection-state=new in-interface-list=WAN
/ip service
set ftp disabled=yes
set ssh available-from=10.10.0.0/16,10.20.0.0/16,10.30.0.0/16,192.168.0.0/16
set telnet disabled=yes
set www disabled=yes
set winbox available-from=\
    10.10.0.0/16,10.20.0.0/16,10.30.0.0/16,192.168.0.0/16
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add disabled=no input.filter=ISP1-IN instance=bgp1 local.address=10.100.1.2 \
    .role=ebgp name=to-ISP1 output.filter-chain=BGP-OUT .redistribute=ospf \
    remote.address=10.100.1.1 .as=65001
add disabled=no input.filter=ISP2-IN instance=bgp1 local.address=10.200.1.2 \
    .role=ebgp name=to-ISP2 output.filter-chain=BGP-OUT .redistribute=ospf \
    remote.address=10.200.1.1 .as=65002
/routing filter rule
add chain=ISP1-IN rule="set bgp-local-pref 200; accept"
add chain=ISP2-IN rule="set bgp-local-pref 100; accept"
add chain=BGP-OUT rule="if (dst in 192.168.0.0/16) { accept }"
add chain=BGP-OUT rule=reject
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 interfaces=ether3,ether4
add area=backbone interfaces=lo passive
/system identity
set name=EDGE
/system logging
add topics=bgp
