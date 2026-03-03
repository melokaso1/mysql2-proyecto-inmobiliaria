DROP DATABASE IF EXISTS inmobiliaria_db;
CREATE DATABASE inmobiliaria_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE inmobiliaria_db;

CREATE TABLE ciudades (
    id_ciudad    INT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    departamento VARCHAR(100) NOT NULL
);

CREATE TABLE barrios (
    id_barrio INT AUTO_INCREMENT PRIMARY KEY,
    ciudad_id INT NOT NULL,
    nombre    VARCHAR(100) NOT NULL,
    CONSTRAINT fk_barrio_ciudad
        FOREIGN KEY (ciudad_id) REFERENCES ciudades(id_ciudad)
);

CREATE TABLE personas (
    id_persona   BIGINT AUTO_INCREMENT PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    apellido     VARCHAR(100) NOT NULL,
    tipo_doc     VARCHAR(20)  NOT NULL,
    num_doc      VARCHAR(50)  NOT NULL UNIQUE,
    telefono     VARCHAR(30)  NULL,
    email        VARCHAR(150) NULL,
    direccion    VARCHAR(200) NULL
);

CREATE TABLE clientes (
    id_cliente      BIGINT PRIMARY KEY,
    fecha_registro  DATE NOT NULL,
    CONSTRAINT fk_cliente_persona
        FOREIGN KEY (id_cliente) REFERENCES personas(id_persona)
);

CREATE TABLE agentes_inmobiliarios (
    id_agente BIGINT PRIMARY KEY,
    codigo    VARCHAR(20) NOT NULL UNIQUE,
    CONSTRAINT fk_agente_persona
        FOREIGN KEY (id_agente) REFERENCES personas(id_persona)
);

CREATE TABLE tipos_propiedad (
    id_tipo_propiedad INT AUTO_INCREMENT PRIMARY KEY,
    nombre            VARCHAR(50) NOT NULL
);

CREATE TABLE estados_propiedad (
    id_estado_propiedad INT AUTO_INCREMENT PRIMARY KEY,
    nombre              VARCHAR(50) NOT NULL
);

CREATE TABLE propiedades (
    id_propiedad        INT AUTO_INCREMENT PRIMARY KEY,
    ciudad_id           INT NOT NULL,
    barrio_id           INT NULL,
    id_tipo_propiedad   INT NOT NULL,
    id_estado_propiedad INT NOT NULL,
    direccion           VARCHAR(200) NOT NULL,
    area_m2             DECIMAL(10,2) NULL,
    num_habitaciones    TINYINT NULL,
    num_banos           TINYINT NULL,
    parqueadero         BOOLEAN NULL,
    valor_referencia    DECIMAL(20,2) NULL,
    CONSTRAINT fk_prop_ciudad
        FOREIGN KEY (ciudad_id) REFERENCES ciudades(id_ciudad),
    CONSTRAINT fk_prop_barrio
        FOREIGN KEY (barrio_id) REFERENCES barrios(id_barrio),
    CONSTRAINT fk_prop_tipo
        FOREIGN KEY (id_tipo_propiedad) REFERENCES tipos_propiedad(id_tipo_propiedad),
    CONSTRAINT fk_prop_estado
        FOREIGN KEY (id_estado_propiedad) REFERENCES estados_propiedad(id_estado_propiedad)
);

CREATE TABLE tipos_contrato (
    id_tipo_contrato INT AUTO_INCREMENT PRIMARY KEY,
    nombre           VARCHAR(50) NOT NULL
);

CREATE TABLE estados_contrato (
    id_estado_contrato INT AUTO_INCREMENT PRIMARY KEY,
    nombre             VARCHAR(50) NOT NULL
);

CREATE TABLE contratos (
    id_contrato         INT AUTO_INCREMENT PRIMARY KEY,
    propiedad_id        INT     NOT NULL,
    cliente_id          BIGINT  NOT NULL,
    agente_id           BIGINT  NOT NULL,
    id_tipo_contrato    INT     NOT NULL,
    id_estado_contrato  INT     NOT NULL,
    fecha_inicio        DATE    NOT NULL,
    fecha_fin           DATE    NULL,
    valor               DECIMAL(20,2) NOT NULL,
    comision_porcentaje DECIMAL(5,2) NOT NULL DEFAULT 3.00,
    CONSTRAINT fk_contrato_prop
        FOREIGN KEY (propiedad_id) REFERENCES propiedades(id_propiedad),
    CONSTRAINT fk_contrato_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_contrato_agente
        FOREIGN KEY (agente_id) REFERENCES agentes_inmobiliarios(id_agente),
    CONSTRAINT fk_contrato_tipo
        FOREIGN KEY (id_tipo_contrato) REFERENCES tipos_contrato(id_tipo_contrato),
    CONSTRAINT fk_contrato_estado
        FOREIGN KEY (id_estado_contrato) REFERENCES estados_contrato(id_estado_contrato)
);

CREATE TABLE contrato_detalle (
    id_detalle          INT AUTO_INCREMENT PRIMARY KEY,
    contrato_id         INT NOT NULL,
    direccion           VARCHAR(200) NOT NULL,
    ciudad              VARCHAR(100) NOT NULL,
    barrio              VARCHAR(100) NULL,
    departamento        VARCHAR(100) NOT NULL,
    tipo_propiedad      VARCHAR(50)  NOT NULL,
    area_m2             DECIMAL(10,2) NULL,
    num_habitaciones    TINYINT NULL,
    num_banos           TINYINT NULL,
    parqueadero         BOOLEAN NULL,
    valor_contrato      DECIMAL(20,2) NOT NULL,
    fecha_registro      DATETIME NOT NULL,
    CONSTRAINT fk_detalle_contrato
        FOREIGN KEY (contrato_id) REFERENCES contratos(id_contrato)
);

CREATE TABLE metodos_pago (
    id_metodo_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre         VARCHAR(50) NOT NULL
);

CREATE TABLE registro_pagos (
    id_pago        INT AUTO_INCREMENT PRIMARY KEY,
    contrato_id    INT         NOT NULL,
    fecha_pago     DATE        NOT NULL,
    monto          DECIMAL(20,2) NOT NULL,
    id_metodo_pago INT         NOT NULL,
    observacion    VARCHAR(255) NULL,
    CONSTRAINT fk_pago_contrato
        FOREIGN KEY (contrato_id) REFERENCES contratos(id_contrato),
    CONSTRAINT fk_pago_metodo
        FOREIGN KEY (id_metodo_pago) REFERENCES metodos_pago(id_metodo_pago)
);

CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE usuarios_sistema (
    id_usuario    INT AUTO_INCREMENT PRIMARY KEY,
    persona_id    BIGINT      NOT NULL,
    username      VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    id_rol        INT         NOT NULL,
    CONSTRAINT fk_usuario_persona
        FOREIGN KEY (persona_id) REFERENCES personas(id_persona),
    CONSTRAINT fk_usuario_rol
        FOREIGN KEY (id_rol) REFERENCES roles(id_rol)
);

CREATE TABLE console_logs (
    id_log         INT AUTO_INCREMENT PRIMARY KEY,
    accion         VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    usuario        VARCHAR(100) NOT NULL,
    fecha_evento   DATETIME     NOT NULL DEFAULT NOW()
);

CREATE TABLE error_logs (
    id_error      INT AUTO_INCREMENT PRIMARY KEY,
    origen        VARCHAR(100) NOT NULL,
    mensaje_error VARCHAR(255) NOT NULL,
    fecha_error   DATETIME     NOT NULL DEFAULT NOW()
);

CREATE TABLE auditoria_propiedades (
    id_auditoria    INT AUTO_INCREMENT PRIMARY KEY,
    propiedad_id    INT          NOT NULL,
    estado_anterior INT          NULL,
    estado_nuevo    INT          NOT NULL,
    fecha_cambio    DATETIME     NOT NULL DEFAULT NOW(),
    usuario         VARCHAR(100) NOT NULL,
    comentario      VARCHAR(255) NULL,
    CONSTRAINT fk_aud_prop
        FOREIGN KEY (propiedad_id)    REFERENCES propiedades(id_propiedad),
    CONSTRAINT fk_aud_est_ant
        FOREIGN KEY (estado_anterior) REFERENCES estados_propiedad(id_estado_propiedad),
    CONSTRAINT fk_aud_est_nuevo
        FOREIGN KEY (estado_nuevo)    REFERENCES estados_propiedad(id_estado_propiedad)
);

CREATE TABLE auditoria_contratos (
    id_auditoria     INT AUTO_INCREMENT PRIMARY KEY,
    contrato_id      INT          NOT NULL,
    campo_modificado VARCHAR(100) NOT NULL,
    valor_anterior   VARCHAR(255) NULL,
    valor_nuevo      VARCHAR(255) NULL,
    fecha_cambio     DATETIME     NOT NULL DEFAULT NOW(),
    usuario          VARCHAR(100) NOT NULL,
    comentario       VARCHAR(255) NULL,
    CONSTRAINT fk_aud_contrato
        FOREIGN KEY (contrato_id) REFERENCES contratos(id_contrato)
);

CREATE OR REPLACE VIEW vw_pagos_pendientes AS
SELECT
    c.id_contrato,
    c.cliente_id,
    c.propiedad_id,
    c.valor AS valor_mensual,
    IFNULL(SUM(rp.monto), 0) AS total_pagado,
    (c.valor - IFNULL(SUM(rp.monto), 0)) AS total_pendiente
FROM contratos c
LEFT JOIN registro_pagos rp ON rp.contrato_id = c.id_contrato
GROUP BY c.id_contrato, c.cliente_id, c.propiedad_id, c.valor
HAVING total_pendiente > 0;
