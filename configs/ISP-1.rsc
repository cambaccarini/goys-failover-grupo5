# =====================================================================
# ISP-1 — configuración definitiva (cierre F4 / entrega F5) · RouterOS 7.24.1
# Base: backups/F4/ISP-1-F4.rsc + baseline de hardening de F1 (memoria §2.3).
# Cambios respecto del export F4: ver configs/README.md.
# Secretos: los tokens __NOMBRE__ se sustituyen con configs/render.sh.
# NO importar este archivo sin renderizar y NO versionar el resultado.
# =====================================================================
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
/routing bgp instance
add as=65001 name=bgp1 router-id=1.1.1.1
/snmp community
set [ find default=yes ] addresses=192.168.10.0/24,192.168.20.0/24 name=__SNMP_COMMUNITY__
/system logging action
add disk-file-name=estadored disk-lines-per-file=500 name=estadored target=disk
/user group
add name=monitor-ro policy=local,ssh,winbox,read
add name=superadmin policy=local,telnet,ssh,ftp,reboot,read,write,policy,test,winbox,password,web,sniff,sensitive,api,romon,rest-api
/ip neighbor discovery-settings
set discover-interface-list=none
/ip address
add address=1.1.1.1 interface=lo network=1.1.1.1
add address=10.100.1.1/30 comment="WAN hacia EDGE" interface=ether1 network=10.100.1.0
/ip dhcp-client
add disabled=yes interface=ether1 name=client1
/ip firewall address-list
add address=1.1.1.1 list=NET-ISP1
/ip service
set ftp disabled=yes
set ssh available-from=10.0.0.0/8,192.168.0.0/16
set telnet disabled=yes
set www disabled=yes
set reverse-proxy disabled=yes
set winbox available-from=10.0.0.0/8,192.168.0.0/16
set api disabled=yes
set api-ssl disabled=yes
/routing bgp connection
add instance=bgp1 local.address=10.100.1.1 .role=ebgp name=to-EDGE output.default-originate=always .network=NET-ISP1 remote.address=10.100.1.2 .as=65000 tcp-md5-key=__BGP_KEY_ISP1__
/snmp
set contact=grupo5 enabled=yes location=GNS3-lab
/system identity
set name=ISP-1
/system logging
add action=estadored topics=interface,info
add action=estadored topics=ospf
add action=estadored topics=bgp
/tool mac-server
set allowed-interface-list=none
/tool mac-server mac-winbox
set allowed-interface-list=none
/tool mac-server ping
set enabled=no
/user
add name=netadmin group=full password=__NETADMIN_PASSWORD__
add name=monitor group=monitor-ro password=__MONITOR_PASSWORD__
# Paso manual posterior (tras verificar login con netadmin): /user remove [find name=admin]
