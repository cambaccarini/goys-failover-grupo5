# 2026-10-25 14:11:58 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
/user group
add name=superadmin policy="local,telnet,ssh,ftp,reboot,read,write,policy,test\
    ,winbox,password,web,sniff,sensitive,api,romon,rest-api"
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=2.2.2.2 interface=lo network=2.2.2.2
add address=10.200.1.1/30 comment="WAN hacia EDGE" interface=ether1 network=\
    10.200.1.0
/ip dhcp-client
add interface=ether1 name=client1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/system identity
set name=ISP-2