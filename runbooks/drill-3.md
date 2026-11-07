# Drill 3 — Failover BGP ante la caída del proveedor primario ISP-1

**Responsable:** R1 — Juan Ignacio Atencio
**Fecha:** 07/11/2026
**Estado:** COMPLETADO. Se ejecutó el corte controlado de la WAN primaria, se comprobó la selección automática de la ruta de respaldo por ISP-2, se registró el ping de prueba y se documentó la restauración del enlace.

## Objetivo

Comprobar que, al interrumpir el enlace WAN EDGE–ISP-1 (`10.100.1.0/30`), EDGE deja de utilizar la ruta por defecto primaria y selecciona automáticamente la alternativa anunciada por ISP-2 (`10.200.1.1`), sin intervención manual sobre las rutas.

## Estado inicial

La preparación de F4 registró en EDGE las dos sesiones eBGP establecidas:

- ISP-1: vecino `10.100.1.1`, AS `65001`, estado `ESTABLISHED`.
- ISP-2: vecino `10.200.1.1`, AS `65002`, estado `ESTABLISHED`.
- EDGE: AS `65000`, Router-ID `3.3.3.3`.
- Ruta por defecto principal: `0.0.0.0/0` vía `10.100.1.1` (ISP-1).
- Ruta por defecto de respaldo: `0.0.0.0/0` vía `10.200.1.1` (ISP-2).

Los filtros BGP `ISP1-IN` e `ISP2-IN` establecen preferencias locales de 200 y 100, respectivamente.

## Procedimiento ejecutado

Se utilizó PC-USER para comprobar el alcance ICMP hacia la loopback de ISP-2 (`2.2.2.2`). En EDGE se deshabilitó la interfaz hacia el proveedor principal:

```routeros
/interface disable [find name=ether1]
```

Se consultaron las sesiones eBGP y las rutas por defecto:

```routeros
/routing bgp session print
/ip route print detail where dst-address=0.0.0.0/0
```

Se registró el estado de EDGE durante el corte y una captura del ping desde PC-USER. A continuación, se restauró la interfaz primaria:

```routeros
/interface enable [find name=ether1]
```

Por último, se repitieron las verificaciones de sesiones y rutas para documentar el estado restaurado.

## Resultados observados durante la falla

- La ruta por defecto mediante ISP-1 (`10.100.1.1`) quedó marcada `DIb`: dinámica BGP, inactiva.
- La ruta por defecto mediante ISP-2 (`10.200.1.1`) pasó a `DAb`: dinámica BGP, activa.
- La ruta activa informó `immediate-gw=10.200.1.1%ether2`, confirmando la selección del enlace secundario.
- En la captura inmediata al corte, ambas sesiones todavía aparecían con la marca `E` (`ESTABLISHED`). Esto no contradice la conmutación de ruta: el tiempo de retención BGP informado era `hold-time=3m`, y el estado de sesión puede tardar en actualizarse.
- Se guardó una captura de la prueba ICMP hacia `2.2.2.2` durante el ensayo.

La evidencia decisiva del failover es la conmutación de la **ruta por defecto activa** hacia ISP-2. El ping a `2.2.2.2` complementa la prueba de conectividad, pero por sí solo no demuestra el cambio de ruta default, ya que ese destino también puede tener una ruta más específica.

## Restauración

Después de volver a habilitar `ether1` se documentó el estado posterior en EDGE, utilizando:

```routeros
/routing bgp session print
/ip route print detail where dst-address=0.0.0.0/0
```

La restauración busca recuperar ambas sesiones BGP y la preferencia original por ISP-1 (`10.100.1.1`), conservando ISP-2 como respaldo. La captura del estado restaurado se incorporó al conjunto de evidencias del drill.

## Evidencias

- `capturas/f4/drills/preparacion-edge-bgp-ospf.png`: sesiones BGP y adyacencias OSPF en la preparación de F4.
- `capturas/f4/drills/drill-3-bgp-failover-isp2.png`: corte de `ether1` y tabla de rutas con ISP-1 inactivo e ISP-2 activo.
- `capturas/f4/drills/drill-3-ping-isp2.png`: prueba ICMP desde PC-USER durante el ensayo.
- `capturas/f4/drills/drill-3-bgp-restaurado.png`: verificaciones posteriores a la restauración de la WAN primaria.

## Medición y conclusión

**Failover de rutas BGP funcional verificado.** Al perder disponibilidad el enlace principal, EDGE retiró la ruta por defecto de ISP-1 de la selección activa y utilizó automáticamente la ruta vía ISP-2 por `ether2`. Se realizó y documentó la restauración del enlace original.

Las capturas aportadas no incluyen una medición numérica consolidada del tiempo de interrupción ni un total verificable de paquetes ICMP perdidos; por ello no se informan valores ni se afirma un umbral cuantitativo que no esté demostrado.

## Post-mortem

- **Qué ocurrió:** se interrumpió intencionalmente `ether1`, que conecta EDGE con ISP-1.
- **Impacto observado:** la ruta default vía ISP-1 quedó inactiva y pasó a estar activa la ruta por ISP-2.
- **Causa:** indisponibilidad simulada del enlace WAN primario.
- **Qué funcionó:** la selección automática de la ruta de respaldo, sin cambios manuales en la tabla de enrutamiento.
- **Observación:** en la consulta inmediata la sesión BGP de ISP-1 aún figuraba `ESTABLISHED`; debe distinguirse el estado de la sesión del estado efectivo de la ruta.
- **Qué puede mejorarse:** para una medición cuantitativa futura, guardar los resultados completos del ping y las marcas de tiempo exactas del corte y de la recuperación.

**Resultado: COMPLETADO — conmutación funcional y evidencias registradas; tiempos y pérdida exactos no cuantificados.**
