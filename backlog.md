# Backlog — Laboratorio Failover Routing

**Grupo:** 5 · **Vencimiento final:** vie 23/10

## Leyenda de estado

- `[ ]` pendiente · `[~]` en curso · `[x]` hecho
- Cada tarea lleva **dueño** (rol): `[R1]` … `[R5]`.

---

## Epic F0 — Diseño y gestión de cambio · _vence vie 2/10_

### IPAM / direccionamiento

- [x] [R1] Definir subredes /30 para enlaces WAN y Core-Core
- [x] [R3] Definir subredes /30 para enlaces Core-Distribución
- [x] [R4] Definir subredes /24 para VLANs de Usuarios y Servidores (sin solapamiento)

### Corrección del diagrama (≥ 3 defectos)

- [x] [R1] Documentar corrección del SPOF en el borde (ausencia de HA)[cite: 3, 6]
- [x] [R3] Documentar el agregado del enlace físico core-core entre C1 y C2[cite: 3, 6]
- [x] [R4] Documentar el traslado del FHRP de HSRP/Core a VRRP/Distribución[cite: 3, 6]

### Política de seguridad

- [x] [R1] Definir usuarios mínimos, privilegios y servicios a deshabilitar
- [x] [R3] Establecer esquemas de autenticación criptográfica (OSPF MD5, BGP TCP-MD5)

### Política de operación (change log + backup)

- [x] [R5] Definir convención de commits (Conventional Commits) y formato del Change Log
- [x] [R5] Establecer política de respaldos (`/export` y snapshots)

### Repositorio git

- [x] [R5] Crear estructura de directorios, README.md y commits iniciales de la F0

---

## Epic F1 — Topología + hardening + backup · _vence vie 9/10_

### Despliegue (7 CHR + 2 switches + 2 hosts)

- [~] [R3] Levantar los 7 routers CHR, 2 switches y 2 hosts en GNS3 según la topología aprobada en F0.
- [~] [R3] Cablear los nodos y comprobar que las conexiones coincidan con el diagrama.
- [~] [R4] Capturar la topología completa y verificar que se vean los 7 routers, 2 switches y 2 hosts.

### IPs de enlace + loopbacks

- [ ] [R3] Configurar las IPs de todos los enlaces de acuerdo con el IPAM definido en F0.
- [ ] [R3] Configurar las loopbacks y los router-IDs acordados para los 7 routers.
- [ ] [R4] Completar en `docs/memoria.md` la tabla de interfaces, IPs, vecinos, loopbacks y router-IDs.
- [ ] [R4] Verificar y documentar los pings entre vecinos directos; guardar las evidencias en `capturas/F1/conectividad/`.

### Snapshot BASE

- [ ] [R3] Crear el snapshot BASE del proyecto GNS3 con la topología desplegada en el estado inicial acordado.
- [ ] [R4] Documentar en `docs/memoria.md` la fecha, el nombre y el estado incluido en el snapshot; guardar su evidencia si corresponde.

### Hardening (los 7 routers)

- [ ] [R3] Configurar una contraseña administrativa segura y crear el usuario `monitor` con privilegios mínimos en los 7 routers.
- [ ] [R3] Deshabilitar en los 7 routers los servicios innecesarios definidos en la política de seguridad de F0.
- [ ] [R4] Verificar usuarios, privilegios y servicios en cada router; registrar los comandos y resultados en `docs/memoria.md` y guardar evidencias en `capturas/F1/hardening/`.

### Backup inicial (`/export`)

- [ ] [R3] Ejecutar `/export` en ISP-1, ISP-2, EDGE, CORE-1, CORE-2, DIST-1 y DIST-2, generando un archivo por router.
- [ ] [R4] Revisar que estén los 7 exports, identificarlos correctamente y guardarlos en `backups/F1/exports/`.
- [ ] [R4] Versionar los 7 archivos `.rsc` en Git y registrar el commit correspondiente; revisar que no se incluyan secretos agregados deliberadamente.

---

## Epic F2 — VRRP + OSPF · _vence vie 16/10_

### VRRP (2 grupos, load-sharing, auth)

- [ ] [R4] configurar VRRP vrid 10 en DIST-1 (master)
- [ ] [R4] configurar VRRP vrid 20 en DIST-2 (master)
- [ ] [R4] activar auth simple en ambos grupos
- [ ] [R5] verificar master/backup con `/interface vrrp print`

### OSPF área 0 (con MD5, incluido core–core)

- [ ] <!-- [R#] tarea -->

### Verificación L3 (ping intra-LAN + gateway virtual)

- [ ] <!-- [R#] tarea -->

---

## Epic F3 — BGP + firewall · _vence vie 16/10_

### eBGP multi-homing (2 sesiones, TCP-MD5)

- [ ] <!-- [R#] tarea -->

### Redistribución OSPF→BGP

- [ ] <!-- [R#] tarea -->

### Salida a "Internet" (host → loopback ISP)

- [ ] <!-- [R#] tarea -->

### Firewall edge (filtro + plano de gestión)

- [ ] <!-- [R#] tarea -->

---

## Epic F4 — Drills + monitoreo · _vence mar 20/10_

### Los 5 drills (runbook + post-mortem + tiempo)

- [ ] <!-- [R#] tarea -->

### Monitoreo (SNMP/chequeos)

- [ ] <!-- [R#] tarea -->

### Verificación de seguridad (clave incorrecta falla)

- [ ] <!-- [R#] tarea -->

---

## Epic F5 — Memoria + defensa · _vence vie 23/10_

### Memoria (plantilla completa)

- [ ] <!-- [R#] tarea -->

### Backlog cerrado (todo en "hecho")

- [ ] <!-- [R#] tarea -->

### Defensa oral (parte propia + ajena)

- [ ] <!-- [R#] tarea -->
