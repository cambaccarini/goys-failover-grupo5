# Backlog — Laboratorio Failover Routing
**Grupo:** 5 · **Vencimiento final:** vie 23/10

## Leyenda de estado
- `[ ]` pendiente · `[~]` en curso · `[x]` hecho
- Cada tarea lleva **dueño** (rol): `[R1]` … `[R5]`.

---

## Epic F0 — Diseño y gestión de cambio · *vence vie 2/10*

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

## Epic F1 — Topología + hardening + backup · *vence vie 9/10*

### Despliegue (7 CHR + 2 switches + 2 hosts)
- [ ] <!-- [R#] tarea -->

### IPs de enlace + loopbacks
- [ ] <!-- [R#] tarea -->

### Snapshot BASE
- [ ] <!-- [R#] tarea -->

### Hardening (los 7 routers)
- [ ] <!-- [R#] tarea -->

### Backup inicial (`/export`)
- [ ] <!-- [R#] tarea -->

---

## Epic F2 — VRRP + OSPF · *vence vie 16/10*

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

## Epic F3 — BGP + firewall · *vence vie 16/10*

### eBGP multi-homing (2 sesiones, TCP-MD5)
- [ ] <!-- [R#] tarea -->

### Redistribución OSPF→BGP
- [ ] <!-- [R#] tarea -->

### Salida a "Internet" (host → loopback ISP)
- [ ] <!-- [R#] tarea -->

### Firewall edge (filtro + plano de gestión)
- [ ] <!-- [R#] tarea -->

---

## Epic F4 — Drills + monitoreo · *vence mar 20/10*

### Los 5 drills (runbook + post-mortem + tiempo)
- [ ] <!-- [R#] tarea -->

### Monitoreo (SNMP/chequeos)
- [ ] <!-- [R#] tarea -->

### Verificación de seguridad (clave incorrecta falla)
- [ ] <!-- [R#] tarea -->

---

## Epic F5 — Memoria + defensa · *vence vie 23/10*

### Memoria (plantilla completa)
- [ ] <!-- [R#] tarea -->

### Backlog cerrado (todo en "hecho")
- [ ] <!-- [R#] tarea -->

### Defensa oral (parte propia + ajena)
- [ ] <!-- [R#] tarea -->
