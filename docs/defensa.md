# Guía de preparación de la defensa oral

Apoyo para la sesión de simulación y la defensa (backlog, Epic F5). Todo lo que figura acá sale de `docs/memoria.md`, los runbooks y `configs/`; ante una duda, mandan esos documentos.

## 1. Datos que todos deben saber de memoria

| Dato | Valor |
|---|---|
| Capas | ISP → EDGE → CORE → DIST → acceso (VLAN 10 usuarios, VLAN 20 servidores) |
| ASN / Router-ID | ISP-1 65001 (`1.1.1.1`) · ISP-2 65002 (`2.2.2.2`) · EDGE 65000 (`3.3.3.3`) |
| Core / Dist | CORE-1 `4.4.4.4` · CORE-2 `5.5.5.5` · DIST-1 `6.6.6.6` · DIST-2 `7.7.7.7` |
| Enlaces | WAN `10.100.1.0/30` y `10.200.1.0/30` · EDGE–CORE `10.10.1.0/30` y `10.10.2.0/30` · Core-Core `10.20.1.0/30` · CORE–DIST `10.30.1.0/30` a `10.30.4.0/30` |
| VRRP | VRID 10 → VIP `192.168.10.1`, Master DIST-1 (prio 150) · VRID 20 → VIP `192.168.20.1`, Master DIST-2 (prio 150) · v2, autenticación simple |
| BGP | `local-pref` 200 por ISP-1 y 100 por ISP-2 · `BGP-OUT` solo publica `192.168.0.0/16` · ISPs con `default-originate=always` · TCP-MD5 en ambos peerings |
| OSPF | Área 0, MD5 (`auth-id=1`), loopbacks y VLAN pasivas, EDGE con `originate-default=if-installed` |
| Los 4 defectos del diagrama original | SPOF en el borde · sin enlace Core-Core · FHRP en el Core · direccionamiento solapado |

## 2. Qué defiende cada rol

### R1 — Juan: Borde, BGP multi-homing y firewall (cruzada: VRRP)
- Por qué dual-homing con ISP-1 preferido: elimina el SPOF del borde; `local-pref` mayor gana la default.
- Firewall de EDGE: `input` con established/related, BGP solo desde el vecino, OSPF por `ether3/4`, gestión solo desde la lista `MGMT` y drop del resto desde WAN; `forward` con anti-spoofing RFC 1918 y descarte de conexiones nuevas desde WAN hacia la LAN; NAT masquerade.
- Drill 3: al deshabilitar `ether1`, la default por ISP-1 pasa a `DIb` y la de ISP-2 a `DAb`. Declarar que **no se midió tiempo ni pérdida**.
- Cruzada VRRP: el reparto es activo/activo **por VLAN**, no balanceo 50/50.

### R2 — Patricio: ISPs, backups y failover estático (cruzada: OSPF Core-Core)
- ISPs: un AS por proveedor, `default-originate=always`, anuncio de su loopback.
- Backups: `/export` sin `show-sensitive` por fase, binarios fuera de Git, restauración validada en un nodo aislado con `isp-1-F1-post-hardening.backup`.
- Drill 4: dos rutas a `2.2.2.2/32`, `check-gateway=ping`; conmutación a ≈ 30 s (3 sondeos de 10 s). Límite: es un `/32` de prueba; con eBGP activo (distancia 20) la estática debe tener distancia menor o limitarse a prefijos específicos.
- Cruzada Core-Core: evita *trombone routing* y da camino directo entre CORE-1 y CORE-2 si cae un uplink.

### R3 — Ian: Core, OSPF MD5 y monitoreo (cruzada: BGP TCP-MD5)
- Core como tránsito puro: sin SVIs ni ARP de acceso; VRRP vive en Distribución.
- Prueba negativa OSPF MD5 (12/11): `authentication failed` / `md5 mismatch`, adyacencias sin llegar a `Full`, recuperación a cuatro vecinos `Full` en CORE-1.
- SNMP v2c: solo lectura, restringido a las dos LAN. **`snmpwalk` no se ejecutó**; no decir que la MIB fue consultada.
- Logging: acción `estadored` a disco, temas `interface`, `ospf`, `bgp`. VRRP no se registra.
- Cruzada TCP-MD5 (RFC 2385): firma en cada segmento TCP del puerto 179; con clave errónea la sesión oscila entre `connect` y `active` (evidencia F3).

### R4 — Juan: VRRP en Distribución (cruzada: políticas de EDGE)
- Por qué VRRP en Distribución y no en Core; VIP por VLAN; MACs virtuales `00:00:5E:00:01:0A` (VRID 10) y `…:14` (VRID 20).
- Drills 1 y 5: Master cruzado, traceroutes (PC-USER sale por `192.168.10.2` y SRV por `192.168.20.3`), Torch en DIST-1.
- Límite de la autenticación simple: texto claro en la LAN.

## 3. Demostraciones en vivo

Hacerlas siempre con ping continuo desde el host y **anotar la hora del corte y de la recuperación** (`ping -D`), para tener la cifra que hoy falta.

| Drill | Corte | Qué mostrar | Restauración |
|---|---|---|---|
| 1 VRRP | DIST-1: `/interface disable [find name=vlan10]` | DIST-2: `/interface vrrp print` → `vrrp10` en `RM`; el ping al `192.168.10.1` sigue | `/interface enable [find name=vlan10]`; DIST-1 recupera Master |
| 2 OSPF | EDGE: `/interface disable [find name=ether3]` | `/routing ospf neighbor print` en EDGE: solo CORE-2 `Full`; ping a `2.2.2.2` sigue | `/interface enable [find name=ether3]`; dos vecinos `Full` |
| 3 BGP | EDGE: `/interface disable [find name=ether1]` | `/ip route print detail where dst-address=0.0.0.0/0`: ISP-1 `DIb`, ISP-2 `DAb` | `/interface enable [find name=ether1]` |
| 4 check-gateway | Crear las dos rutas (`runbooks/drill-4.md`) y deshabilitar `ether1` | Primaria `Is`, respaldo `As` a los ≈ 30 s | Habilitar `ether1`; **borrar las rutas de prueba** |

Después de cada demostración, comprobar que el enlace quedó habilitado antes de seguir.

## 4. Preguntas incómodas que el repositorio no puede responder hoy

1. **"¿Cuánto tardó el failover de VRRP?"** El runbook declara < 3 s, pero sin cifra registrada. Con intervalo de 1 s, RFC 3768 da `3 × 1 s + skew` ≈ 3,6 s para un Backup de prioridad 100, que no coincide con ese umbral. No defender la cifra declarada; medirla en la demo.
2. **"¿Y OSPF < 5 s?"** El ping conservado no tiene marca de tiempo del corte. Además, deshabilitar `ether3` en EDGE no necesariamente baja el enlace del lado de CORE-1 en GNS3: ahí la adyacencia depende del *dead interval* (por defecto 40 s en RouterOS; verificar con `/routing ospf interface-template print detail`). Medir con `ping -D -i 0.2`.
3. **"¿Probaron la autenticación VRRP?"** No; está configurada y visible, sin prueba negativa.
4. **"¿Se puede reconstruir la red desde `configs/`?"** Validado de forma estática; falta importar en un CHR limpio.
5. **"¿Los exports reflejan el laboratorio?"** El export F4 de EDGE tenía `ether2` deshabilitada y los exports F2–F4 no muestran parte del hardening de F1. Ver `configs/README.md`.
6. **"¿Las claves del repositorio son reales?"** La memoria nombra `CLAVE_BGP_ISP1`, `CLAVE_BGP_ISP2` y `CLAVE_INCORRECTA` como claves de las pruebas. Si alguna es o fue una clave real, rotarla y reemplazarla en la memoria por un marcador.

## 5. Checklist previo a la defensa

- [ ] Laboratorio encendido: `/routing bgp session print` (dos `E`), `/routing ospf neighbor print` (vecinos `Full`) y roles VRRP cruzados.
- [ ] Verificar los puntos de `configs/README.md` ("Verificación pendiente en los routers reales"), en especial `ether2` de EDGE.
- [ ] Snapshot de GNS3 antes de las demostraciones.
- [ ] Cada integrante ensayó su demostración completa, incluida la restauración.
- [ ] Cifras de tiempo y pérdida de los Drills 1 a 3 medidas y guardadas, si hay margen.
