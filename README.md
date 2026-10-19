# Laboratorio Grupal: Failover Routing

**Cátedra:** Gestión Operativa y Seguridad en Redes (GOYS)  
**Grupo:** 5  
**Plataforma de Simulación:** GNS3 · MikroTik CHR (RouterOS v7)  
**Repositorio Oficial:** [github.com/cambaccarini/goys-failover-grupo5](https://github.com/cambaccarini/goys-failover-grupo5)

---

## 1. Integrantes y Matriz de Roles


| Integrante | Rol | Email de Contacto / Git | Responsabilidad de Infraestructura | Responsabilidades Operativas Asumidas |
| :--- | :---: | :--- | :--- | :--- |
| **Camila Baccarini** | **R1** | `cambaccarini01@gmail.com` | **Líder / Edge-WAN:** Router EDGE (AS 65000), dual-homing eBGP con ISP-1 e ISP-2, redistribución y filtrado OSPF↔BGP, BGP TCP-MD5, Firewall perimetral y NAT. | Gobernanza del repositorio Git, consolidación del Change Log general del proyecto y elaboración del Runbook para Drill 3 (BGP Failover ante caída de ISP). |
| **Alesandro Patricio Borda** | **R2** | `PATOEDA@HOTMAIL.COM` | **Proveedores (ISP):** Routers ISP-1 (AS 65001) e ISP-2 (AS 65002), inyección de rutas por defecto (`default-originate`), peering eBGP hacia EDGE, simulación de Loopbacks públicas. | Política integral y ejecución de Backups (`/export` scripts `.rsc` y backups binarios `.backup`), pruebas de restauración ante desastres y Runbook para Drill 4 (`check-gateway` / Failover estático). |
| **Ian Vidmar** | **R3** | `ividmar@alu.frlp.utn.edu.ar` | **Core / Backbone:** Routers CORE-1 y CORE-2, OSPF v2 Área 0 backbone en modo tránsito puro, enlace dedicado `core-core`, autenticación criptográfica OSPF MD5. | Aseguramiento de Calidad (QA) y auditoría técnica de configuraciones, monitoreo y telemetría de red (SNMP / logs de adyacencias OSPF/BGP) y Runbook para Drill 2 (Corte de enlace interno OSPF). |
| **Juan Ignacio Atencio Barrenechea** | **R4** | `juanignacioatenciobarrenechea@alu.frlp.utn.edu.ar` | **Distribución & FHRP:** Routers DIST-1 y DIST-2, redundancia de primer salto VRRP activo/activo (*load-sharing* entre VLAN 10 y VLAN 20), autenticación VRRP simple y enlaces OSPF uplink. | Despliegue, configuración y pruebas en equipos terminales (PC-USER en VLAN 10 y SRV en VLAN 20), verificación de conectividad L3 de primer salto y Runbooks para Drill 1 (Caída de Master VRRP) y Drill 5 (Load-sharing VRRP). |

---

## 2. Resumen Ejecutivo del Proyecto

El presente laboratorio aborda el diseño, aprovisionamiento, hardening, operación y verificación empírica de una infraestructura de red empresarial jerárquica de **5 capas**, con el objetivo de mejorar la resiliencia ante contingencias físicas o lógicas. La alta disponibilidad y la conmutación por falla se verificarán progresivamente mediante las fases de implementación y sus evidencias.

### Pilares Arquitectónicos y Protocolos:
1. **Redundancia de Primer Salto (FHRP - Layer 1 de Failover):**
   - Implementación de **VRRP v2/v3** en la capa de Distribución con balanceo de carga simétrico (*Active/Active Load-Sharing*):
     - `DIST-1`: Master de VLAN 10 (Usuarios - `192.168.10.1`, VRID 10, Prioridad 150) y Backup de VLAN 20 (Prioridad 100).
     - `DIST-2`: Master de VLAN 20 (Servidores - `192.168.20.1`, VRID 20, Prioridad 150) y Backup de VLAN 10 (Prioridad 100).
   - Autenticación mediante clave compartida en las tramas multicast de control VRRP.
2. **Enrutamiento Dinámico Interior (IGP - Layer 2 de Failover):**
   - **OSPF v2 Área 0 (Backbone)** desplegado sobre la malla de tránsito: EDGE, CORE-1, CORE-2, DIST-1 y DIST-2.
   - Enlace físico dedicado **Core-Core** (`10.20.1.0/30`) para convergencia acelerada, mitigación de asimetrías de ruteo (*trombone routing*) y estabilidad de inundación de LSAs Tipo 1.
   - El Core se mantiene como **Pure Transit**: desacoplado de SVIs de usuario o tablas ARP de acceso.
   - Autenticación criptográfica obligatoria con **MD5** en todas las adyacencias OSPF.
3. **Enrutamiento Exterior e Interconexión WAN (EGP - Layer 3 de Failover):**
   - **eBGP Multi-homing** desde el router EDGE hacia dos Sistemas Autónomos independientes:
     - ISP-1: ASN 65001.
     - ISP-2: ASN 65002.
   - AS Privado de la empresa: **ASN 65000**.
   - Protección de la sesión de control BGP mediante **TCP-MD5** (RFC 2385) para prevenir inyección de paquetes RST o falsificación de rutas.
   - Los proveedores inyectan ruta por defecto dinámica mediante BGP `default-originate`.
4. **Seguridad Perimetral y Hardening de Dispositivos:**
   - Desactivación sistemática de vectores de ataque por servicios inseguros (Telnet, HTTP, FTP, API, MAC-Server) y supresión de anuncios MNDP/CDP hacia enlaces no confiables.
   - Modelo de acceso RBAC con credenciales criptográficas y usuario auditor de solo lectura (`monitor`).
   - Firewall de Borde con inspección con estado (*Stateful Inspection*), aislamiento de planos de gestión y control, y NAT/Masquerade para salida hacia Internet.
5. **Operación DevOps y Verificación Empírica (Drills):**
   - Trazabilidad estricta de cambios bajo la convención **Conventional Commits**.
   - Procedimiento formal de salvaguarda y recuperación ante desastres mediante `/export` (scripts versionables) y backups binarios.
   - Batería de 5 simulaciones de falla destructivas (*Failover Drills*) cronometradas, con registro de telemetría y análisis *post-mortem*.

---

## 3. Asignación de Nodos y Router-IDs

Cada router MikroTik CHR tiene configurada una interfaz virtual Loopback (`lo`) con máscara `/32` que determina de manera estricta y predecible su identidad en los protocolos de control:

| Dispositivo | Capa Jerárquica | Rol del Nodo | Loopback / Router-ID | ASN BGP | Dominio IGP |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **ISP-1** | WAN / Internet | Proveedor Primario | `1.1.1.1/32` | 65001 | BGP External |
| **ISP-2** | WAN / Internet | Proveedor Secundario | `2.2.2.2/32` | 65002 | BGP External |
| **EDGE** | Borde Perimetral | Gateway Empresarial | `3.3.3.3/32` | 65000 | OSPF Área 0 / BGP Local |
| **CORE-1** | Núcleo (Core) | Tránsito Backbone A | `4.4.4.4/32` | N/A | OSPF Área 0 |
| **CORE-2** | Núcleo (Core) | Tránsito Backbone B | `5.5.5.5/32` | N/A | OSPF Área 0 |
| **DIST-1** | Distribución | Gateway VLAN 10 (Master) | `6.6.6.6/32` | N/A | OSPF Área 0 / VRID 10 |
| **DIST-2** | Distribución | Gateway VLAN 20 (Master) | `7.7.7.7/32` | N/A | OSPF Área 0 / VRID 20 |

---

## 4. Esquema Resumido de Enlaces e IPAM

```text
       [ISP-1 (AS 65001)]                 [ISP-2 (AS 65002)]
         10.100.1.1/30                       10.200.1.1/30
               │                                   │
               │ (ether1)                 (ether2) │
               └─────────────► [EDGE] ◄────────────┘
                              (AS 65000)
                     (ether3) │        │ (ether4)
                10.10.1.1/30  │        │ 10.10.2.1/30
                              ▼        ▼
                    [CORE-1] ──────────── [CORE-2]
           10.10.1.2/30 │   10.20.1.0/30   │ 10.10.2.2/30
                        │   (Core-Core)    │
            10.30.1.0/30│ 10.30.2.0/30     │10.30.3.0/30 10.30.4.0/30
                        │      │           │      │
                        ▼      └──────┐    ▼      │
                    [DIST-1] ◄────────┼─ [DIST-2] ◄┘
                 VRRP Master 10       │ VRRP Master 20
                 VRRP Backup 20       └─ VRRP Backup 10
                        │                   │
                  [SW-ACC-USERS]      [SW-ACC-SERVERS]
                  VLAN 10: .10.0/24   VLAN 20: .20.0/24
                     PC-USER                 SRV
                 192.168.10.100/24   192.168.20.100/24
```

---

## 5. Estructura Física del Repositorio

El árbol de directorios del repositorio está estandarizado y cuenta con persistencia de carpetas mediante archivos `.gitkeep`:

```text
goys-failover-grupo5/
├── README.md              # Documentación de equipo, arquitectura y guía rápida
├── backlog.md             # Seguimiento granular de tareas y criterios de aceptación (F0-F5)
├── docs/                  # Memoria técnica completa y diagramas de topología
│   ├── memoria.md         # Documento maestro de ingeniería, configs, drills y post-mortems
│   └── diagramas/         # Diagramas lógicos, capturas GNS3 y matrices de tráfico
│       └── .gitkeep
├── configs/               # Scripts exportados (.rsc) limpios para cada uno de los 7 routers
│   └── .gitkeep
├── backups/               # Respaldos de configuración (scripts /export y binarios .backup)
│   ├── .gitkeep
│   └── f1/exports/        # .rsc base de F1 (sin secretos)
├── runbooks/              # Procedimientos operativos estándar (SOP) para los 5 drills
│   └── .gitkeep
└── capturas/              # Evidencias en imagen de adyacencias, ping de drills y failover
    └── f1/                # topologia/ · conectividad/ · hardening/ · troubleshooting/
```

---

## 6. Política de Operación Git y Convención de Commits

Para asegurar una auditoría cristalina y cumplir con la política de gestión operativa, todos los integrantes del grupo realizan sus aportes mediante la especificación **Conventional Commits**:

### Formato de Mensajes de Commit:
```text
<tipo>(<alcance>): <descripción concisa y técnica en imperativo>
```
* **Tipos válidos:**
  * `feat`: Implementación de nueva configuración de red, protocolos o políticas.
  * `fix`: Corrección de direccionamiento, rutas, filtros o discrepancias de sintaxis.
  * `docs`: Modificación o ampliación de memoria técnica, backlog, diagramas o README.
  * `ops`: Operaciones de respaldo, scripts de mantenimiento o automatización.
  * `chore`: Creación de estructura de directorios, archivos `.gitkeep` o tareas administrativas.
* **Alcances comunes (`scope`):** `ipam`, `roles`, `backlog`, `memoria`, `vrrp`, `ospf`, `bgp`, `firewall`, `hardening`, `drills`, `backup`.

---

## 7. Cronograma Oficial de Hitos

| Fase / Hito | Alcance Principal | Fecha de Entrega | Estado |
| :--- | :--- | :---: | :---: |
| **F0** | Diseño arquitectónico, corrección de defectos, IPAM, seguridad y operación | Vie 02/10/2026 | **Aprobado con observaciones** |
| **F1** | Despliegue de topología física en GNS3, hardening base y backup inicial | Vie 09/10/2026 | **Completado** (exports versionados; evidencia de snapshot y hardening por verificar) |
| **F2** | Configuración de VRRP (load-sharing) y OSPF Área 0 con autenticación MD5 | Vie 16/10/2026 | En Curso |
| **F3** | eBGP Multi-homing, BGP TCP-MD5, redistribución de rutas y Firewall perimetral | Vie 16/10/2026 | Planificado |
| **F4** | Ejecución de los 5 Drills destructivos de failover, monitoreo y telemetría | Mar 20/10/2026 | Planificado |
| **F5** | Memoria técnica completa, cierre del backlog, repositorio final y defensa oral | Vie 23/10/2026 | Planificado |
