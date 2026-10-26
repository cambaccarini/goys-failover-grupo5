# 2026-10-26 06:00:29 by RouterOS 7.24.1
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
/routing bgp instance
add as=65001 name=bgp1 router-id=1.1.1.1
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
add interface=ether1 name=client1
/ip firewall address-list
add address=1.1.1.1 list=NET-ISP1
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add instance=bgp1 local.address=10.100.1.1 .role=ebgp name=to-EDGE \
    output.default-originate=always .network=NET-ISP1 remote.address=\
    10.100.1.2 .as=65000
/system identity
set name=ISP-1