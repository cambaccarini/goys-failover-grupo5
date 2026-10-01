# Memoria del Laboratorio — Failover Routing

**Grupo:** 5
**Materia:** Gestión Operativa y Seguridad en Redes (GOYS)
**Fecha de entrega:** viernes 23/10/2026

## Integrantes y roles

| Integrante | Rol |
|-----------|-----|
| Camila Baccarini | R1 — Líder / Edge-WAN |
| Patricio Borda | R2 — Proveedores (ISP) |
| Ian Vidmar | R3 — Core |
| Juan Atencio | R4 — Distribución |
| Integrante 5 | R5 — Hosts / QA / Operación | 

---

## 1. Diseño (F0)

### 1.1 Corrección del diagrama

| # | Defecto detectado | Corrección aplicada | Justificación |
|:-:|-------------------|---------------------|---------------|
| 1 | Firewall sin par HA (SPOF) en el borde. | Se documenta la necesidad de un par activo/standby para el firewall de borde. | En producción, un único ASA 5506-X representa un Single Point of Failure crítico. Para la resiliencia requerida (Edge-WAN), se necesita failover de hardware. |
| 2 | Subredes solapadas (ej. 192.168.10.0/24 en Site 1 y 2). | Se diseñó un esquema IPAM estricto (VLAN 10 para usuarios, VLAN 20 para servidores) sin repeticiones. | El solapamiento de subredes impide el correcto enrutamiento entre sitios. Un diseño jerárquico exige direccionamiento limpio y sumarizable. |
| 3 | Sin enlace directo Core-Core (C1 a C2). | Se agregó un enlace físico /30 dedicado (`core-core`) entre CORE-1 y CORE-2. | Es vital para evitar asimetrías de ruteo, prevenir path pinholes y permitir la rápida sincronización de bases de datos OSPF (LSA) en el área 0. |
| 4 | HSRP ubicado en la capa Core. | Se movió la redundancia de primer salto (VRRP) a la capa de Distribución. | El Core debe enfocarse exclusivamente en conmutación rápida de paquetes (tránsito puro). El FHRP pertenece al bloque de distribución. |

### 1.2 Plan de direccionamiento (IPAM)

| Enlace / Red | Subred | Dispositivo A (IP/iface) | Dispositivo B (IP/iface) |
|--------------|:------:|--------------------------|--------------------------|
| ISP-1 ↔ EDGE | 10.100.1.0/30 | ISP-1 (10.100.1.1) | EDGE (10.100.1.2) |
| ISP-2 ↔ EDGE | 10.200.1.0/30 | ISP-2 (10.200.1.1) | EDGE (10.200.1.2) |
| EDGE ↔ CORE-1 | 10.10.1.0/30 | EDGE (10.10.1.1) | CORE-1 (10.10.1.2) |
| EDGE ↔ CORE-2 | 10.10.2.0/30 | EDGE (10.10.2.1) | CORE-2 (10.10.2.2) |
| CORE-1 ↔ CORE-2 (core-core) | 10.20.1.0/30 | CORE-1 (10.20.1.1) | CORE-2 (10.20.1.2) |
| CORE ↔ DIST-1 (×2) | 10.30.1.0/30 y 10.30.3.0/30 | CORE-1/2 (10.30.1.1, 10.30.3.1) | DIST-1 (10.30.1.2, 10.30.3.2) |
| CORE ↔ DIST-2 (×2) | 10.30.2.0/30 y 10.30.4.0/30 | CORE-1/2 (10.30.2.1, 10.30.4.1) | DIST-2 (10.30.2.2, 10.30.4.2) |
| USERS (gateway VRRP) | 192.168.10.0/24 | DIST-1/DIST-2 | `192.168.10.1` (IP Virtual) |
| SERVERS (gateway VRRP) | 192.168.20.0/24 | DIST-1/DIST-2 | `192.168.20.1` (IP Virtual) |

**VRRP:**

| Grupo | VRID | Master | Priority | IP virtual |
|-------|:----:|:------:|:--------:|:----------:|
| USERS | 10 | DIST-1 | 150 | 192.168.10.1 |
| SERVERS | 20 | DIST-2 | 150 | 192.168.20.1 |

**Router-IDs:** 
* CORE-1: `4.4.4.4`
* CORE-2: `5.5.5.5`
* *(A completar el resto según la topología GNS3)*

### 1.3 Política de seguridad

- **Usuarios y privilegios:** Se prohíbe el uso de credenciales por defecto. Se configurará un usuario administrador fuerte y un usuario de solo lectura (`monitor`) para auditoría y visualización del estado.
- **Servicios que se deshabilitan:** Se apagarán todos los servicios de administración en texto plano y de descubrimiento de capa 2 innecesarios (Telnet, HTTP, FTP, MNDP en interfaces públicas). 
- **Claves de autenticación** (OSPF / BGP / VRRP): OSPF operará con autenticación MD5; las sesiones eBGP utilizarán TCP-MD5; los grupos VRRP requerirán autenticación simple/clave compartida.

### 1.4 Política de operación

- **Formato del change log** (convención de commits): Se utilizará *Conventional Commits* en el repositorio Git (`feat`, `fix`, `docs`, `ops`, `chore`). Un commit representará un único cambio lógico. El Change Log (sección 6.1) debe coincidir con el historial de Git.
- **Política de backup** (cuándo y cómo): El rol R5 (operaciones) ejecutará `/export` (en texto plano versionado en Git) y `/system backup save` (binario local) de todos los nodos al finalizar cada épica (F1 a F4) y antes de los drills destructivos. Se validará la viabilidad de restauración.

--- Fase 1 ---

## 2. Topología 

> Pegar acá la captura del proyecto GNS3 (o el diagrama) con las 5 capas identificadas.

```
[INTERNET] [EDGE] [CORE] [DISTRIBUTION] [ACCESS]
<!-- insertar diagrama/captura -->
```

---

## 3. Configuración

> Un bloque por dispositivo. Se puede referenciar el archivo `.rsc` del repo y pegar el contenido final.

### 3.1 ISP-1
```routeros
<!-- config final -->
```

### 3.2 ISP-2
```routeros
<!-- config final -->
```

### 3.3 EDGE
```routeros
<!-- config final -->
```

### 3.4 CORE-1
```routeros
<!-- config final -->
```

### 3.5 CORE-2
```routeros
<!-- config final -->
```

### 3.6 DIST-1
```routeros
<!-- config final -->
```

### 3.7 DIST-2
```routeros
<!-- config final -->
```

### 3.8 Hosts (PC-USER / SRV)
```bash
<!-- config final de los hosts -->
```

---

## 4. Verificación

### 4.1 Conectividad básica

| Prueba | Comando | Resultado |
|--------|---------|-----------|
| ping intra-LAN (PC-USER ↔ SRV) | <!-- --> | <!-- --> |
| traceroute a ISP (loopback) | <!-- --> | <!-- --> |

> Pegar capturas de las tablas: `/routing/route/print`, `/interface/vrrp/print`, `/routing/bgp/session/print`.

### 4.2 Los 5 drills de failover

> Para cada drill, documentar con la estructura **detección → respuesta → recuperación → post-mortem** y el **tiempo medido**.

#### Drill 1 — VRRP: se cae el gateway
- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem** (¿por qué funcionó? ¿qué aprendieron?): <!-- -->

#### Drill 2 — OSPF: se corta el camino interno
- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem:** <!-- -->

#### Drill 3 — BGP: se cae el proveedor
- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem:** <!-- -->

#### Drill 4 — check-gateway: failover estático de enlace
- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Tiempo medido:** <!-- -->
- **Post-mortem:** <!-- -->

#### Drill 5 — Load-sharing VRRP: ambos DIST activos
- **Detección:** <!-- -->
- **Respuesta:** <!-- -->
- **Recuperación:** <!-- -->
- **Post-mortem:** <!-- -->

---

## 5. Seguridad aplicada

| Mecanismo | Dónde se aplicó | Verificación (¿cómo probaron que funciona?) |
|-----------|-----------------|---------------------------------------------|
| Hardening (usuarios/servicios) | <!-- --> | <!-- --> |
| OSPF MD5 | <!-- --> | <!-- --> |
| BGP TCP-MD5 | <!-- --> | <!-- --> |
| VRRP auth | <!-- --> | <!-- --> |
| Firewall/ACL (edge) | <!-- --> | <!-- --> |

> Prueba de seguridad obligatoria: adyacencia OSPF / sesión BGP debe **fallar** con clave incorrecta. Documentar el resultado.

---

## 6. Gestión operativa

### 6.1 Change log

| Fecha | Responsable | Cambio | Motivo | Cómo se revierte |
|-------|-------------|--------|--------|------------------|
| <!-- --> | <!-- --> | <!-- --> | <!-- --> | <!-- --> |

### 6.2 Backups

> Evidencia de backup (`/export` + `/system backup save`) y de **restore probado**.

<!-- pegar evidencia -->

### 6.3 Monitoreo

> Qué se monitorea (enlaces, vecinos OSPF, sesiones BGP, VRRP) y con qué (SNMP, chequeos).

<!-- -->

---

## 7. Capturas

> Listar o enlazar la carpeta de capturas (drills, tablas, failover).

<!-- -->

---

## 8. Conclusiones y lecciones aprendidas

> Post-mortem global: qué salió bien, qué fue difícil, qué harían distinto.

<!-- -->

---

## 9. Referencias

> Lecturas y videos efectivamente consultados.

- <!-- -->
- <!-- -->

---

## 10. Checklist de entrega

> Marcar **todo** antes de entregar. Si algo no está, el lab no está completo.

### Diseño (F0)
- [ ] IPAM completo y sin solapamiento
- [ ] Corrección del diagrama justificada (≥ 3 defectos)
- [ ] Política de seguridad definida (usuarios, servicios, claves)
- [ ] Política de operación definida (change log + backup)

### Redes
- [ ] 7 CHR + 2 switches + 2 hosts levantados y cableados
- [ ] VRRP operativo (2 grupos, load-sharing)
- [ ] OSPF área 0 con adyacencias (incluido core–core)
- [ ] BGP eBGP ×2 establecido (multi-homing)
- [ ] Los 5 drills ejecutados y documentados (runbook + post-mortem + tiempo)

### Seguridad
- [ ] Hardening aplicado (password, usuario mínimo, servicios apagados)
- [ ] OSPF MD5 funcionando
- [ ] BGP TCP-MD5 funcionando
- [ ] VRRP auth funcionando
- [ ] Firewall edge aplicado
- [ ] Prueba con clave incorrecta → debe **fallar** (documentado)

### Operación
- [ ] Change log completo (refleja los commits del repo)
- [ ] Backups con restore probado
- [ ] Monitoreo habilitado y documentado
- [ ] Runbook por drill + post-mortem global

### Entrega
- [ ] Memoria completa (todas las secciones de esta plantilla)
- [ ] Repo git con la estructura correcta y commits por rol
- [ ] `backlog.md` con todas las tareas en "done"
- [ ] Capturas en la carpeta `capturas/`
- [ ] Cada integrante puede defender su parte **y** una parte ajena
