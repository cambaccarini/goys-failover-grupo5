# 2026-10-19 21:47:39 by RouterOS 7.24.1
# system id = OINlIIfBfhJ
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface vlan
add interface=ether4 name=vlan10 vlan-id=10
add interface=ether3 name=vlan20 vlan-id=20
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
/ip dhcp-client
add disabled=yes interface=ether1 name=client1
/ip service
set ftp disabled=yes
set ssh available-from=10.0.0.0/8,192.168.0.0/16
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox available-from=10.0.0.0/8,192.168.0.0/16
set api disabled=yes
set api-ssl disabled=yes
/system identity
set name=DIST-2
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
/tool mac-server ping
set enabled=no