USE Inmobiliaria;

DELIMITER $$

CREATE OR REPLACE VIEW vw_contratos_detalle AS
SELECT
    c.id_contrato,
    c.tipo_contrato,
    c.valor,
    c.fecha_inicio,
    c.fecha_fin,
    c.estado,
    p.direccion,
    p.tipo_propiedad,
    cli.id_cliente,
    per_cli.nombre   AS nombre_cliente,
    per_cli.apellido AS apellido_cliente,
    a.id_agente,
    per_age.nombre   AS nombre_agente,
    per_age.apellido AS apellido_agente
FROM contratos c
JOIN propiedades p           ON p.id_propiedad = c.propiedad_id
JOIN clientes   cli          ON cli.id_cliente = c.cliente_id
JOIN personas   per_cli      ON per_cli.id_persona = cli.id_cliente
JOIN agentes_inmobiliarios a ON a.id_agente = c.agente_id
JOIN personas   per_age      ON per_age.id_persona = a.persona_id$$

CREATE OR REPLACE VIEW vw_pagos_por_contrato AS
SELECT
    c.id_contrato,
    c.cliente_id,
    c.tipo_contrato,
    c.valor          AS valor_contrato,
    IFNULL(SUM(rp.total_pagado), 0) AS total_pagado,
    (c.valor - IFNULL(SUM(rp.total_pagado), 0)) AS deuda
FROM contratos c
LEFT JOIN registro_pagos rp ON rp.contrato_id = c.id_contrato
GROUP BY c.id_contrato, c.cliente_id, c.tipo_contrato, c.valor$$

CREATE TABLE IF NOT EXISTS reporte_pagos_pendientes (
    id_reporte    INT AUTO_INCREMENT PRIMARY KEY,
    fecha_reporte DATE         NOT NULL,
    contrato_id   INT          NOT NULL,
    cliente_id    BIGINT       NOT NULL,
    total_deuda   DECIMAL(20,2) NOT NULL
)$$

SET GLOBAL event_scheduler = ON$$

CREATE EVENT IF NOT EXISTS ev_reporte_pagos_pendientes_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS '2025-02-01 00:00:00'
DO
INSERT INTO reporte_pagos_pendientes (fecha_reporte, contrato_id, cliente_id, total_deuda)
SELECT
    CURDATE(),
    c.id_contrato,
    c.cliente_id,
    c.valor - IFNULL(SUM(rp.total_pagado), 0) AS total_deuda
FROM contratos c
LEFT JOIN registro_pagos rp ON rp.contrato_id = c.id_contrato
WHERE c.tipo_contrato = 'Arriendo'
GROUP BY c.id_contrato, c.cliente_id, c.valor
HAVING total_deuda > 0$$

DELIMITER ;
