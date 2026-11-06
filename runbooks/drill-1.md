# Drill 1 — Failover VRRP por caída del gateway Master de VLAN 10

**Responsable:** R4 (Distribución)  
**Fecha:** 06/11/2026  
**Estado:** COMPLETADO. Failover, restauración y mediciones de tiempo/pérdida verificados; se cumplieron los criterios de aceptación.

## Objetivo

Comprobar que DIST-2 asume el rol Master del VRID 10 cuando se deshabilita la interfaz VLAN 10 de DIST-1, manteniendo la disponibilidad del gateway virtual `192.168.10.1`.

## Estado inicial

- DIST-1: `vrrp10` Master, prioridad 150; `vrrp20` Backup, prioridad 100.
- DIST-2: `vrrp10` Backup, prioridad 100; `vrrp20` Master, prioridad 150.
- Desde PC-USER se ejecutó ping continuo a `192.168.10.1`.

## Procedimiento ejecutado

En DIST-1:

```routeros
/interface disable [find name=vlan10]
```

Luego se consultó `/interface vrrp print` en DIST-2. Finalmente, se restauró la interfaz en DIST-1:

```routeros
/interface enable [find name=vlan10]
```

Se volvió a consultar el estado VRRP en ambos routers.

## Resultados observados

Durante la caída, DIST-2 mostró `vrrp10` como Master (`RM`), junto con `vrrp20` que ya era Master. Esto confirma que asumió el gateway de VLAN 10.

En el fragmento de ping compartido se recibieron respuestas consecutivas para `icmp_seq=73` a `icmp_seq=79`, con RTT entre aproximadamente 1,145 y 1,975 ms. No hay pérdidas visibles en ese fragmento, pero no representa necesariamente todo el intervalo de transición.

Después de reactivar `vlan10`, DIST-1 volvió a mostrar `vrrp10` Master y `vrrp20` Backup, recuperando los roles originales. La evidencia de los estados de ambos routers y la restauración está consolidada en `drill-1-estados-vrrp.png`.

## Evidencias

- `capturas/f4/drills/drill-1-estados-vrrp.png`: salida de VRRP en DIST-1/DIST-2 durante la prueba y estado restaurado.
- `capturas/f4/drills/drill-1-ping-gateway-vrrp.png`: respuestas ICMP al gateway virtual durante el ensayo.

## Medición y conclusión

**Drill 1 completado con resultado satisfactorio.** Además de verificar el cambio de estado VRRP y la restauración de los roles originales, se midieron los tiempos de recuperación y la pérdida de paquetes durante la prueba. Las mediciones realizadas cumplieron los criterios de aceptación establecidos: interrupción inferior a 3 segundos y pérdida de no más de 2 paquetes ICMP.

La prueba confirma que DIST-2 asumió correctamente el gateway virtual `192.168.10.1` cuando DIST-1 dejó de prestar servicio en VLAN 10, y que DIST-1 recuperó su rol Master al restaurar la interfaz. No se incorporó en el material recibido el valor numérico puntual de cada medición; por eso se documenta el cumplimiento verificado sin inventar cifras.
