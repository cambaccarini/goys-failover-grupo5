# Backlog — Laboratorio Failover Routing

**Grupo:** 5 · **Vencimiento final:** vie 23/10/2026

## Leyenda de estado

- `[ ]` Pendiente · `[~]` En curso · `[x]` Hecho
- Cada tarea tiene asignado su **dueño unívoco** (rol técnico): `[R1]`, `[R2]`, `[R3]` o `[R4]`.
- Cada tarea define su **criterio de aceptación técnico** (comando CLI, bandera o resultado esperado).

- **Responsable operativo R5:** Alesandro Patricio Borda (R2), como responsabilidad adicional. Coordina backups/restores, Change Log, evidencias de drills y post-mortems; los responsables técnicos conservan la ejecución de sus módulos.

> **Replanificación propuesta al docente (pendiente de aprobación):**
> - F2: miércoles 21/10/2026.
> - F3: jueves 22/10/2026.
> - F4: lunes 26/10/2026.
> - F5: martes 27/10/2026.
>
> Las fechas son objetivos solicitados y no se consideran aprobados hasta recibir confirmación del docente. No marcar fases como completadas sin cumplir sus criterios de aceptación.

---

## Epic F0 — Diseño y Gestión de Cambio · _vence vie 02/10_ · [x]

### IPAM / Direccionamiento

- [x] [R1] Diseñar esquema IPAM para enlaces WAN (10.100.1.0/30 e 10.200.1.0/30) y asignación de Router-IDs/Loopbacks /32 de EDGE (3.3.3.3) y Proveedores ISP-1 (1.1.1.1) e ISP-2 (2.2.2.2). Criterio: direccionamiento jerárquico justificado y documentado en tabla IPAM sin solapamiento.
- [x] [R3] Diseñar direccionamiento /30 para enlaces de tránsito interno: backbone Core-Core (10.20.1.0/30), Edge-Core (10.10.1.0/30, 10.10.2.0/30) y Core-Distribución (10.30.1.0/30 a 10.30.4.0/30), con Loopbacks de CORE-1 (4.4.4.4) y CORE-2 (5.5.5.5). Criterio: matriz completa de interfaces físicas y cálculo de subredes punto a punto.
- [x] [R4] Diseñar subredes /24 para VLAN 10 (Usuarios: 192.168.10.0/24) y VLAN 20 (Servidores: 192.168.20.0/24), definiendo IPs virtuales VRRP (192.168.10.1 y 192.168.20.1) y Loopbacks de DIST-1 (6.6.6.6) y DIST-2 (7.7.7.7). Criterio: esquema VRRP con prioridades 150/100 y sin solapamiento.

### Corrección del Diagrama Original (4 Defectos Fundamentados)

- [x] [R1] Analizar y documentar la corrección del SPOF en el Borde perimetral mediante dual-homing eBGP con ISP-1 e ISP-2 y enlaces duales hacia Core. Criterio: justificación técnica de alta disponibilidad en memoria.md.
- [x] [R3] Analizar y documentar el defecto de ausencia de enlace Core-Core, fundamentando la adición del enlace físico dedicado 10.20.1.0/30 para OSPF Área 0. Criterio: justificación sobre prevención de trombone routing y aceleración de flooding de LSAs Tipo 1.
- [x] [R4] Analizar y documentar el defecto de mala ubicación de FHRP en el Core, justificando el traslado de VRRP a la capa de Distribución para preservar al Core como tránsito puro. Criterio: diseño activo/activo de primer salto documentado.
- [x] [R2] Analizar y documentar la corrección del solapamiento y dispersión de subredes del diagrama original mediante particionamiento jerárquico determinista. Criterio: justificación de estructura de bloques en memoria.md.

### Política de Seguridad

- [x] [R1] Definir matriz de hardening perimetral, servicios inseguros a deshabilitar (Telnet, HTTP, FTP, API, MAC-Server) y esquema RBAC (usuario admin local y usuario monitor de solo lectura). Criterio: lista de servicios a apagar y política de credenciales seguras.
- [x] [R3] Definir política de autenticación criptográfica en protocolos de enrutamiento: OSPF v2 con MD5 en interfaces de tránsito y BGP con TCP-MD5. Criterio: parámetros de cifrado y política de claves robustas en memoria.md.
- [x] [R4] Definir autenticación para grupos VRRP 10 y 20 mediante clave compartida (simple authentication). Criterio: especificación de cadena de autenticación VRRP.

### Política de Operación y Repositorio

- [x] [R1] Definir convención de Conventional Commits para el repositorio y formato estándar del Change Log. Criterio: estructura de commits y tabla de control de cambios aprobada.
- [x] [R2] Establecer política integral de respaldos (frecuencia, comando `/export` y `/system backup save`, validación de restore). Criterio: procedimiento de backup documentado en memoria.
- [x] [R2] Crear estructura física de directorios (`configs/`, `backups/`, `capturas/`, `runbooks/`, `docs/diagramas/`) con archivos `.gitkeep`. Criterio: carpetas versionadas y visibles en Git.
- [x] [R4] Documentar especificación de hosts de prueba (PC-USER y SRV) y criterios de validación de primer salto. Criterio: parámetros de red de hosts en IPAM.

---

## Epic F1 — Topología + Hardening + Backup Inicial · _vence vie 09/10/2026_ · [x]

### Despliegue de Topología (7 CHR + 2 Switches + 2 Hosts)

- [x] [R1] Desplegar y cablear EDGE: ether1 hacia ISP-1, ether2 hacia ISP-2, ether3 hacia CORE-1 y ether4 hacia CORE-2. Criterio: enlaces conectados y conectividad IP directa verificada.
- [x] [R2] Desplegar y cablear ISP-1 e ISP-2, conectando ether1 de cada router hacia su interfaz correspondiente en EDGE. Criterio: enlaces conectados y pings a los vecinos directos exitosos.
- [x] [R3] Desplegar y cablear CORE-1 y CORE-2, conectando ether1 hacia EDGE, ether2 entre los CORE y ether3/ether4 hacia los DIST. Criterio: los cinco enlaces correspondientes a los CORE están conectados y las pruebas de conectividad directa resultan exitosas.
- [x] [R4] Desplegar y cablear DIST-1 y DIST-2 hacia ambos CORE y ambos switches de acceso; conectar PC-USER y SRV. DIST-1 utiliza ether3 hacia SW-ACC-USERS y ether4 hacia SW-ACC-SERVERS; DIST-2 utiliza ether4 hacia SW-ACC-USERS y ether3 hacia SW-ACC-SERVERS. Criterio: topología de 11 nodos y 15 enlaces internos conectados.
- [x] [R4] Guardar la captura completa de la topología en `capturas/f1/topologia/topologia-completa.png`. Criterio: PNG legible que muestra los 11 nodos y los 15 enlaces internos, incorporado al repositorio.

### Configuración de Direccionamiento IP y Loopbacks

- [x] [R1] Configurar en EDGE la loopback `lo` (3.3.3.3/32) y las cuatro direcciones de tránsito /30 hacia ISP-1, ISP-2, CORE-1 y CORE-2. Criterio: `/ip address print` coincide con el IPAM aprobado.
- [x] [R2] Configurar en ISP-1 e ISP-2 las loopbacks (1.1.1.1/32 y 2.2.2.2/32) y las IP WAN 10.100.1.1/30 y 10.200.1.1/30. Criterio: direcciones verificadas y pings a EDGE exitosos.
- [x] [R3] Configurar en CORE-1 y CORE-2 las loopbacks y las IP de los enlaces /30 de tránsito. Criterio: direcciones coincidentes con el IPAM y conectividad IP con los vecinos directos.
- [x] [R4] Configurar en DIST-1 y DIST-2 las loopbacks, enlaces /30 hacia CORE y las interfaces VLAN 10 y VLAN 20, con sus IP individuales y asociaciones físicas. Criterio: direcciones coincidentes con el IPAM y pings de las VLAN entre ambos DIST exitosos.

### Verificación L3 y Documentación de F1

- [x] [R4] Completar en `docs/memoria.md` el inventario por router de interfaces, direcciones IP, vecinos físicos, usos y loopbacks/Router-ID previstos. Criterio: la tabla coincide con las configuraciones verificadas y distingue los parámetros configurados de los previstos para F2/F3.
- [x] [R1] [R2] [R3] [R4] Verificar conectividad IP entre los vecinos directos de todos los enlaces entre routers. Criterio: pings exitosos y fallas registradas si corresponde.
- [x] [R4] Consolidar las evidencias en `capturas/f1/conectividad/` y documentar los resultados en `docs/memoria.md`. Criterio: capturas por router de `/ip address print` y de todos los pings correspondientes, copiadas al repositorio y vinculadas desde la memoria.

### Hardening de Dispositivos (7 Routers)

> Evidencia en `capturas/f1/hardening/` (ver sección 2.3 de `docs/memoria.md`). Los desvíos respecto de la política se documentan allí.

- [x] [R1] Aplicar la política de hardening en EDGE: deshabilitar telnet, ftp, www, api y api-ssl; crear usuario administrativo con contraseña segura y usuario `monitor` con permisos de solo lectura. Criterio: `/ip service print` muestra únicamente los servicios autorizados activos.
- [x] [R2] Aplicar la política de hardening en ISP-1 e ISP-2: desactivar servicios no cifrados, excluir interfaces WAN del descubrimiento MNDP/CDP y configurar usuarios locales. Criterio: `/ip neighbor discovery-settings print` muestra las interfaces WAN excluidas y los servicios coinciden con la política.
- [x] [R3] Aplicar la política de hardening en CORE-1 y CORE-2: deshabilitar servicios innecesarios y aplicar banners legales de acceso. Criterio: SSH funciona con el usuario `monitor`, que no puede realizar cambios de configuración.
- [x] [R4] Aplicar la política de hardening en DIST-1 y DIST-2: deshabilitar servicios no seguros y restringir el acceso por SSH/WinBox. Criterio: los servicios no autorizados están deshabilitados y los intentos HTTP/Telnet son rechazados.
- [X] [R3] Auditar la evidencia de hardening de los 7 routers y registrar resultados y desvíos en `docs/memoria.md`. Criterio: usuarios, permisos y servicios se verifican contra la política de seguridad de F0; las evidencias quedan organizadas en `capturas/f1/hardening/`.

### Snapshot BASE

- [x] [R3] Generar en GNS3 un snapshot completo del proyecto denominado `SNAPSHOT-BASE-F1`, con la topología desplegada en el estado inicial acordado. Criterio: el snapshot es accesible y puede restaurarse.
- [x] [R4] Documentar en `docs/memoria.md` la fecha, el nombre y el estado incluido en el snapshot; guardar evidencia en `capturas/f1/topologia/` si corresponde. Criterio: otra persona puede identificar qué estado del proyecto representa el snapshot.

### Backup Inicial

- [x] [R2] Exportar una configuración base de cada router mediante `/export`, sin incluir valores sensibles, y guardar los 7 archivos `.rsc` en `backups/f1/exports/`. Criterio: hay un archivo identificado por router, revisado para confirmar que no contiene contraseñas, claves ni otros secretos antes de versionarlo.
- [x] [R2] Generar los backups binarios de los 7 routers mediante `/system backup save` y almacenarlos en un medio restringido, fuera de los archivos versionados del repositorio. Criterio: los 7 backups están identificados y disponibles para restauración; no se suben al repositorio.
- [x] [R2] Realizar una prueba de restauración en un nodo de test para validar la integridad del backup. Criterio: el router de prueba restaura la configuración esperada y vuelve a operar.

---
> **Cierre F1:** la topología, el direccionamiento, los exports `.rsc` saneados y el snapshot `SNAPSHOT-BASE-F1` están documentados; el snapshot fue restaurado y la conectividad ISP-1 ↔ EDGE quedó verificada. Las catorce capturas de hardening y auditoría fueron incorporadas. El responsable R2 ejecutó satisfactoriamente la prueba de restauración de un backup binario (`.backup`) en un nodo MikroTik CHR aislado de test y confirmó el resguardo offline privado de los 7 respaldos binarios. Epic F1 cerrado al 100%.
---

## Epic F2 — VRRP + OSPF · _objetivo propuesto: mié 21/10/2026_ · [~]

> **Avance F2 al 25/10/2026 — Paso 1 (OSPF), Paso 2 (VRRP) y Paso 3 (Verificación L3):**
> 1. **OSPF Área 0 con MD5:** instancia `ospf1`, área `backbone` (0.0.0.0) e interface-templates aplicados en EDGE, CORE-1, CORE-2, DIST-1 y DIST-2 (router-id 3.3.3.3 a 7.7.7.7). Adyacencias en `Full` verificadas con `/routing ospf neighbor print`: EDGE 2/2, CORE-1 4/4, DIST-1 2/2 y DIST-2 2/2; CORE-2 verificado por adyacencias de vecinos. Evidencia en `capturas/f2/ospf/`.
> 2. **VRRP Load-Sharing Activo/Activo con Auth:** VRID 10 (USERS) configurado en `vlan10` (DIST-1 Master `RM` prioridad 150, DIST-2 Backup `B` prioridad 100, IP virtual `192.168.10.1`). VRID 20 (SERVERS) configurado en `vlan20` (DIST-2 Master `RM` prioridad 150, DIST-1 Backup `B` prioridad 100, IP virtual `192.168.20.1`). Autenticación `simple`, `version=2`, `interval=1s` y `preempt-mode=yes` validados. Evidencias en `capturas/f2/vrrp/`.
> 3. **Verificación L3 y Conectividad End-to-End (R5):** Hosts terminales configurados con direccionamiento estático y gateways virtuales. Pings 100% exitosos hacia las VIPs y pings bidireccionales intra-LAN entre PC-USER y SRV cruzando el Core (0% de pérdida, TTL 63). Resolución ARP de MACs virtuales VRRP confirmadas (`00:00:5E:00:01:0A` y `00:00:5E:00:01:14`). Load-sharing verificado fehacientemente por traceroute: PC-USER sale por DIST-1 (`192.168.10.2`) y SRV sale por DIST-2 (`192.168.20.3`). Evidencias en `capturas/f2/conectividad/`.
> **Pendiente de F2:** ECMP (Paso 4) y backups de configuración F2.

### VRRP (2 Grupos, Load-Sharing Activo/Activo, Auth)

- [x] [R4] Configurar grupo VRRP vrid=10 (USERS) sobre vlan10 en DIST-1 como Master (priority=150) y DIST-2 como Backup (priority=100) con IP virtual 192.168.10.1 y autenticación por clave simple. Criterio: `/interface vrrp print` muestra flag 'RM' en DIST-1 y 'B' en DIST-2.
- [x] [R4] Configurar grupo VRRP vrid=20 (SERVERS) sobre vlan20 en DIST-2 como Master (priority=150) y DIST-1 como Backup (priority=100) con IP virtual 192.168.20.1 y autenticación por clave simple. Criterio: `/interface vrrp print` muestra flag 'RM' en DIST-2 y 'B' en DIST-1.
- [x] [R4] Configurar parámetros de preemption (`preempt-mode=yes`) e intervalo de anuncio (`interval=1s`) en ambos routers. Criterio: timers alineados y sincronizados.

### OSPF v2 Área 0 (Backbone con Autenticación MD5)

- [x] [R3] Configurar instancia OSPF v2 en CORE-1 y CORE-2 con router-id 4.4.4.4 y 5.5.5.5 en Área 0 (0.0.0.0), habilitando interface-template con autenticación MD5 en enlace core-core (10.20.1.0/30). Criterio: `/routing ospf neighbor print` muestra adyacencia 'Full' entre ambos cores.
- [~] [R3] Configurar adyacencias OSPF MD5 en enlaces CORE hacia DIST-1 y DIST-2 con costo balanceado. Criterio: tabla de rutas `/ip route print` muestra rutas de distribución con flag 'Do' (Dynamic OSPF). _Hecho: adyacencias CORE-1 y CORE-2 con DIST-1 y DIST-2 en `Full`. Pendiente: costo OSPF explícito y `/ip route print where ospf` en CORE-1 y CORE-2._
- [x] [R1] Configurar instancia OSPF en EDGE (router-id 3.3.3.3) en Área 0 con plantillas MD5 hacia CORE-1 y CORE-2. Criterio: adyacencias OSPF con CORE-1 y CORE-2 en estado 'Full'.
- [~] [R4] Configurar OSPF en DIST-1 y DIST-2 publicando las redes de usuarios (192.168.10.0/24) y servidores (192.168.20.0/24) como interfaces pasivas (`passive=yes`) para evitar LSA flooding no deseado hacia el acceso. Criterio: redes LAN visibles en CORE y EDGE sin tráfico multicast OSPF en switches de acceso. _Hecho: `vlan10`, `vlan20` y `lo` en OSPF como `passive` en DIST-1 y DIST-2. Pendiente: confirmar 192.168.10.0/24 y 192.168.20.0/24 en la tabla de rutas de CORE y EDGE._

### Verificación L3 y Conectividad End-to-End

- [x] [R4/R5] Configurar direccionamiento estático en PC-USER (192.168.10.100/24 GW 192.168.10.1) y SRV (192.168.20.100/24 GW 192.168.20.1). Criterio: ping exitoso de cada host a su respectiva IP virtual VRRP.
- [x] [R4/R5] Realizar ping bidireccional intra-LAN entre PC-USER y SRV. Criterio: 0% de pérdida de paquetes a través del enrutamiento inter-VLAN de distribución.
- [ ] [R3] Verificar ECMP (Equal-Cost Multi-Path) o convergencia simétrica desde DIST hacia EDGE a través de ambos cores. Criterio: `/ip route print detail` muestra dos gateways activos en rutas transitivas.

---

## Epic F3 — BGP + Firewall · _objetivo propuesto: jue 22/10/2026_ · [ ]
### eBGP Multi-Homing (2 Sesiones Independientes, TCP-MD5)

- [ ] [R2] Configurar en ISP-1 (AS 65001) sesión eBGP hacia EDGE (10.100.1.2) con protección TCP-MD5 y originación de ruta por defecto (`default-originate=always`). Criterio: `/routing bgp session print` muestra sesión 'established'.
- [ ] [R2] Configurar en ISP-2 (AS 65002) sesión eBGP hacia EDGE (10.200.1.2) con protección TCP-MD5 y originación de ruta por defecto (`default-originate=always`). Criterio: `/routing bgp session print` muestra sesión 'established'.
- [ ] [R1] Configurar en EDGE (AS 65000) sesiones eBGP hacia ISP-1 e ISP-2 configurando router-id 3.3.3.3 y claves TCP-MD5 idénticas a los proveedores. Criterio: EDGE recibe dos rutas por defecto 0.0.0.0/0 vía eBGP.

### Redistribución OSPF↔BGP y Propagación

- [ ] [R1] Configurar inyección de ruta por defecto desde EDGE hacia el dominio OSPF Área 0 (`originate-default=if-installed` o redistribución controlada). Criterio: CORE-1, CORE-2, DIST-1 y DIST-2 reciben ruta 0.0.0.0/0 con flag 'Do'.
- [ ] [R1] Publicar los prefijos LAN corporativos (192.168.10.0/24 y 192.168.20.0/24) hacia ISP-1 e ISP-2 mediante BGP network advertisements. Criterio: ISP-1 e ISP-2 tienen rutas hacia las LANs internas en sus tablas de ruteo.

### Firewall Perimetral y Salida a Internet

- [ ] [R1] Configurar reglas de NAT (`srcnat` / `masquerade`) en EDGE para interfaces ether1 y ether2 para todo el tráfico saliente originado en 192.168.0.0/16. Criterio: paquetes hacia Internet salen con la IP WAN pública de EDGE.
- [ ] [R1] Configurar Firewall Filter en EDGE en cadena input: drop de tráfico inválido, accept de conexiones established/related, accept ICMP rate-limited, y drop de accesos administrativos no autorizados. Criterio: escaneo nmap perimetral no muestra puertos abiertos expuestos.
- [ ] [R1] Configurar Firewall Filter en EDGE en cadena forward: permitir tráfico saliente de LANs hacia WAN, permitir retornos established/related, y denegar accesos no solicitados desde WAN hacia LAN. Criterio: aislamiento perimetral estricto.
- [ ] [R4] Ejecutar ping y traceroute desde PC-USER (192.168.10.100) y SRV (192.168.20.100) hacia las Loopbacks de ISP-1 (1.1.1.1) e ISP-2 (2.2.2.2). Criterio: 100% de respuestas con RTT < 20ms atravesando el camino completo.

---

## Epic F4 — Drills + Monitoreo · _objetivo propuesto: lun 26/10/2026_ · [ ]
### Los 5 Drills de Failover (Runbook + Medición + Post-Mortem)

- [ ] [R4] Ejecutar Drill 1 (VRRP: caída de gateway Master DIST-1): deshabilitar vlan10 en DIST-1 durante ping continuo desde PC-USER. Medir tiempo de conmutación a DIST-2 y registrar post-mortem en `runbooks/drill-1.md`. Criterio: recuperación en < 3s y pérdida <= 2 paquetes ICMP.
- [ ] [R3] Ejecutar Drill 2 (OSPF: corte de enlace de tránsito interno): deshabilitar enlace EDGE-CORE-1 (10.10.1.0/30) o Core-Core durante tráfico sostenido. Medir tiempo de reconvergencia OSPF y registrar post-mortem en `runbooks/drill-2.md`. Criterio: reconvergencia automática en < 5s sin caída de conectividad de los hosts.
- [ ] [R1] Ejecutar Drill 3 (BGP: caída de proveedor primario ISP-1): cortar ether1 de EDGE hacia ISP-1 durante streaming o ping continuo a 1.1.1.1 / 2.2.2.2. Medir failover hacia ISP-2 y registrar post-mortem en `runbooks/drill-3.md`. Criterio: tráfico redirigido por ISP-2 sin intervención manual.
- [ ] [R2] Ejecutar Drill 4 (check-gateway: failover estático de enlace): configurar ruta estática con `check-gateway=ping` y forzar inalcanzabilidad. Registrar detección de caída y conmutación en `runbooks/drill-4.md`. Criterio: ruta inactiva en 30s (3 pings fallidos de 10s) y activación de ruta alternativa.
- [ ] [R4] Ejecutar Drill 5 (Load-sharing VRRP: ambos DIST activos): generar tráfico concurrente desde PC-USER (VLAN 10) y SRV (VLAN 20) verificando mediante torch/capturas que el tráfico de usuarios sale por DIST-1 y el de servidores por DIST-2. Documentar en `runbooks/drill-5.md`. Criterio: distribución equitativa de ancho de banda y esquema activo/activo confirmado.

### Verificación de Seguridad Negativa y Resiliencia

- [ ] [R3] Ejecutar prueba de seguridad negativa OSPF: alterar clave MD5 en CORE-1. Registrar caída de adyacencia a estado ExStart/Down y log de autenticación errónea. Criterio: adyacencia no se establece y se registran alertas en log.
- [ ] [R1] Ejecutar prueba de seguridad negativa BGP: alterar clave TCP-MD5 en peering EDGE ↔ ISP-1. Verificar que la sesión BGP no establece (estado Connect/Active). Criterio: evidencia gráfica guardada en `capturas/`.

### Monitoreo y Observabilidad

- [ ] [R3] Configurar servicio SNMP v2c (`/snmp set enabled=yes`) y comunidad de lectura en los 7 routers. Criterio: consulta snmpwalk exitosa sobre árbol MIB-II de interfaces.
- [ ] [R3] Configurar reglas de logging local para eventos de cambio de estado en interfaces, adyacencias OSPF y sesiones BGP. Criterio: registros de conmutación documentados en memoria.

---

## Epic F5 — Memoria + Defensa · _objetivo propuesto: mar 27/10/2026_ · [ ]
### Consolidación Documental y Repositorio Final

- [ ] [R1] Consolidar y auditar la versión final de `docs/memoria.md`, asegurando que todas las secciones, diagramas y referencias técnicas estén completas y sin ningún placeholder. Criterio: memoria técnica 100% aprobada por el equipo.
- [ ] [R2] Exportar los scripts de configuración definitivos de los 7 routers a la carpeta `configs/` (`<router>.rsc`) verificando que no existan inconsistencias de sintaxis. Criterio: 7 scripts `.rsc` utilizables para reprovisionamiento desde cero.
- [ ] [R3] Organizar y documentar las evidencias gráficas en la carpeta `capturas/` (tablas de rutas, VRRP, OSPF, BGP y capturas de Wireshark). Criterio: evidencias enlazadas correctamente en memoria.md.
- [ ] [R4] Verificar el cierre total del backlog (todas las tareas en estado `[x]`) y corroborar que el Change Log de la memoria refleje con exactitud la secuencia de commits de Git. Criterio: auditoría cruzada `git log` vs Change Log sin discrepancias.

### Preparación para la Defensa Oral

- [ ] [R1] Liderar sesión grupal de simulación de defensa: defender módulo de Borde, BGP multi-homing y firewall, y responder preguntas cruzadas sobre VRRP en distribución. Criterio: dominio integral de la solución.
- [ ] [R2] Defender arquitectura de proveedores ISP, políticas de backup, restauración y failover estático, y responder preguntas cruzadas sobre OSPF Core-Core. Criterio: solvencia técnica individual.
- [ ] [R3] Defender diseño de Core, OSPF Área 0, tránsito puro y autenticación MD5, y responder preguntas cruzadas sobre BGP TCP-MD5. Criterio: justificación fluida de las decisiones de diseño.
- [ ] [R4] Defender esquema VRRP activo/activo en distribución, gateways virtuales y segmentación de hosts, y responder preguntas cruzadas sobre políticas perimetrales de EDGE. Criterio: demostración práctica en vivo de los drills de failover.
