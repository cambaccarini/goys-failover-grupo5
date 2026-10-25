# 2026-10-25 14:15:06 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/routing ospf instance
add name=ospf1 router-id=4.4.4.4
/routing ospf area
add instance=ospf1 name=backbone
/user group
add name=superadmin policy="local,telnet,ssh,ftp,reboot,read,write,policy,test\
    ,winbox,password,web,sniff,sensitive,api,romon,rest-api"
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=4.4.4.4 comment="Loopback / Router-ID" interface=lo network=\
    4.4.4.4
add address=10.10.1.2/30 comment=EDGE-CORE-1 interface=ether1 network=\
    10.10.1.0
add address=10.20.1.1/30 comment=Core-Core interface=ether2 network=10.20.1.0
add address=10.30.1.1/30 comment=CORE-1-DIST-1 interface=ether3 network=\
    10.30.1.0
add address=10.30.2.1/30 comment=CORE-1-DIST-2 interface=ether4 network=\
    10.30.2.0
/ip dhcp-client
add interface=ether1 name=client1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 interfaces=ether1,ether2,ether3,ether4
add area=backbone interfaces=lo passive
/system identity
set name=CORE-1
/system note
set note="ACCESO RESTRINGIDO - Solo personal autorizado. Toda actividad es reg\
    istrada y auditada."