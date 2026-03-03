USE inmobiliaria_db;

DELIMITER $$

CREATE FUNCTION fn_calcular_comision_venta(
    p_contrato_id INT
) RETURNS DECIMAL(20,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_valor DECIMAL(20,2);
    DECLARE v_pct   DECIMAL(5,2);

    SELECT valor, comision_porcentaje
    INTO v_valor, v_pct
    FROM contratos
    WHERE id_contrato = p_contrato_id;

    IF v_valor IS NULL OR v_pct IS NULL THEN
        RETURN 0;
    END IF;

    RETURN (v_valor * v_pct / 100);
END$$

CREATE FUNCTION fn_deuda_pendiente_arriendo(
    p_contrato_id INT
) RETURNS DECIMAL(20,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_valor_mensual DECIMAL(20,2);
    DECLARE v_pagado        DECIMAL(20,2);

    SELECT valor
    INTO v_valor_mensual
    FROM contratos
    WHERE id_contrato = p_contrato_id;

    IF v_valor_mensual IS NULL THEN
        RETURN 0;
    END IF;

    SELECT IFNULL(SUM(monto), 0)
    INTO v_pagado
    FROM registro_pagos
    WHERE contrato_id = p_contrato_id;

    RETURN (v_valor_mensual - v_pagado);
END$$

CREATE FUNCTION fn_total_propiedades_disponibles_por_tipo(
    p_id_tipo_propiedad INT
) RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_result INT;

    SELECT COUNT(*)
    INTO v_result
    FROM propiedades p
    JOIN estados_propiedad ep
        ON ep.id_estado_propiedad = p.id_estado_propiedad
    WHERE p.id_tipo_propiedad = p_id_tipo_propiedad
      AND ep.nombre = 'Disponible';

    RETURN IFNULL(v_result, 0);
END$$

DELIMITER ;
