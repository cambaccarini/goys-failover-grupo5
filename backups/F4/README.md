# F4 — Manifiesto de backups pendientes

**Estado al 07/11/2026:** pendiente de generación y verificación de los siete exports finales. La ejecución de los drills 3 y 5 no produce automáticamente una copia de configuración de RouterOS. **Responsable operativo:** Patricio Borda (R2 + R5). Los exports F3 ya versionados no sustituyen a los F4.

## Inventario de exports F4

| Router | Archivo esperado | Estado |
|---|---|---|
| EDGE | `EDGE-F4.rsc` | Pendiente |
| ISP-1 | `ISP-1-F4.rsc` | Pendiente |
| ISP-2 | `ISP-2-F4.rsc` | Pendiente |
| CORE-1 | `CORE-1-F4.rsc` | Pendiente |
| CORE-2 | `CORE-2-F4.rsc` | Pendiente |
| DIST-1 | `DIST-1-F4.rsc` | Pendiente |
| DIST-2 | `DIST-2-F4.rsc` | Pendiente |

## Obtención (en RouterOS, una vez restaurado el estado normal)

Desde la consola de **cada router** correspondiente, ejecutar `/export file=EDGE-F4`, `/export file=ISP-1-F4`, `/export file=ISP-2-F4`, `/export file=CORE-1-F4`, `/export file=CORE-2-F4`, `/export file=DIST-1-F4` o `/export file=DIST-2-F4` según corresponda. Esto crea el archivo `.rsc` en el sistema de archivos del router. Descargarlo y guardarlo en este directorio con el nombre del inventario.

No incluir `show-sensitive`, claves de OSPF/BGP/VRRP, comunidades SNMP, contraseñas, tokens ni metadatos innecesarios. Revisar **cada archivo** manualmente antes de commitear. No subir `.backup` binarios ni ningún secreto. Si el export contiene datos sensibles aunque se haya generado sin `show-sensitive`, retirarlos antes de versionarlo.

## Verificaciones de cierre

1. EDGE: comprobar nuevamente BGP con ISP-1 e ISP-2 establecido, la default principal por `10.100.1.1`, y que `ether1` esté habilitada.
2. DIST-1/DIST-2: comprobar Master de VRID 10 en DIST-1 y de VRID 20 en DIST-2.
3. ISP-1, ISP-2, CORE-1 y CORE-2: verificar estado operativo antes de exportar.
4. Confirmar exactamente siete `.rsc` legibles, saneados y con nombres consistentes.
5. Actualizar `docs/memoria.md`, `backlog.md` y Change Log **después** de realizar y validar los backups, no antes.

Los resultados del Drill 3 y Drill 5 están documentados en `runbooks/drill-3.md` y `runbooks/drill-5.md`. Este documento es un registro de pendientes, **no** una certificación de backups existentes.
