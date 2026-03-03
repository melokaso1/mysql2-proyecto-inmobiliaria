USE inmobiliaria_db;

CREATE INDEX idx_propiedades_ciudad     ON propiedades (ciudad_id);
CREATE INDEX idx_propiedades_estado     ON propiedades (id_estado_propiedad);
CREATE INDEX idx_propiedades_tipo       ON propiedades (id_tipo_propiedad);

CREATE INDEX idx_contratos_propiedad    ON contratos (propiedad_id);
CREATE INDEX idx_contratos_cliente      ON contratos (cliente_id);
CREATE INDEX idx_contratos_agente       ON contratos (agente_id);
CREATE INDEX idx_contratos_estado       ON contratos (id_estado_contrato);
CREATE INDEX idx_contratos_tipo         ON contratos (id_tipo_contrato);
CREATE INDEX idx_contratos_fecha_inicio ON contratos (fecha_inicio);

CREATE INDEX idx_pagos_contrato         ON registro_pagos (contrato_id);
CREATE INDEX idx_pagos_fecha            ON registro_pagos (fecha_pago);

CREATE INDEX idx_aud_prop_propiedad     ON auditoria_propiedades (propiedad_id, fecha_cambio);
CREATE INDEX idx_aud_contrato_fecha     ON auditoria_contratos (contrato_id, fecha_cambio);

SET GLOBAL event_scheduler = ON;

DELIMITER $$

CREATE EVENT IF NOT EXISTS ev_reporte_pagos_pendientes_mensual
ON SCHEDULE EVERY 1 MONTH
STARTS CURRENT_DATE + INTERVAL 1 DAY
DO
BEGIN
    INSERT INTO console_logs (accion, tabla_afectada, usuario, fecha_evento)
    SELECT
        'EJECUCION_REPORTE_PAGOS_PENDIENTES',
        'vw_pagos_pendientes',
        CURRENT_USER(),
        NOW();
END$$

DELIMITER ;
