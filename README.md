# Laboratorio Grupal: Failover Routing 

**Materia:** Gestión Operativa y Seguridad en Redes 

**Grupo:** 5

**Simulador:** GNS3 · MikroTik CHR (RouterOS 7)

---

## Integrantes y Roles

| Integrante | Rol | Responsabilidad principal |
| --- | --- | --- |
| Camila Baccarini | R1 — Líder / Edge-WAN | EDGE: eBGP ×2, redistribución, BGP MD5, firewall |
| Patricio Borda | R2 — Proveedores (ISP) | ISP-1/ISP-2: default-originate, eBGP, hardening |
| Ian Vidmar | R3 — Core | CORE-1/CORE-2: OSPF, core–core, OSPF MD5 |
| Juan Atencio | R4 — Distribución | DIST-1/DIST-2: VRRP (auth), OSPF, gateways |
| Integrante 5 | R5 — Hosts / QA / Operación | Hosts, ejecuta los drills, backlog, change log, backups y runbooks |

---

## Resumen del Laboratorio

Este proyecto consiste en el diseño, implementación, operación y aseguramiento de una infraestructura de red empresarial jerárquica de 5 capas resiliente a fallas físicas y de enlace.

### Objetivos Clave

* **Redundancia de Primer Salto (FHRP):** Implementación de VRRP en la capa de Distribución con balanceo de carga (*load-sharing*) entre routers.


* **Enrutamiento Interior (IGP):** Configuración de OSPF Área 0 en tránsito puro con enlace dedicado `core-core` y autenticación MD5.


* **Enrutamiento Exterior (EGP):** Implementación de eBGP Multi-homing con dos proveedores independientes (ISP-1 e ISP-2) y protección mediante TCP-MD5.


* **Seguridad y Hardening:** Aplicación de políticas de acceso restrictivo, eliminación de servicios inseguros y reglas de firewall en el borde.


* **Gestión Operativa:** Control de cambios estricto vía Git (Conventional Commits), respaldos periódicos y pruebas de caída (*drills* de failover).


---

## Estructura del Repositorio


```text
goys-failover-grupo5/
├── README.md          # Descripción general del grupo, integrantes y roles
├── backlog.md         # Seguimiento de tareas y estados del proyecto (F0-F5)
├── docs/              # Documentación técnica y memoria del laboratorio
│   ├── memoria.md
│   └── diagramas/
├── configs/           # Scripts de configuración (.rsc) finales por router
├── backups/           # Respaldos de configuración (/export y binarios)
├── runbooks/          # Guías paso a paso para la ejecución de los 5 drills
└── capturas/          # Evidencias fotográficas y comprobaciones de failover

```

---
