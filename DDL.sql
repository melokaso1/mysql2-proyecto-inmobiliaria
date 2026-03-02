create database if not exists Inmobiliaria_manejo_propiedades;

use Inmobiliaria_manejo_propiedades;

CREATE TABLE personas (
    id_persona        INT          NOT NULL,
    nombre            VARCHAR(50)  NOT NULL,
    apellido          VARCHAR(50)  NOT NULL,
    correo            VARCHAR(200) NOT NULL,
    telefono_contacto VARCHAR(20)  NOT NULL,
    PRIMARY KEY (id_persona)
);

CREATE TABLE agentes_inmobiliarios (
    id_agente         INT NOT NULL AUTO_INCREMENT,
    persona_id        INT NOT NULL,
    activo            BOOLEAN,
    comision_venta    DECIMAL(4,3),
    comision_arriendo DECIMAL(4,3),
    PRIMARY KEY (id_agente),
    KEY idx_agente_persona (persona_id),
    CONSTRAINT fk_agente_persona
        FOREIGN KEY (persona_id) REFERENCES personas(id_persona)
);

CREATE TABLE clientes (
    id_cliente  INT NOT NULL,
    pago_estado ENUM('Pendiente','Realizado') NOT NULL,
    PRIMARY KEY (id_cliente),
    CONSTRAINT fk_cliente_persona
        FOREIGN KEY (id_cliente) REFERENCES personas(id_persona)
);

CREATE TABLE propiedades (
    id_propiedad   INT NOT NULL AUTO_INCREMENT,
    direccion      VARCHAR(200) NOT NULL,
    tipo_propiedad ENUM('Casa','Apartamento','Local') NOT NULL,
    estado         ENUM('Arriendo','Vendida','Disponible') NOT NULL
                    DEFAULT 'Disponible',
    valor_arriendo DECIMAL(20,2) NOT NULL,
    valor_venta    DECIMAL(20,2) NOT NULL,
    observacion    VARCHAR(200)  NOT NULL,
    PRIMARY KEY (id_propiedad)
);

CREATE TABLE contratos (
    id_contrato   INT NOT NULL AUTO_INCREMENT,
    propiedad_id  INT NOT NULL,
    cliente_id    INT NOT NULL,
    agente_id     INT NOT NULL,
    tipo_contrato ENUM('Arriendo','Venta') NOT NULL,
    valor         DECIMAL(20,2) NOT NULL,
    fecha_inicio  DATE NOT NULL,
    fecha_fin     DATE NOT NULL,
    estado        ENUM('Vigente','Finalizado','Rescindido')
                    NOT NULL DEFAULT 'Vigente',
    PRIMARY KEY (id_contrato),
    KEY idx_contratos_cliente   (cliente_id),
    KEY idx_contratos_agente    (agente_id),
    KEY idx_contratos_propiedad (propiedad_id),
    CONSTRAINT fk_contrato_propiedad
        FOREIGN KEY (propiedad_id) REFERENCES propiedades(id_propiedad),
    CONSTRAINT fk_contrato_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_contrato_agente
        FOREIGN KEY (agente_id) REFERENCES agentes_inmobiliarios(id_agente)
);

CREATE TABLE registro_pagos (
    id_pago       INT NOT NULL AUTO_INCREMENT,
    cliente_id    INT NOT NULL,
    contrato_id   INT NOT NULL,
    total_pagado  DECIMAL(20,2) NOT NULL,
    fecha_pago    DATETIME      NOT NULL,
    metodo_pago   ENUM('Efectivo','Transferencia') NOT NULL,
    observaciones VARCHAR(200),
    PRIMARY KEY (id_pago, fecha_pago),
    KEY idx_pagos_contrato (contrato_id),
    KEY idx_pagos_cliente  (cliente_id),
    CONSTRAINT fk_pago_cliente
        FOREIGN KEY (cliente_id) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_pago_contrato
        FOREIGN KEY (contrato_id) REFERENCES contratos(id_contrato)
)
PARTITION BY RANGE (YEAR(fecha_pago)*100 + MONTH(fecha_pago)) (
    PARTITION p202501 VALUES LESS THAN (202502),
    PARTITION p202502 VALUES LESS THAN (202503),
    PARTITION p202503 VALUES LESS THAN (202504),
    PARTITION p202504 VALUES LESS THAN (202505),
    PARTITION p202505 VALUES LESS THAN (202506),
    PARTITION p202506 VALUES LESS THAN (202507),
    PARTITION p202507 VALUES LESS THAN (202508),
    PARTITION p202508 VALUES LESS THAN (202509),
    PARTITION p202509 VALUES LESS THAN (202510),
    PARTITION p202510 VALUES LESS THAN (202511),
    PARTITION p202511 VALUES LESS THAN (202512),
    PARTITION p202512 VALUES LESS THAN (202601),
    PARTITION pmax    VALUES LESS THAN MAXVALUE
);

CREATE TABLE console_logs (
    id_log         INT NOT NULL AUTO_INCREMENT,
    accion         VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    usuario        VARCHAR(100) NOT NULL,
    fecha_evento   DATETIME     NOT NULL,
    PRIMARY KEY (id_log, fecha_evento),
    KEY idx_consolelogs_fecha (fecha_evento)
)
PARTITION BY RANGE (YEAR(fecha_evento)) (
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION pmax  VALUES LESS THAN MAXVALUE
);

CREATE TABLE error_logs (
    id_error_log   INT NOT NULL AUTO_INCREMENT,
    codigo_error   VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    fecha_error    DATETIME     NOT NULL,
    usuario        VARCHAR(50)  NOT NULL,
    PRIMARY KEY (id_error_log),
    KEY idx_errorlogs_fecha (fecha_error)
);
