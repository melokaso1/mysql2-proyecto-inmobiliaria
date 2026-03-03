USE inmobiliaria_db;

SELECT * FROM ciudades;
SELECT * FROM barrios;
SELECT * FROM personas;
SELECT * FROM clientes;
SELECT * FROM agentes_inmobiliarios;
SELECT * FROM usuarios_sistema;
SELECT * FROM propiedades;
SELECT * FROM contratos;
SELECT * FROM contrato_detalle;
SELECT * FROM registro_pagos;
SELECT * FROM roles;
SELECT * FROM metodos_pago;
SELECT * FROM estados_propiedad;
SELECT * FROM estados_contrato;
SELECT * FROM tipos_propiedad;
SELECT * FROM tipos_contrato;
SELECT * FROM auditoria_propiedades;
SELECT * FROM auditoria_contratos;
SELECT * FROM console_logs;
SELECT * FROM error_logs;
SELECT * FROM vw_pagos_pendientes;

SELECT fn_calcular_comision_venta(1) AS comision_contrato_1;
SELECT fn_deuda_pendiente_arriendo(2) AS deuda_contrato_2;
SELECT fn_total_propiedades_disponibles_por_tipo(1) AS casas_disponibles;

CALL sp_crear_contrato(
    3,
    1,
    3,
    1,
    1,
    '2025-05-01',
    '2026-04-30',
    1300000.00,
    4.00
);

CALL sp_registrar_pago(
    2,
    '2025-05-10',
    600000.00,
    1,
    'Tercer pago'
);

CALL sp_cambiar_estado_propiedad(1, 2, 'Propiedad arrendada a cliente 1');

SELECT * FROM auditoria_propiedades WHERE propiedad_id = 1;
SELECT * FROM auditoria_contratos WHERE contrato_id = 1;
SELECT * FROM vw_pagos_pendientes;

SELECT USER() AS user_logico, CURRENT_USER() AS user_mysql;
