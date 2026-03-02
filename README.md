# Sistema de Gestión Inmobiliaria en MySQL

![Diagrama entidad-relación](proyecto%20MYSQL2.png)

## 1. Descripción general

Este proyecto implementa una base de datos relacional en MySQL para la gestión de una inmobiliaria.  
El sistema cubre:

- Administración del portafolio de propiedades (casas, apartamentos, locales).
- Gestión de clientes y agentes inmobiliarios.
- Registro de contratos de arriendo y venta.
- Historial de pagos asociados a los contratos.
- Auditoría de cambios y manejo básico de errores.
- Seguridad a nivel de usuarios y roles de base de datos.
- Optimización de consultas mediante índices, vista y evento programado mensual.

Toda la estructura está normalizada hasta 3FN, separando claramente catálogos, entidades de negocio y tablas de auditoría.

---

## 2. Estructura de la base de datos (MER)

### 2.1. Catálogos y tablas globales

**Objetivo:** centralizar valores repetidos (tipos, estados, localización) para evitar duplicidad y facilitar mantenimiento.

Tablas:

- `ciudades`: ciudades donde existen propiedades.  
  - Atributos: `id_ciudad`, `nombre`, `departamento`.
- `barrios`: subdivisión de una ciudad.  
  - FK: `ciudad_id → ciudades.id_ciudad`.
- `tipos_propiedad`: tipo de inmueble.  
  - Ejemplos: Casa, Apartamento, Local.
- `estados_propiedad`: estado actual de una propiedad.  
  - Ejemplos: Disponible, Arrendada, Vendida.
- `tipos_contrato`: clase de contrato.  
  - Ejemplos: Arriendo, Venta.
- `estados_contrato`: estado del ciclo de vida del contrato.  
  - Ejemplos: Vigente, Finalizado, Rescindido.
- `metodos_pago`: formas de pago aceptadas.  
  - Ejemplos: Efectivo, Transferencia.
- `roles`: roles de aplicación para usuarios del sistema.  
  - Ejemplos: Administrador, Agente, Contador.

**Lógica de diseño:**  
En vez de usar `ENUM`, se definen tablas de catálogo. Esto permite agregar nuevos tipos/estados sin alterar el esquema, mantiene la consistencia referencial y apoya la normalización a 3FN.

---

### 2.2. Personas y actores del negocio

**Objetivo:** modelar personas de manera genérica y especializarlas como clientes, agentes y usuarios del sistema.

Tablas:

- `personas`  
  - Datos básicos: nombre, apellidos, tipo y número de documento, contacto y dirección.
- `clientes`  
  - PK y FK: `id_cliente → personas.id_persona`.  
  - Atributo: `fecha_registro`.
- `agentes_inmobiliarios`  
  - PK y FK: `id_agente → personas.id_persona`.  
  - Atributo: `codigo` único del agente.
- `usuarios_sistema`  
  - Usuario lógico de la aplicación.  
  - FK: `persona_id → personas.id_persona`, `id_rol → roles.id_rol`.  
  - Atributos: `username`, `password_hash`.

**Lógica de diseño:**  
Se usa una tabla genérica `personas` y tablas derivadas (`clientes`, `agentes_inmobiliarios`) que referencian la PK de `personas`. Así se evita duplicar datos personales y se mantiene un único registro por persona. `usuarios_sistema` separa la identidad de negocio (persona) de las credenciales de aplicación.

---

### 2.3. Propiedades, contratos y pagos

**Objetivo:** registrar el inventario de propiedades y los contratos asociados (arriendo/venta) con su historial de pagos.

Tablas:

- `propiedades`  
  - FKs: `ciudad_id`, `barrio_id`, `id_tipo_propiedad`, `id_estado_propiedad`.  
  - Atributos físicos: dirección, área, habitaciones, baños, parqueadero, valor de referencia.
- `contratos`  
  - FKs: `propiedad_id`, `cliente_id`, `agente_id`, `id_tipo_contrato`, `id_estado_contrato`.  
  - Atributos: fechas de inicio/fin, valor, porcentaje de comisión.
- `contrato_detalle`  
  - FK: `contrato_id → contratos.id_contrato`.  
  - Copia (snapshot) de información relevante de la propiedad y el contrato al momento de la firma: dirección, ciudad, barrio, departamento, tipo de propiedad, área, características y valor del contrato.
- `registro_pagos`  
  - FKs: `contrato_id → contratos.id_contrato`, `id_metodo_pago → metodos_pago.id_metodo_pago`.  
  - Atributos: fecha de pago, monto, observación opcional.

**Lógica de diseño:**  

- `propiedades` almacena solo el estado actual de cada inmueble, ligado a catálogos de tipo y estado.  
- `contratos` relaciona una propiedad, un cliente y un agente, indicando el tipo de contrato y su estado.  
- `contrato_detalle` guarda un histórico inmutable de las condiciones del contrato en el momento de creación (desnormalización controlada a propósito de auditoría). Esto permite que, aunque cambie la propiedad o la ciudad, se pueda reconstruir cómo estaba la información cuando se firmó.  
- `registro_pagos` almacena cada transacción económica asociada a un contrato, permitiendo calcular pagos totales, deudas y reportes.

---

### 2.4. Auditoría y logs

**Objetivo:** registrar eventos importantes del sistema y errores para trazabilidad y depuración.

Tablas:

- `console_logs`  
  - Registra acciones de alto nivel ejecutadas (SP, eventos, creación de contratos, etc.).  
  - Atributos: acción, tabla afectada, usuario, fecha.
- `error_logs`  
  - Registra errores atrapados en procedimientos almacenados.  
  - Atributos: origen (SP/proceso), mensaje de error, fecha.
- `auditoria_propiedades`  
  - FK: `propiedad_id → propiedades.id_propiedad`,  
    `estado_anterior` y `estado_nuevo → estados_propiedad.id_estado_propiedad`.  
  - Registra cada cambio de estado de una propiedad (ej. Disponible → Arrendada).  
  - Atributos: estados, fecha de cambio, usuario y comentario.
- `auditoria_contratos`  
  - FK: `contrato_id → contratos.id_contrato`.  
  - Registra cambios importantes de un contrato: por ejemplo, valor y estado.  
  - Atributos: campo modificado, valor anterior/nuevo, fecha, usuario, comentario.

**Lógica de diseño:**  
El modelo separa los datos operativos (propiedades, contratos, pagos) del historial de cambios (tablas de auditoría). Esto mantiene las tablas principales limpias y permite hacer análisis temporal sin perder rendimiento en operaciones diarias.

---

## 3. Scripts del proyecto

El proyecto se divide en varios scripts SQL para organizar la solución.

### 3.1. DDL – Creación de la base de datos

Archivo sugerido: `01_ddl_estructura.sql`

Contenido:

- Creación de la base de datos `inmobiliaria_db`.
- Creación de las 20 tablas descritas en el modelo.
- Definición de claves primarias, foráneas, `NOT NULL` y `UNIQUE`.
- Creación de la vista `vw_pagos_pendientes`, que calcula por contrato:
  - Valor mensual.  
  - Total pagado.  
  - Total pendiente (solo se muestran contratos con saldo > 0).

Este script se ejecuta primero, ya que define toda la estructura.

---

### 3.2. DML – Datos iniciales y de prueba

Archivo sugerido: `02_dml_inicial.sql`

Contenido:

- Inserción de valores en catálogos:
  - `roles` (Administrador, Agente, Contador).
  - `tipos_propiedad` (Casa, Apartamento, Local).
  - `estados_propiedad` (Disponible, Arrendada, Vendida).
  - `tipos_contrato` (Arriendo, Venta).
  - `estados_contrato` (Vigente, Finalizado, Rescindido).
  - `metodos_pago` (Efectivo, Transferencia).
- Inserción de ciudades y barrios de ejemplo.
- Inserción de personas, clientes, agentes y usuarios del sistema.
- Inserción de propiedades de ejemplo.
- Inserción de contratos y pagos para probar triggers, funciones y vistas.

**Lógica de diseño:**  
El script de datos iniciales permite que, tras ejecutarlo, el sistema tenga un escenario mínimo para probar:

- Un contrato de venta.
- Uno o varios contratos de arriendo con pagos parciales.
- Distintos estados de propiedad (disponible, arrendada, vendida).

---

### 3.3. UDFs – Funciones personalizadas

Archivo sugerido: `03_udf_funciones.sql`

Funciones implementadas:

1. `fn_calcular_comision_venta(p_contrato_id)`  
   - Entrada: id de contrato de tipo venta.  
   - Salida: valor de la comisión del agente.  
   - Lógica: `valor * comision_porcentaje / 100`.  
   - Uso típico: cálculo de comisión en reportes o consultas analíticas.

2. `fn_deuda_pendiente_arriendo(p_contrato_id)`  
   - Entrada: id de contrato (generalmente de arriendo).  
   - Obtiene el valor base del contrato y la suma de pagos en `registro_pagos`.  
   - Devuelve: `valor - total_pagado`.  
   - Se puede usar para consultas rápidas de deuda por contrato.

3. `fn_total_propiedades_disponibles_por_tipo(p_id_tipo_propiedad)`  
   - Entrada: id de tipo de propiedad.  
   - Cuenta cuántas propiedades están en estado “Disponible” para ese tipo.  
   - Utiliza `propiedades` + `estados_propiedad`.

**Lógica de diseño:**  
Las funciones encapsulan operaciones recurrentes (cálculo de comisión, deuda, conteos) en la capa de base de datos, lo que simplifica las consultas desde la aplicación o desde reportes manuales.

---

### 3.4. Triggers

Archivo sugerido: `04_triggers.sql`

Triggers implementados:

1. `trg_contratos_nuevo` (AFTER INSERT ON contratos)  
   - Registra en `console_logs` la creación de un nuevo contrato.  
   - Inserta un registro en `contrato_detalle` con un snapshot de:
     - Dirección, ciudad, barrio, departamento.  
     - Tipo de propiedad.  
     - Características físicas de la propiedad.  
     - Valor del contrato y fecha de registro.

2. `trg_propiedades_cambio_estado` (AFTER UPDATE ON propiedades)  
   - Si cambia `id_estado_propiedad`, inserta en `auditoria_propiedades`:
     - Id de la propiedad.  
     - Estado anterior y nuevo.  
     - Fecha del cambio.  
     - Usuario actual y comentario por defecto.

3. `trg_contratos_update` (AFTER UPDATE ON contratos)  
   - Si cambia el `valor`, registra el cambio en `auditoria_contratos` con campo `valor`.  
   - Si cambia `id_estado_contrato`, registra el cambio con campo `id_estado_contrato`.

**Lógica de diseño:**  
Los triggers automatizan la auditoría sin depender de la aplicación. Cualquier modificación directa sobre las tablas de negocio queda registrada automáticamente en las tablas de auditoría y logs.

---

### 3.5. Seguridad y usuarios de base de datos

Archivo sugerido: `05_security_users.sql`

Contenido:

- Creación de usuarios de MySQL:
  - `admin_app` con todos los privilegios sobre `inmobiliaria_db`.
  - `agente_app` con permisos de lectura/escritura sobre propiedades y contratos, y lectura de pagos.
  - `contador_app` con permisos de lectura sobre contratos y auditoría de propiedades, y lectura/inserción de pagos.
- Ejemplo de `GRANT` por tabla según el rol.

**Lógica de diseño:**  
La seguridad se maneja en dos niveles:

- A nivel de aplicación con `usuarios_sistema` y roles lógicos.
- A nivel de servidor MySQL con usuarios y privilegios; se restringe qué puede hacer cada tipo de usuario sobre las tablas (principio de mínimo privilegio).

---

### 3.6. Optimización y evento programado

Archivo sugerido: `06_optimizacion_eventos.sql`

Contenido:

- Creación de índices sobre columnas usadas como FKs y en filtros frecuentes:
  - Índices en FKs de `propiedades`, `contratos`, `registro_pagos`, `auditoria_*`.
- Evento mensual `ev_reporte_pagos_pendientes_mensual`:
  - Usa la vista `vw_pagos_pendientes`.
  - Cada mes inserta en `console_logs` un registro indicando que se ejecutó el reporte de pagos pendientes.

**Lógica de diseño:**  

- Los índices aceleran `JOIN` y consultas filtradas por ciudad, tipo/estado de propiedad, estado de contrato, fechas y contrato.  
- La vista `vw_pagos_pendientes` encapsula la lógica de cálculo de saldo pendiente; el evento programado demuestra el uso del `event_scheduler` para tareas periódicas (reportes automáticos).

---

### 3.7. Manejo de errores (Stored Procedures)

Archivo sugerido: `07_manejo_errores.sql`

Procedimientos:

1. `sp_crear_contrato`  
   - Inserta un nuevo contrato dentro de una transacción.  
   - `HANDLER` captura cualquier error SQL, registra el mensaje en `error_logs` y hace `ROLLBACK`.  
   - Si todo va bien, hace `COMMIT` y registra la acción en `console_logs`.

2. `sp_registrar_pago`  
   - Inserta un pago en `registro_pagos` con transacción.  
   - Si ocurre error (ej. FK inválida), se registra en `error_logs` y se deshace la operación.

3. `sp_cambiar_estado_propiedad`  
   - Actualiza el `id_estado_propiedad`.  
   - Si ocurre error, se registra en `error_logs`.  
   - Registra la acción en `console_logs`.  
   - El trigger `trg_propiedades_cambio_estado` se encarga de la auditoría de estados.

**Lógica de diseño:**  
Los SP centralizan las operaciones críticas de negocio y aseguran que:

- Siempre se registren errores de base de datos.
- Se mantenga la atomicidad de operaciones relacionadas (contrato + logs, pago + logs, cambio de estado + logs).

---

## 4. Instalación y uso

### 4.1. Requisitos

- MySQL 8.x.
- `event_scheduler` habilitado (para el evento mensual).
- Usuario con privilegios para crear bases de datos, usuarios y eventos.

### 4.2. Orden de ejecución de scripts

1. `01_ddl_estructura.sql`  
2. `02_dml_inicial.sql`  
3. `03_udf_funciones.sql`  
4. `04_triggers.sql`  
5. `05_security_users.sql`  
6. `06_optimizacion_eventos.sql`  
7. `07_manejo_errores.sql`  
8. Opcional: script de pruebas (`08_testing.sql`) con consultas y llamadas a SP/UDF.

---

## 5. Ejemplos de consultas útiles

- Propiedades disponibles por ciudad y tipo:

```sql
SELECT c.nombre AS ciudad,
       tp.nombre AS tipo_propiedad,
       COUNT(*)  AS total
FROM propiedades p
JOIN ciudades c        ON c.id_ciudad = p.ciudad_id
JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
JOIN estados_propiedad ep ON ep.id_estado_propiedad = p.id_estado_propiedad
WHERE ep.nombre = 'Disponible'
GROUP BY c.nombre, tp.nombre;
