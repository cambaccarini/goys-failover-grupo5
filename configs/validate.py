#!/usr/bin/env python3
"""Validación estática de configs/*.rsc (no reemplaza una importación real en CHR).

Comprueba: tokens de secretos, sintaxis básica, interfaces/direccionamiento (IPAM),
Router-ID = loopback, pares OSPF/BGP/VRRP coherentes entre routers.
Uso: python3 configs/validate.py
"""
import re, sys, os, ipaddress, collections

D = os.path.dirname(os.path.abspath(__file__))
ROUTERS = ["EDGE","ISP-1","ISP-2","CORE-1","CORE-2","DIST-1","DIST-2"]
TOKENS_OK = {"SNMP_COMMUNITY","OSPF_MD5_KEY","VRRP_KEY","BGP_KEY_ISP1","BGP_KEY_ISP2","NETADMIN_PASSWORD","MONITOR_PASSWORD"}
NEED = {
 "EDGE":  {"SNMP_COMMUNITY","OSPF_MD5_KEY","BGP_KEY_ISP1","BGP_KEY_ISP2","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
 "ISP-1": {"SNMP_COMMUNITY","BGP_KEY_ISP1","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
 "ISP-2": {"SNMP_COMMUNITY","BGP_KEY_ISP2","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
 "CORE-1":{"SNMP_COMMUNITY","OSPF_MD5_KEY","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
 "CORE-2":{"SNMP_COMMUNITY","OSPF_MD5_KEY","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
 "DIST-1":{"SNMP_COMMUNITY","OSPF_MD5_KEY","VRRP_KEY","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
 "DIST-2":{"SNMP_COMMUNITY","OSPF_MD5_KEY","VRRP_KEY","NETADMIN_PASSWORD","MONITOR_PASSWORD"},
}
errs, warns = [], []
def err(r, m): errs.append(f"[{r}] {m}")

def parse(r):
    txt = open(os.path.join(D, f"{r}.rsc"), encoding="utf-8").read()
    sec, items = None, []
    for n, raw in enumerate(txt.splitlines(), 1):
        l = raw.rstrip()
        if not l or l.startswith("#"): continue
        if l.endswith("\\"): err(r, f"línea {n}: continuación con backslash")
        if l.count('"') % 2: err(r, f"línea {n}: comillas desbalanceadas")
        if l.startswith("/"):
            sec = l.strip(); continue
        if sec is None: err(r, f"línea {n}: comando fuera de sección"); continue
        if not re.match(r"^(add|set|remove|enable|disable)\b", l): err(r, f"línea {n}: comando no reconocido: {l[:40]}")
        items.append((sec, l))
    return txt, items

def kv(line):
    return dict(re.findall(r'([\w.\-]+)=("[^"]*"|\S+)', line))

data = {}
for r in ROUTERS:
    txt, items = parse(r)
    body = "\n".join(x for x in txt.splitlines() if not x.lstrip().startswith("#"))
    toks = set(re.findall(r"__([A-Z0-9_]+)__", body))
    if toks - TOKENS_OK: err(r, f"tokens desconocidos: {toks-TOKENS_OK}")
    if toks != NEED[r]: err(r, f"tokens esperados {sorted(NEED[r])} != encontrados {sorted(toks)}")
    for bad in ("REDACTED","# system id","<DEFINIR"):
        if bad in txt: err(r, f"contiene '{bad}'")
    if re.search(r"ether\d \] .*disabled=yes", txt): err(r, "interfaz ethernet deshabilitada")
    data[r] = items

# IPAM
nets = collections.defaultdict(list); loop = {}; vips = {}
for r, items in data.items():
    for sec, l in items:
        if sec == "/ip address" and l.startswith("add"):
            p = kv(l); ip = ipaddress.ip_interface(p["address"] if "/" in p["address"] else p["address"]+"/32")
            if ip.network.prefixlen == 32 and p["interface"] == "lo": loop[r] = str(ip.ip)
            elif p["interface"].startswith("vrrp"): vips.setdefault(str(ip.ip), []).append((r, p["interface"]))
            else: nets[str(ip.network)].append((r, str(ip.ip), p["interface"]))
exp_loop = dict(zip(ROUTERS, ["3.3.3.3","1.1.1.1","2.2.2.2","4.4.4.4","5.5.5.5","6.6.6.6","7.7.7.7"]))
for r in ROUTERS:
    if loop.get(r) != exp_loop[r]: err(r, f"loopback {loop.get(r)} != {exp_loop[r]}")
    rid = [kv(l).get("router-id") for s,l in data[r] if s.endswith("instance") and "router-id" in l]
    if not rid or set(rid) != {exp_loop[r]}: err(r, f"router-id {rid} != loopback {exp_loop[r]}")
for n, m in sorted(nets.items()):
    pl = ipaddress.ip_network(n).prefixlen
    if pl == 30 and len(m) != 2: err("IPAM", f"{n}: {len(m)} extremos (esperado 2): {m}")
    ips = [x[1] for x in m]
    if len(set(ips)) != len(ips): err("IPAM", f"{n}: IPs repetidas {m}")
# VIP VRRP: la misma VIP debe existir en ambos DIST (una por VLAN) y no chocar con IPs reales
if sorted(vips) != ["192.168.10.1","192.168.20.1"] or any(len(v) != 2 for v in vips.values()):
    err("VRRP", f"VIPs inesperadas: {vips}")
real = {x[1] for m in nets.values() for x in m}
if real & set(vips): err("VRRP", f"VIP coincide con IP real: {real & set(vips)}")
# OSPF: interfaces del template existen y los enlaces con vecino OSPF usan MD5
for r in ["EDGE","CORE-1","CORE-2","DIST-1","DIST-2"]:
    ifs_def = {kv(l)["interface"] for s,l in data[r] if s=="/ip address" and "interface" in kv(l)}
    ifs_def |= {kv(l)["name"] for s,l in data[r] if s=="/interface vlan"}
    for s,l in data[r]:
        if s == "/routing ospf interface-template":
            p = kv(l)
            for i in p["interfaces"].split(","):
                if i not in ifs_def: err(r, f"OSPF template usa interfaz sin IP: {i}")
            if "passive" not in l and "auth=md5" not in l: err(r, f"template OSPF sin MD5: {l}")
# BGP espejo
def bgp(r):
    out = []
    for s,l in data[r]:
        if s == "/routing bgp connection":
            p = kv(l); out.append((p["local.address"], p["remote.address"], p["tcp-md5-key"]))
    return out
for isp, ed_idx in (("ISP-1",0),("ISP-2",1)):
    (la, ra, ka), = bgp(isp); le, re_, ke = bgp("EDGE")[ed_idx]
    if (la, ra) != (re_, le): err(isp, f"par BGP no espeja a EDGE: {(la,ra)} vs {(le,re_)}")
    if ka != ke: err(isp, "token tcp-md5-key distinto al de EDGE")
# VRRP: VRIDs y prioridades complementarias
vr = {}
for r in ("DIST-1","DIST-2"):
    for s,l in data[r]:
        if s == "/interface vrrp": p = kv(l); vr[(r,p["vrid"])] = int(p.get("priority","100"))
if not (vr[("DIST-1","10")]==150 and vr[("DIST-2","10")]==100 and vr[("DIST-2","20")]==150 and vr[("DIST-1","20")]==100):
    err("VRRP", f"prioridades inesperadas {vr}")

print(f"Routers validados: {len(ROUTERS)} · redes: {len(nets)} · loopbacks: {len(loop)} · VIP VRRP: {len(vips)}")
for w in warns: print("AVISO", w)
if errs:
    print(f"\n{len(errs)} ERRORES"); [print(" -", e) for e in errs]; sys.exit(1)
print("OK: sin errores (validación estática).")
