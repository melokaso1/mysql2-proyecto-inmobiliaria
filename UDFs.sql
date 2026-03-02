USE Inmobiliaria;

DELIMITER $$

CREATE FUNCTION fn_calcular_comision_venta(p_contrato_id INT)
RETURNS DECIMAL(20,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_valor_contrato DECIMAL(20,2);
    DECLARE v_comision_venta DECIMAL(4,3);
    DECLARE v_resultado      DECIMAL(20,2);

    SELECT c.valor, a.comision_venta
    INTO v_valor_contrato, v_comision_venta
    FROM contratos c
    JOIN agentes_inmobiliarios a ON a.id_agente = c.agente_id
    WHERE c.id_contrato = p_contrato_id;

    SET v_resultado = v_valor_contrato * v_comision_venta;
    RETURN v_resultado;
END$$

CREATE FUNCTION fn_deuda_pendiente_arriendo(p_contrato_id INT)
RETURNS DECIMAL(20,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_valor_contrato DECIMAL(20,2);
    DECLARE v_total_pagado   DECIMAL(20,2);
    DECLARE v_deuda          DECIMAL(20,2);

    SELECT valor
    INTO v_valor_contrato
    FROM contratos
    WHERE id_contrato = p_contrato_id
      AND tipo_contrato = 'Arriendo';

    SELECT IFNULL(SUM(total_pagado), 0)
    INTO v_total_pagado
    FROM registro_pagos
    WHERE contrato_id = p_contrato_id;

    SET v_deuda = v_valor_contrato - v_total_pagado;
    IF v_deuda < 0 THEN
        SET v_deuda = 0;
    END IF;

    RETURN v_deuda;
END$$

CREATE FUNCTION fn_total_propiedades_disponibles_por_tipo(p_tipo VARCHAR(20))
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_total INT;

    SELECT COUNT(*)
    INTO v_total
    FROM propiedades
    WHERE estado = 'Disponible'
      AND tipo_propiedad = p_tipo;

    RETURN v_total;
END$$

DELIMITER ;
