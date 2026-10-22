# 2026-10-19 21:46:53 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/user group
add name=superadmin policy="local,telnet,ssh,ftp,reboot,read,write,policy,test\
    ,winbox,password,web,sniff,sensitive,api,romon,rest-api"
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=5.5.5.5 comment="Loopback / Router-ID" interface=lo network=\
    5.5.5.5
add address=10.10.2.2/30 comment=EDGE-CORE-2 interface=ether1 network=\
    10.10.2.0
add address=10.20.1.2/30 comment=Core-Core interface=ether2 network=10.20.1.0
add address=10.30.3.1/30 comment=CORE-2-DIST-1 interface=ether3 network=\
    10.30.3.0
add address=10.30.4.1/30 comment=CORE-2-DIST-2 interface=ether4 network=\
    10.30.4.0
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
set name=CORE-2
/system note
set note="ACCESO RESTRINGIDO - Solo personal autorizado. Toda actividad es reg\
    istrada y auditada."
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
/tool mac-server ping
set enabled=no
