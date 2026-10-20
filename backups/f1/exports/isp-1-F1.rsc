# 2026-10-19 21:35:43 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
/user group
add name=superadmin policy="local,telnet,ssh,ftp,reboot,read,write,policy,test\
    ,winbox,password,web,sniff,sensitive,api,romon,rest-api"
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=1.1.1.1 interface=lo network=1.1.1.1
add address=10.100.1.1/30 comment="WAN hacia EDGE" interface=ether1 network=\
    10.100.1.0
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
set name=ISP-1
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
/tool mac-server ping
set enabled=no