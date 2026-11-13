# configs/ — Scripts definitivos de los 7 routers

Scripts RouterOS 7.24.1 para reprovisionar la topología desde cero. Son el estado de **diseño final** (cierre de F4), no un volcado crudo: se construyeron a partir de `backups/F4/*-F4.rsc` y se corrigieron las diferencias descritas abajo.

| Archivo | Router | Router-ID |
|---|---|---|
| `EDGE.rsc` | Borde / eBGP AS 65000 | 3.3.3.3 |
| `ISP-1.rsc` | Proveedor primario AS 65001 | 1.1.1.1 |
| `ISP-2.rsc` | Proveedor secundario AS 65002 | 2.2.2.2 |
| `CORE-1.rsc` | Núcleo OSPF Área 0 | 4.4.4.4 |
| `CORE-2.rsc` | Núcleo OSPF Área 0 | 5.5.5.5 |
| `DIST-1.rsc` | Distribución, Master VRID 10 | 6.6.6.6 |
| `DIST-2.rsc` | Distribución, Master VRID 20 | 7.7.7.7 |

## Secretos: no están en el repositorio

Los exports de RouterOS no incluyen claves ni contraseñas (se exportan sin `show-sensitive`), por lo que un `.rsc` crudo no levanta OSPF MD5, BGP TCP-MD5 ni VRRP. Estos scripts llevan **tokens** `__NOMBRE__` en cada lugar donde va un secreto:

| Token | Dónde se usa |
|---|---|
| `__OSPF_MD5_KEY__` | `auth-key` de las interface-template OSPF (EDGE, CORE-1/2, DIST-1/2) |
| `__BGP_KEY_ISP1__` / `__BGP_KEY_ISP2__` | `tcp-md5-key` de cada peering (EDGE e ISP del lado correspondiente) |
| `__VRRP_KEY__` | `password` de autenticación simple VRRP (DIST-1/2) |
| `__SNMP_COMMUNITY__` | Nombre de la comunidad SNMP v2c (los 7 routers) |
| `__NETADMIN_PASSWORD__` / `__MONITOR_PASSWORD__` | Usuarios `netadmin` y `monitor` (los 7 routers) |

### Procedimiento

```bash
cp configs/secrets.example.env configs/secrets.env   # completar con los valores reales (fuera de Git)
python3 configs/validate.py                          # validación estática de los .rsc
./configs/render.sh                                  # genera configs/<ROUTER>.rendered.rsc
```

Luego, en cada router: subir `<ROUTER>.rendered.rsc` (SFTP/WinBox), `/import file-name=<ROUTER>.rendered.rsc`, verificar y **borrar** el archivo renderizado. Tras comprobar el login con `netadmin`, ejecutar `/user remove [find name=admin]`.

- `configs/secrets.env` y `configs/*.rendered.rsc` están en `.gitignore`.
- Los valores solo pueden usar `A-Z a-z 0-9 . _ @ % + : -` (van sin comillas en RouterOS); `render.sh` rechaza otros caracteres y los lee como texto, sin ejecutarlos.
- Las dos claves BGP deben ser distintas entre sí, y cada ISP debe usar la misma que EDGE para su peering.

## Diferencias respecto de los exports `backups/F4/`

Los exports F4 se conservan intactos como registro histórico del cierre. En `configs/` se aplicaron estos cambios:

| # | Cambio | Motivo |
|---|---|---|
| 1 | **EDGE:** `ether2` habilitada (el export F4 la tenía con `disabled=yes`) | Con `ether2` caída no se establece el peering con ISP-2 y se pierde el dual-homing diseñado. No hay ningún drill documentado que explique ese estado al cierre. |
| 2 | Se quitó la línea `# system id = …` | Metadato de la instancia de simulación; la política del repositorio (memoria §6.2) es no versionarlo. Había reaparecido en los siete exports F4. |
| 3 | `client1` (DHCP client en `ether1`) con `disabled=yes` en los 7 | Baseline de hardening de F1 (memoria §2.3). Los exports F2–F4 lo muestran habilitado. |
| 4 | `ssh`/`winbox` con `available-from=10.0.0.0/8,192.168.0.0/16` en CORE-1/2 e ISP-1/2 | Baseline F1 (§2.3). EDGE y DIST ya lo traían (EDGE con rangos más estrictos). |
| 5 | `/ip service set reverse-proxy disabled=yes` | Baseline F1 (§2.3). |
| 6 | `/tool mac-server`, `mac-winbox` con `allowed-interface-list=none` y `mac-server ping` deshabilitado | Baseline F1 (§2.3). Ausentes en los exports F2–F4. |
| 7 | Usuarios `netadmin` (grupo `full`) y `monitor` (grupo `monitor-ro`) con contraseña tokenizada | RBAC de memoria §1.3 y §2.3. Los exports no los incluyen. |
| 8 | Claves OSPF/BGP/VRRP tokenizadas (`auth-key`, `tcp-md5-key`, `password`) | Sin ellas las autenticaciones no se aplican en un reprovisionamiento. |
| 9 | Comunidad SNMP: `REDACTED` → `__SNMP_COMMUNITY__` | Importar `REDACTED` dejaría esa palabra literal como comunidad. |
| 10 | Líneas con continuación `\` unidas en una sola | Evita errores de importación por saltos de línea. |

### Qué es reconstrucción y no export

- El grupo **`monitor-ro`** (`policy=local,ssh,winbox,read`) no aparece en ningún export; se definió con el mínimo necesario para que `monitor` sea de solo lectura. Verificar contra el estado real con `/user group print detail`.
- Los puntos 3–7 se tomaron de lo que la memoria documenta como verificado en F1. Si los routers reales ya no coinciden, es una regresión de hardening posterior a F1 que conviene revisar (ver "Verificación pendiente").

## Validación realizada y alcance

`validate.py` comprueba de forma **estática**: tokens esperados por router, sintaxis básica, Router-ID = loopback, cada `/30` con exactamente dos extremos, VIP VRRP únicas y compartidas, pares BGP espejados (local/remote y token de clave), prioridades VRRP 150/100 cruzadas y MD5 en todas las templates OSPF no pasivas.

**No se importaron en un CHR limpio.** Hasta que eso se haga, el criterio "reprovisionamiento desde cero" está validado solo estáticamente.

## Verificación pendiente en los routers reales

Para confirmar si el laboratorio vivo coincide con estos scripts:

```routeros
/interface print where name=ether2                    # EDGE: ¿disabled?
/ip dhcp-client print                                 # ¿client1 deshabilitado?
/tool mac-server print ; /tool mac-server mac-winbox print
/ip service print where name~"ssh|winbox|reverse"
/user print ; /user group print detail
```
