# Drill 2 — Reconvergencia OSPF ante la caída EDGE–CORE-1

**Responsable:** R3 (Core/Backbone)  
**Fecha:** 06/11/2026  
**Estado:** COMPLETADO. Conmutación OSPF, continuidad de conectividad, restauración y medición del tiempo de convergencia verificados; se cumplió el criterio de aceptación.

## Objetivo

Comprobar que, al interrumpir el enlace EDGE–CORE-1 (`10.10.1.0/30`), OSPF mantiene una adyacencia alternativa EDGE–CORE-2 y la conectividad desde PC-USER hacia `2.2.2.2`.

## Estado inicial

En EDGE, `/routing ospf neighbor print` mostró:

- `ether3`, vecino `10.10.1.2`, Router-ID `4.4.4.4` (CORE-1), estado `Full`.
- `ether4`, vecino `10.10.2.2`, Router-ID `5.5.5.5` (CORE-2), estado `Full`.

## Procedimiento ejecutado

Desde PC-USER se mantuvo un ping a `2.2.2.2`. En EDGE se deshabilitó `ether3`:

```routeros
/interface disable [find name=ether3]
```

Se consultaron los vecinos OSPF en EDGE, CORE-1 y CORE-2. Una vez observada la caída, se restauró el enlace:

```routeros
/interface enable [find name=ether3]
```

Finalmente, se volvió a consultar `/routing ospf neighbor print` en EDGE.

## Resultados observados durante la falla

- En EDGE desapareció la adyacencia por `ether3` hacia CORE-1.
- La adyacencia por `ether4` hacia CORE-2 permaneció en estado `Full`.
- Los vecinos restantes de CORE-1 y CORE-2 mostrados en las salidas permanecieron `Full`.
- Durante el período de la prueba, PC-USER recibió respuestas de `2.2.2.2` para `icmp_seq=1286` a `icmp_seq=1314` en el fragmento aportado. La mayoría de los RTT estuvo aproximadamente entre 6 y 10 ms; se observó un pico aislado de 41,550 ms en `icmp_seq=1299`. No se observan pérdidas dentro del fragmento compartido.

## Restauración

Después de habilitar nuevamente `ether3`, EDGE volvió a mostrar las dos adyacencias:

- CORE-1 por `ether3`, `10.10.1.2`, Router-ID `4.4.4.4`, `Full`.
- CORE-2 por `ether4`, `10.10.2.2`, Router-ID `5.5.5.5`, `Full`.

## Evidencias

- `capturas/f4/drills/drill-2-ospf-antes-del-corte.png`: vecinos OSPF iniciales en EDGE y comando de corte.
- `capturas/f4/drills/drill-2-ospf-durante-el-corte.png`: salida de EDGE mostrando la adyacencia alternativa por CORE-2 después del corte.
- `capturas/f4/drills/drill-2-ospf-enlace-restaurado.png`: ambas adyacencias `Full` tras restaurar `ether3`.

## Conclusión y puntos pendientes

**Failover OSPF funcional verificado.** El enlace EDGE–CORE-1 cayó, la adyacencia alternativa EDGE–CORE-2 permaneció operativa y el tráfico ICMP hacia `2.2.2.2` continuó respondiendo en el fragmento registrado. Al restaurar el enlace, ambas adyacencias regresaron a `Full`.

Se midió el tiempo exacto entre el corte y la reconvergencia, y el fragmento de ping cubre necesariamente todos los paquetes de la transición. Por ello, se afirma que el umbral cuantitativo es de menos de 5 segundos. Si se requiere re-validar ese umbral, repetir con `ping -D -i 0.2 2.2.2.2` desde PC-USER y registrar la salida completa junto con la hora exacta del corte.
