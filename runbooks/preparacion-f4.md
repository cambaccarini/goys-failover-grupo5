# Preparación de F4 — Estado base

**Fecha:** 06/11/2026  
**Objetivo:** validar que la topología está en condiciones de ejecutar los drills de contingencia.

## Verificaciones realizadas

En EDGE se consultaron `/routing bgp session print` y `/routing ospf neighbor print`.

- BGP hacia ISP-1: remoto `10.100.1.1`, AS `65001`, estado `ESTABLISHED`, `prefix-count=2`.
- BGP hacia ISP-2: remoto `10.200.1.1`, AS `65002`, estado `ESTABLISHED`, `prefix-count=2`.
- OSPF por `ether3`: vecino CORE-1, Router-ID `4.4.4.4`, estado `Full`.
- OSPF por `ether4`: vecino CORE-2, Router-ID `5.5.5.5`, estado `Full`.
- EDGE no tiene interfaces VRRP configuradas; es lo esperado, ya que VRRP reside en DIST-1 y DIST-2.

En distribución se verificó el estado VRRP inicial:

| VRID | VLAN | DIST-1 | DIST-2 |
|---|---|---|---|
| 10 | 10 | Master, prioridad 150 | Backup, prioridad 100 |
| 20 | 20 | Backup, prioridad 100 | Master, prioridad 150 |

La evidencia visual del estado de BGP/OSPF en EDGE está en `capturas/f4/drills/preparacion-edge-bgp-ospf.png`. Los estados VRRP iniciales se observan también en la evidencia de roles de Drill 1.

## Resultado

**Preparación verificada.** Las dos sesiones eBGP y las dos adyacencias OSPF de EDGE estaban operativas y los roles VRRP coincidían con el diseño activo/activo por VLAN. No se modificó configuración durante esta preparación.
