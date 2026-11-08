# F4 — Manifiesto de backups consolidados

**Estado al 08/11/2026:** COMPLETADO. Los siete exports finales de RouterOS correspondientes al cierre operativo de F4 han sido generados, saneados y validados en el repositorio. **Responsable operativo:** Patricio Borda (R2 + R5).

## Inventario de exports F4

| Router | Archivo generado | Estado | Descripción |
|---|---|---|---|
| EDGE | `EDGE-F4.rsc` | Verificado | Configuración final de Borde: eBGP dual-homing, OSPF default-originate y firewall perimetral. |
| ISP-1 | `ISP-1-F4.rsc` | Verificado | Proveedor primario AS 65001, eBGP peering y simulación de loopback pública 1.1.1.1. |
| ISP-2 | `ISP-2-F4.rsc` | Verificado | Proveedor secundario AS 65002, eBGP peering y simulación de loopback pública 2.2.2.2. |
| CORE-1 | `CORE-1-F4.rsc` | Verificado | Núcleo OSPF backbone área 0, enlace inter-core e interfaces hacia distribución. |
| CORE-2 | `CORE-2-F4.rsc` | Verificado | Núcleo OSPF backbone área 0, enlace inter-core e interfaces hacia distribución. |
| DIST-1 | `DIST-1-F4.rsc` | Verificado | Distribución: VRRP Master VLAN 10 (USERS) / Backup VLAN 20, OSPF pasivo en accesos. |
| DIST-2 | `DIST-2-F4.rsc` | Verificado | Distribución: VRRP Master VLAN 20 (SERVERS) / Backup VLAN 10, OSPF pasivo en accesos. |

## Saneamiento y seguridad

Todos los archivos han sido depurados manualmente:
1. Se excluyeron contraseñas en texto claro, hashes y tokens sensibles.
2. Claves de autenticación MD5 de OSPF y BGP han sido sanitizadas (`REDACTED`).
3. Se comprobó la integridad sintáctica de los siete archivos para reproducción o provisión desde cero.
