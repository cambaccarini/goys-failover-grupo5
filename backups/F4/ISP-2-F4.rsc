# 2026-11-13 01:24:58 by RouterOS 7.24.1
# system id = x1jW4EkR2KI
#
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
/routing bgp instance
add as=65002 name=bgp1 router-id=2.2.2.2
/snmp community
set [ find default=yes ] addresses=192.168.10.0/24,192.168.20.0/24 name=REDACTED
/system logging action
add disk-file-name=estadored disk-lines-per-file=500 name=estadored target=disk
/user group
add name=superadmin policy=local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon,rest-api
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=2.2.2.2 interface=lo network=2.2.2.2
add address=10.200.1.1/30 comment="WAN hacia EDGE" interface=ether1 network=10.200.1.0
/ip dhcp-client
add interface=ether1 name=client1
/ip firewall address-list
add address=2.2.2.2 list=NET-ISP2
/ip service
set ftp disabled=yes
set telnet disabled=yes
set www disabled=yes
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add instance=bgp1 local.address=10.200.1.1 .role=ebgp name=to-EDGE output.default-originate=always .network=NET-ISP2 remote.address=10.200.1.2 .as=65000
/snmp
set contact=grupo5 enabled=yes location=GNS3-lab
/system identity
set name=ISP-2
/system logging
add action=estadored topics=interface,info
add action=estadored topics=ospf
add action=estadored topics=bgp