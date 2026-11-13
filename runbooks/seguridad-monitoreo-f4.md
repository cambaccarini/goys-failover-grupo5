# F4 — Seguridad y monitoreo (R3)

**Fecha:** 12/11/2026  
**Responsable:** Ian Vidmar (R3)  
**Alcance:** prueba negativa OSPF MD5, logging local y SNMP v2c en los siete routers.

## 1. Prueba negativa OSPF MD5

Se comprobó el comportamiento ante una discordancia de clave MD5 en OSPF. Los registros de CORE-1 mostraron mensajes `authentication failed` y `md5 mismatch` procedentes de vecinos en enlaces de tránsito. Durante el desajuste, las adyacencias afectadas no alcanzaban `Full`; las salidas intermedias mostraron estados `Init`, `Exchange` y `Loading`.

Después de restablecer la clave coincidente, `/routing ospf neighbor print` en CORE-1 mostró cuatro vecinos en estado `Full`:

| Interfaz | Vecino | Router ID | Estado final |
|---|---|---|---|
| ether1 | 10.10.1.1 | 3.3.3.3 | Full |
| ether2 | 10.20.1.2 | 5.5.5.5 | Full |
| ether3 | 10.30.1.2 | 6.6.6.6 | Full |
| ether4 | 10.30.2.2 | 7.7.7.7 | Full |

**Resultado:** la autenticación rechazó los paquetes con firma no coincidente y las adyacencias se recuperaron al restaurar la clave correcta.

Evidencias: `capturas/f4/seguridad/ospf-md5/`.

## 2. Logging local en los siete routers

Se configuró una acción local persistente llamada `estadored`, con destino `disk`, dos archivos rotativos y hasta 500 líneas por archivo. Se agregaron reglas para:

```routeros
/system logging action
add name=estadored target=disk disk-file-name=estadored disk-file-count=2 disk-lines-per-file=500

/system logging
add topics=interface,info action=estadored
add topics=ospf action=estadored
add topics=bgp action=estadored
```

Las capturas muestran la configuración en los routers y registros de eventos de interfaz/OSPF. Los exports finales contienen la acción y las reglas en los siete equipos.

Evidencias: `capturas/f4/monitoreo/logging/`.

## 3. SNMP v2c en los siete routers

Se habilitó SNMP con una comunidad de lectura, limitada a las redes LAN:

```routeros
/snmp community
set [find default=yes] name=<COMUNIDAD_LOCAL> addresses=192.168.10.0/24,192.168.20.0/24 read-access=yes write-access=no

/snmp
set enabled=yes contact="grupo5" location="GNS3-lab"
```

Se verificó en cada router con `/snmp print` y `/snmp community print`. Las capturas confirman `enabled: yes`, `read-access: yes`, `write-access: no` y las dos subredes autorizadas.

**Limitación de validación:** no se ejecutó `snmpwalk`. Virtual PC Simulator 0.8.4 no incluye esa utilidad y no se logró acceder desde el PC personal a la red de GNS3. Por eso queda verificada la configuración SNMP en los routers, pero no una consulta MIB-II extremo a extremo desde un host.

Evidencias: `capturas/f4/monitoreo/snmp/`.

## 4. Exports y saneamiento

Se regeneraron los siete exports F4 y se incorporaron en `backups/F4/`. La comunidad SNMP real se sustituyó por `REDACTED` antes de versionar. Los archivos incluyen las reglas SNMP y logging del cierre.

**Seguridad:** no introducir la comunidad operativa real en Git. Reemplazar el marcador por un secreto local únicamente al restaurar la configuración.

## 5. Estado de cierre

- [x] Prueba negativa OSPF MD5 y recuperación de adyacencias.
- [x] Logging local a disco para `interface`, `ospf` y `bgp` en siete routers.
- [x] SNMP v2c de solo lectura configurado y restringido a las LAN en siete routers.
- [ ] `snmpwalk` desde host: no ejecutado por limitaciones del entorno; no se considera validado.
- [x] Exports F4 regenerados y saneados.
- [x] Evidencias y documentación incorporadas.

F4 se considera cerrada en cuanto a las tareas de implementación y documentación previstas. La limitación de `snmpwalk` queda explícita para no presentar como realizada una prueba que no pudo ejecutarse.
