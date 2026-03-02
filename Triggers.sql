USE Inmobiliaria;

DELIMITER $$

CREATE TRIGGER trg_propiedades_cambio_estado
AFTER UPDATE ON propiedades
FOR EACH ROW
BEGIN
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO console_logs (accion, tabla_afectada, usuario, fecha_evento)
        VALUES (
            CONCAT('CAMBIO_ESTADO_', OLD.estado, '_A_', NEW.estado),
            'propiedades',
            CURRENT_USER(),
            NOW()
        );
    END IF;
END$$

CREATE TRIGGER trg_contratos_nuevo
AFTER INSERT ON contratos
FOR EACH ROW
BEGIN
    INSERT INTO console_logs (accion, tabla_afectada, usuario, fecha_evento)
    VALUES (
        CONCAT('NUEVO_CONTRATO_', NEW.id_contrato),
        'contratos',
        CURRENT_USER(),
        NOW()
    );
END$$

DELIMITER ;
