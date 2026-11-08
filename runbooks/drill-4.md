# Drill 4 — Failover de rutas estáticas con check-gateway=ping

**Responsable:** R2 — Alesandro Patricio Borda  
**Fecha:** 08/11/2026  
**Estado:** COMPLETADO. Detección de inalcanzabilidad por `check-gateway=ping`, conmutación automática a ruta de respaldo por distancia administrativa, restauración de enlace y limpieza de rutas verificados; se cumplieron los criterios de aceptación.

## Objetivo

Demostrar que RouterOS deja de utilizar una ruta estática cuyo gateway deja de responder a sondeos ICMP periódicos (`check-gateway=ping`) y selecciona automáticamente una ruta alternativa de respaldo con mayor distancia administrativa, sin requerir intervención manual.

## Topología y routers involucrados

- **EDGE** (MikroTik CHR, RouterOS v7.24.1): router de borde donde se configuran y evalúan las políticas de ruteo estático hacia ambos proveedores.
- **ISP-1** (gateway `10.100.1.1` vía interfaz `ether1`).
- **ISP-2** (gateway `10.200.1.1` vía interfaz `ether2`).
- Destino de prueba: prefijo de host `2.2.2.2/32`.

## Estado inicial

Se verificó previamente la alcanzabilidad ICMP desde EDGE hacia ambos gateways WAN:
- `10.100.1.1`: 0% packet loss.
- `10.200.1.1`: 0% packet loss.

A continuación, se aprovisionaron dos rutas estáticas específicas para el destino `2.2.2.2/32`:

```routeros
/ip route add dst-address=2.2.2.2/32 gateway=10.100.1.1 distance=1 check-gateway=ping comment="F4-DRILL4-PRIMARY"
/ip route add dst-address=2.2.2.2/32 gateway=10.200.1.1 distance=2 check-gateway=ping comment="F4-DRILL4-BACKUP"
```

Al consultar la tabla de ruteo con `/ip route print detail where dst-address=2.2.2.2/32`, se observó:
- **Ruta 0 (F4-DRILL4-PRIMARY):** flags `As` (Active, Static), gateway `10.100.1.1`, `immediate-gw=10.100.1.1%ether1`, `check-gateway=ping`, `distance=1`.
- **Ruta 1 (F4-DRILL4-BACKUP):** flags `s` (Static, inactiva como respaldo), gateway `10.200.1.1`, `immediate-gw=10.200.1.1%ether2`, `check-gateway=ping`, `distance=2`.

## Procedimiento ejecutado

1. En EDGE, se provocó la caída del enlace WAN primario hacia ISP-1:
   ```routeros
   /interface disable [find name=ether1]
   ```
2. Se aguardó el intervalo de detección del mecanismo `check-gateway=ping` (3 paquetes ICMP fallidos con intervalo de 10 segundos, totalizando ~30 segundos).
3. Se verificó el estado de las rutas en EDGE:
   ```routeros
   /ip route print detail where dst-address=2.2.2.2/32
   ```
4. Se procedió a restaurar la interfaz WAN primaria:
   ```routeros
   /interface enable [find name=ether1]
   ```
5. Tras 10-15 segundos para la recepción de respuestas ICMP válidas, se verificó el retorno de la ruta primaria como activa.
6. Se procedió al desaprovisionamiento de las rutas de prueba y verificación de la tabla:
   ```routeros
   /ip route remove [find where comment="F4-DRILL4-PRIMARY"]
   /ip route remove [find where comment="F4-DRILL4-BACKUP"]
   /ip route print where comment~"F4-DRILL4"
   ```

## Resultados observados

### Durante la falla (Failover)
- La ruta primaria `F4-DRILL4-PRIMARY` pasó a estado **`Is`** (Inactive, Static), perdiendo la bandera `A` y reportando `immediate-gw=""`.
- La ruta de respaldo `F4-DRILL4-BACKUP` pasó a estado **`As`** (Active, Static) a través de `10.200.1.1%ether2`.
- El tiempo de detección y conmutación fue de aproximadamente 30 segundos, cumpliendo de forma exacta con la especificación de RouterOS para 3 fallos consecutivos de 10s.

### Tras la restauración
- Al rehabilitar `ether1`, el gateway `10.100.1.1` respondió nuevamente a los sondeos ping.
- La ruta primaria `F4-DRILL4-PRIMARY` recuperó automáticamente el estado **`As`** (Active, Static) por poseer menor distancia administrativa (`distance=1`).
- La ruta `F4-DRILL4-BACKUP` retornó a estado inactivo de reserva (`s`, `distance=2`).

### Limpieza de rutas
- La consulta `/ip route print where comment~"F4-DRILL4"` no devolvió ningún registro, confirmando que la infraestructura quedó en su estado operacional estándar de producción.

## Evidencias

- `capturas/f4/drills/drill-4-rutas-antes-del-corte.png`: rutas de prueba instaladas en EDGE; primaria activa (`As`), secundaria inactiva (`s`).
- `capturas/f4/drills/drill-4-failover-check-gateway.png`: corte en `ether1`, primaria inactiva (`Is`) con `immediate-gw=""`, respaldo activo (`As`).
- `capturas/f4/drills/drill-4-enlace-restaurado.png`: restauración de `ether1`, retorno de preferencia a la primaria (`As`) por menor distancia.
- `capturas/f4/drills/drill-4-rutas-limpias.png`: eliminación completa de las rutas temporales de prueba.

## Post-mortem

- **Qué ocurrió:** Se simuló una pérdida de enlace WAN primario deshabilitando administrativamente `ether1`. El mecanismo de sondeo de gateway de RouterOS detectó la inalcanzabilidad de `10.100.1.1` y conmutó el tráfico hacia el gateway secundario `10.200.1.1`.
- **Impacto observado:** Detección precisa sin colapso del subsistema de ruteo; failover transparente de la ruta estática activa a la de contingencia.
- **Causa:** El sondeo periódico de `check-gateway=ping` generó timeout en 3 intentos sucesivos, retirando la condición de alcanzabilidad del next-hop de distancia 1.
- **Qué funcionó:** La selección de rutas basada en distancias administrativas ponderadas combinada con `check-gateway` operó exactamente según el diseño teórico de RouterOS v7.
- **Qué debe corregirse / consideraciones:** En entornos con BGP convergido y rutas dinámicas por defecto, el uso de rutas estáticas con `check-gateway` debe limitarse a prefijos específicos o bien requerir distancias inferiores a las de eBGP (distancia 20) para evitar colisiones en la tabla de ruteo. La prueba se ejecutó sobre un prefijo `/32` de prueba para no perturbar la tabla global de producción.

