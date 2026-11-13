# =====================================================================
# DIST-1 — configuración definitiva (cierre F4 / entrega F5) · RouterOS 7.24.1
# Base: backups/F4/DIST-1-F4.rsc + baseline de hardening de F1 (memoria §2.3).
# Cambios respecto del export F4: ver configs/README.md.
# Secretos: los tokens __NOMBRE__ se sustituyen con configs/render.sh.
# NO importar este archivo sin renderizar y NO versionar el resultado.
# =====================================================================
/interface ethernet
set [ find default-name=ether1 ] disable-running-check=no
set [ find default-name=ether2 ] disable-running-check=no
set [ find default-name=ether3 ] disable-running-check=no
set [ find default-name=ether4 ] disable-running-check=no
/interface vlan
add interface=ether3 name=vlan10 vlan-id=10
add interface=ether4 name=vlan20 vlan-id=20
/interface vrrp
add authentication=simple password=__VRRP_KEY__ interface=vlan10 name=vrrp10 priority=150 version=2 vrid=10
add authentication=simple password=__VRRP_KEY__ interface=vlan20 name=vrrp20 version=2 vrid=20
/routing ospf instance
add name=ospf1 router-id=6.6.6.6
/routing ospf area
add instance=ospf1 name=backbone
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
add address=6.6.6.6 comment="Loopback / Router-ID" interface=lo network=6.6.6.6
add address=10.30.1.2/30 comment=DIST-1-CORE-1 interface=ether1 network=10.30.1.0
add address=10.30.3.2/30 comment=DIST-1-CORE-2 interface=ether2 network=10.30.3.0
add address=192.168.10.2/24 interface=vlan10 network=192.168.10.0
add address=192.168.20.2/24 interface=vlan20 network=192.168.20.0
add address=192.168.10.1 comment="VIP VLAN10 USERS" interface=vrrp10 network=192.168.10.1
add address=192.168.20.1 comment="VIP VLAN20 SERVERS" interface=vrrp20 network=192.168.20.1
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
/routing ospf interface-template
add area=backbone auth=md5 auth-id=1 auth-key=__OSPF_MD5_KEY__ interfaces=ether1,ether2
add area=backbone interfaces=vlan10,vlan20 passive
add area=backbone interfaces=lo passive
/snmp
set contact=grupo5 enabled=yes location=GNS3-lab
/system identity
set name=DIST-1
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
