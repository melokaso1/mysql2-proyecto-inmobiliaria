USE inmobiliaria_db;

DELIMITER $$

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

    INSERT INTO contrato_detalle (
        contrato_id,
        direccion,
        ciudad,
        barrio,
        departamento,
        tipo_propiedad,
        area_m2,
        num_habitaciones,
        num_banos,
        parqueadero,
        valor_contrato,
        fecha_registro
    )
    SELECT
        NEW.id_contrato,
        p.direccion,
        c.nombre,
        b.nombre,
        c.departamento,
        tp.nombre,
        p.area_m2,
        p.num_habitaciones,
        p.num_banos,
        p.parqueadero,
        NEW.valor,
        NOW()
    FROM propiedades p
    JOIN ciudades        c  ON c.id_ciudad          = p.ciudad_id
    LEFT JOIN barrios    b  ON b.id_barrio          = p.barrio_id
    JOIN tipos_propiedad tp ON tp.id_tipo_propiedad = p.id_tipo_propiedad
    WHERE p.id_propiedad = NEW.propiedad_id;
END$$

CREATE TRIGGER trg_propiedades_cambio_estado
AFTER UPDATE ON propiedades
FOR EACH ROW
BEGIN
    IF OLD.id_estado_propiedad <> NEW.id_estado_propiedad THEN
        INSERT INTO auditoria_propiedades (
            propiedad_id,
            estado_anterior,
            estado_nuevo,
            fecha_cambio,
            usuario,
            comentario
        ) VALUES (
            NEW.id_propiedad,
            OLD.id_estado_propiedad,
            NEW.id_estado_propiedad,
            NOW(),
            CURRENT_USER(),
            'Cambio de estado de propiedad'
        );
    END IF;
END$$

CREATE TRIGGER trg_contratos_update
AFTER UPDATE ON contratos
FOR EACH ROW
BEGIN
    IF OLD.valor <> NEW.valor THEN
        INSERT INTO auditoria_contratos (
            contrato_id,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            fecha_cambio,
            usuario,
            comentario
        ) VALUES (
            NEW.id_contrato,
            'valor',
            OLD.valor,
            NEW.valor,
            NOW(),
            CURRENT_USER(),
            'Cambio de valor de contrato'
        );
    END IF;

    IF OLD.id_estado_contrato <> NEW.id_estado_contrato THEN
        INSERT INTO auditoria_contratos (
            contrato_id,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            fecha_cambio,
            usuario,
            comentario
        ) VALUES (
            NEW.id_contrato,
            'id_estado_contrato',
            OLD.id_estado_contrato,
            NEW.id_estado_contrato,
            NOW(),
            CURRENT_USER(),
            'Cambio de estado de contrato'
        );
    END IF;
END$$

DELIMITER ;
