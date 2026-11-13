# F4 — Manifiesto de backups consolidados

**Estado al 12/11/2026:** ACTUALIZADOS PARA EL CIERRE DE F4. Los siete exports se regeneraron a partir de las configuraciones posteriores a la incorporación de SNMP v2c y logging local. **Responsable operativo:** Patricio Borda (R2 + R5).

## Inventario de exports F4

| Router | Archivo generado | Estado | Descripción |
|---|---|---|---|
| EDGE | `EDGE-F4.rsc` | Verificado | Configuración final de Borde: eBGP dual-homing, OSPF default-originate, firewall perimetral, SNMP v2c y logging. |
| ISP-1 | `ISP-1-F4.rsc` | Verificado | Proveedor primario AS 65001, eBGP peering, loopback 1.1.1.1, SNMP v2c y logging. |
| ISP-2 | `ISP-2-F4.rsc` | Verificado | Proveedor secundario AS 65002, eBGP peering, loopback 2.2.2.2, SNMP v2c y logging. |
| CORE-1 | `CORE-1-F4.rsc` | Verificado | Núcleo OSPF backbone área 0, enlace inter-core, interfaces hacia distribución, SNMP v2c y logging. |
| CORE-2 | `CORE-2-F4.rsc` | Verificado | Núcleo OSPF backbone área 0, enlace inter-core, interfaces hacia distribución, SNMP v2c y logging. |
| DIST-1 | `DIST-1-F4.rsc` | Verificado | Distribución: VRRP Master VLAN 10 (USERS) / Backup VLAN 20, OSPF pasivo en accesos, SNMP v2c y logging. |
| DIST-2 | `DIST-2-F4.rsc` | Verificado | Distribución: VRRP Master VLAN 20 (SERVERS) / Backup VLAN 10, OSPF pasivo en accesos, SNMP v2c y logging. |

## Saneamiento y seguridad

Todos los archivos han sido depurados manualmente:
1. Se excluyeron contraseñas en texto claro, hashes y tokens sensibles.
2. Claves de autenticación MD5 de OSPF y BGP han sido sanitizadas (`REDACTED`).
3. Se comprobó la integridad sintáctica de los siete archivos para reproducción o provisión desde cero.

## Cambios del cierre F4 (12/11/2026)

- Los siete exports incluyen la configuración de SNMP v2c y logging local a disco.
- La comunidad SNMP se reemplazó por `REDACTED` en los archivos del repositorio. La comunidad operativa real no debe versionarse.
- SNMP se configuró como solo lectura y limitado a `192.168.10.0/24` y `192.168.20.0/24`.
- Logging utiliza la acción `estadored` y reglas para eventos `interface`, `ospf` y `bgp`.
- La consulta `snmpwalk` no se realizó por limitaciones del host de prueba; no se afirma que la lectura MIB-II haya sido validada de extremo a extremo.
- Evidencias: `capturas/f4/monitoreo/`.
