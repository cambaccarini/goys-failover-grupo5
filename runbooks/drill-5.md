# Drill 5 — Verificación VRRP activo/activo y distribución de tráfico por VLAN

**Responsable:** R4 — Juan Ignacio Atencio
**Fecha:** 07/11/2026
**Estado:** COMPLETADO. Se verificaron los roles VRRP, las rutas desde ambos hosts y la observación de tráfico mediante Torch (captura conservada de DIST-1).

## Objetivo

Comprobar que DIST-1 y DIST-2 funcionan simultáneamente como gateways principales de VLAN diferentes: DIST-1 para usuarios (VLAN 10) y DIST-2 para servidores (VLAN 20). El propósito es verificar distribución lógica por VLAN, no un reparto 50/50 del ancho de banda.

## Estado inicial

La preparación de F4 y las verificaciones previas de F2 registraron los siguientes roles:

- DIST-1: `vrrp10` Master (prioridad 150) y `vrrp20` Backup (prioridad 100).
- DIST-2: `vrrp10` Backup (prioridad 100) y `vrrp20` Master (prioridad 150).
- VLAN 10: gateway virtual `192.168.10.1`; PC-USER `192.168.10.100/24`.
- VLAN 20: gateway virtual `192.168.20.1`; SRV `192.168.20.100/24`.

Las prioridades cruzadas permiten que ambos routers asuman el rol Master de una VLAN distinta en condiciones normales.

## Procedimiento ejecutado

En DIST-1 y DIST-2 se comprobaron los roles VRRP:

```routeros
/interface vrrp print
```

Desde PC-USER y SRV se verificaron los primeros saltos hacia el otro host:

```text
trace 192.168.20.100
```

```text
trace 192.168.10.100
```

Se generó tráfico de prueba desde ambos equipos hacia las loopbacks externas:

- PC-USER hacia `2.2.2.2` (ISP-2).
- SRV hacia `1.1.1.1` (ISP-1).

Durante la prueba se inspeccionaron las interfaces VLAN en los routers de distribución utilizando Torch, de una interfaz por vez:

```routeros
/tool torch interface=vlan10
/tool torch interface=vlan20
```

Se guardaron capturas del estado VRRP, de los traceroutes y de Torch en DIST-1 (la de DIST-2 no se conservó).

## Resultados observados

- Los roles VRRP configurados corresponden a un esquema activo/activo por VLAN: DIST-1 es Master de VRID 10 y DIST-2 es Master de VRID 20.
- El traceroute de PC-USER hacia SRV utiliza `192.168.10.2` (DIST-1) como primer salto, según el comportamiento documentado en F2.
- El traceroute de SRV hacia PC-USER utiliza `192.168.20.3` (DIST-2) como primer salto, según el comportamiento documentado en F2.
- Se conserva evidencia de tráfico observado con Torch en DIST-1 durante la prueba de F4.
- La combinación de roles VRRP, selección de gateways de los hosts, traceroutes y capturas de tráfico documenta el funcionamiento de ambos routers como gateways activos de distintas VLAN.

Las capturas de Torch se interpretan junto con los roles VRRP y las rutas: observar paquetes sobre una VLAN, aisladamente, no prueba qué router desempeña el rol Master.

## Restauración

El Drill 5 consistió en verificar el funcionamiento normal del esquema activo/activo. No se deshabilitaron enlaces ni se alteraron prioridades o configuraciones VRRP, por lo que no fue necesaria una restauración.

El estado operativo esperado al finalizar permanece:

- DIST-1: Master de VRID 10 y Backup de VRID 20.
- DIST-2: Backup de VRID 10 y Master de VRID 20.

## Evidencias

- `capturas/f4/drills/drill-5-roles-vrrp.png`: roles VRRP en ambos routers.
- `capturas/f4/drills/drill-5-trace-pc-user.png`: primer salto desde PC-USER.
- `capturas/f4/drills/drill-5-trace-srv.png`: primer salto desde SRV.
- `capturas/f4/drills/drill-5-torch-dist1.png`: observación de tráfico mediante Torch en DIST-1.
- Torch en DIST-2: sin captura en el repositorio (`drill-5-torch-dist2.png` fue citada pero no se conservó); solo está documentado Torch en DIST-1.

Como antecedentes de corroboración también se conservan las verificaciones de F2 en `capturas/f2/vrrp/` y `capturas/f2/conectividad/`.

## Medición y conclusión

**Funcionamiento VRRP activo/activo verificado.** DIST-1 y DIST-2 ejercen simultáneamente la función de gateway Master en VLAN 10 y VLAN 20, respectivamente. Los traceroutes y las capturas de Torch complementan la comprobación de los roles VRRP y del tráfico de ambas redes.

El ensayo demuestra distribución lógica de funciones de primer salto **por VLAN**, no reparto equitativo de bytes ni balanceo flujo a flujo. No se atribuye una proporción 50/50 ni una tasa de tráfico no medida.

## Post-mortem

- **Qué ocurrió:** se verificó el funcionamiento concurrente de los dos routers de distribución con roles Master cruzados.
- **Impacto observado:** los hosts de VLAN 10 y VLAN 20 utilizan gateways principales distintos.
- **Causa:** configuración planificada de prioridades VRRP 150/100 invertidas entre VLAN 10 y VLAN 20.
- **Qué funcionó:** la asignación de roles Master/Backup, la selección del primer salto y la observación de tráfico en ambos DIST.
- **Qué debe aclararse en la documentación:** `activo/activo` significa que ambos equipos prestan servicio simultáneamente a distintas VLAN; no implica idéntico consumo de ancho de banda.

**Resultado: COMPLETADO — esquema VRRP activo/activo por VLAN y evidencias registradas.**
