USE inmobiliaria_db;

CREATE TABLE IF NOT EXISTS console_logs (
    id_log         INT AUTO_INCREMENT PRIMARY KEY,
    accion         VARCHAR(100) NOT NULL,
    tabla_afectada VARCHAR(100) NOT NULL,
    usuario        VARCHAR(100) NOT NULL,
    fecha_evento   DATETIME     NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS error_logs (
    id_error      INT AUTO_INCREMENT PRIMARY KEY,
    origen        VARCHAR(100) NOT NULL,
    mensaje_error VARCHAR(255) NOT NULL,
    fecha_error   DATETIME     NOT NULL DEFAULT NOW()
);

DELIMITER $$

CREATE PROCEDURE sp_crear_contrato (
    IN p_propiedad_id        INT,
    IN p_cliente_id          BIGINT,
    IN p_agente_id           BIGINT,
    IN p_id_tipo_contrato    INT,
    IN p_id_estado_contrato  INT,
    IN p_fecha_inicio        DATE,
    IN p_fecha_fin           DATE,
    IN p_valor               DECIMAL(20,2),
    IN p_comision_porcentaje DECIMAL(5,2)
)
BEGIN
    DECLARE v_error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        INSERT INTO error_logs (origen, mensaje_error)
        VALUES ('sp_crear_contrato', v_error_message);
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO contratos (
        propiedad_id,
        cliente_id,
        agente_id,
        id_tipo_contrato,
        id_estado_contrato,
        fecha_inicio,
        fecha_fin,
        valor,
        comision_porcentaje
    ) VALUES (
        p_propiedad_id,
        p_cliente_id,
        p_agente_id,
        p_id_tipo_contrato,
        p_id_estado_contrato,
        p_fecha_inicio,
        p_fecha_fin,
        p_valor,
        p_comision_porcentaje
    );

    INSERT INTO console_logs (accion, tabla_afectada, usuario, fecha_evento)
    VALUES ('SP_CREAR_CONTRATO', 'contratos', CURRENT_USER(), NOW());

    COMMIT;
END$$

CREATE PROCEDURE sp_registrar_pago (
    IN p_contrato_id    INT,
    IN p_fecha_pago     DATE,
    IN p_monto          DECIMAL(20,2),
    IN p_id_metodo_pago INT,
    IN p_observacion    VARCHAR(255)
)
BEGIN
    DECLARE v_error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        INSERT INTO error_logs (origen, mensaje_error)
        VALUES ('sp_registrar_pago', v_error_message);
        ROLLBACK;
    END;

    START TRANSACTION;

    INSERT INTO registro_pagos (
        contrato_id,
        fecha_pago,
        monto,
        id_metodo_pago,
        observacion
    ) VALUES (
        p_contrato_id,
        p_fecha_pago,
        p_monto,
        p_id_metodo_pago,
        p_observacion
    );

    INSERT INTO console_logs (accion, tabla_afectada, usuario, fecha_evento)
    VALUES ('SP_REGISTRAR_PAGO', 'registro_pagos', CURRENT_USER(), NOW());

    COMMIT;
END$$

CREATE PROCEDURE sp_cambiar_estado_propiedad (
    IN p_propiedad_id    INT,
    IN p_nuevo_estado_id INT,
    IN p_comentario      VARCHAR(255)
)
BEGIN
    DECLARE v_error_message VARCHAR(255);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 v_error_message = MESSAGE_TEXT;
        INSERT INTO error_logs (origen, mensaje_error)
        VALUES ('sp_cambiar_estado_propiedad', v_error_message);
        ROLLBACK;
    END;

    START TRANSACTION;

    UPDATE propiedades
    SET id_estado_propiedad = p_nuevo_estado_id
    WHERE id_propiedad = p_propiedad_id;

    INSERT INTO console_logs (accion, tabla_afectada, usuario, fecha_evento)
    VALUES ('SP_CAMBIAR_ESTADO_PROPIEDAD', 'propiedades', CURRENT_USER(), NOW());

    COMMIT;
END$$

DELIMITER ;
