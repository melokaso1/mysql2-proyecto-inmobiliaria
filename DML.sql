USE inmobiliaria_db;

INSERT INTO roles (nombre) VALUES
('Administrador'),
('Agente'),
('Contador');

INSERT INTO tipos_propiedad (nombre) VALUES
('Casa'),
('Apartamento'),
('Local');

INSERT INTO estados_propiedad (nombre) VALUES
('Disponible'),
('Arrendada'),
('Vendida');

INSERT INTO tipos_contrato (nombre) VALUES
('Arriendo'),
('Venta');

INSERT INTO estados_contrato (nombre) VALUES
('Vigente'),
('Finalizado'),
('Rescindido');

INSERT INTO metodos_pago (nombre) VALUES
('Efectivo'),
('Transferencia');

INSERT INTO ciudades (nombre, departamento) VALUES
('Floridablanca', 'Santander'),
('Bucaramanga',  'Santander');

INSERT INTO barrios (ciudad_id, nombre) VALUES
(1, 'Cañaveral'),
(1, 'Lagos'),
(2, 'Cabecera');

INSERT INTO personas (nombre, apellido, tipo_doc, num_doc, telefono, email, direccion) VALUES
('Juan',  'Pérez',   'CC', '100000001', '300000001', 'juan@example.com',  'Calle 1 #1-01'),
('Ana',   'Gómez',   'CC', '100000002', '300000002', 'ana@example.com',   'Calle 2 #2-02'),
('Luis',  'Ramírez', 'CC', '100000003', '300000003', 'luis@example.com',  'Calle 3 #3-03'),
('Marta', 'López',   'CC', '100000004', '300000004', 'marta@example.com', 'Calle 4 #4-04');

INSERT INTO clientes (id_cliente, fecha_registro) VALUES
(1, '2025-01-10'),
(2, '2025-02-15');

INSERT INTO agentes_inmobiliarios (id_agente, codigo) VALUES
(3, 'AG001'),
(4, 'AG002');

INSERT INTO usuarios_sistema (persona_id, username, password_hash, id_rol) VALUES
(3, 'admin',  'hash_admin', 1),
(3, 'agente', 'hash_agente', 2),
(4, 'conta',  'hash_conta', 3);

INSERT INTO propiedades (
    ciudad_id, barrio_id, id_tipo_propiedad, id_estado_propiedad,
    direccion, area_m2, num_habitaciones, num_banos, parqueadero, valor_referencia
) VALUES
(1, 1, 1, 1, 'Calle 10 #10-10',      120.00, 3, 2, TRUE, 150000000.00),
(1, 2, 2, 1, 'Carrera 20 #20-20',     80.00, 2, 2, FALSE,  90000000.00),
(2, 3, 3, 1, 'Av Principal #30-30',   60.00, 0, 1, FALSE,   5000000.00);

INSERT INTO contratos (
    propiedad_id, cliente_id, agente_id,
    id_tipo_contrato, id_estado_contrato,
    fecha_inicio, fecha_fin, valor, comision_porcentaje
) VALUES
(1, 1, 3, 2, 1, '2025-03-01', NULL,          180000000.00, 3.00),
(2, 2, 3, 1, 1, '2025-03-01', '2026-02-28',    1200000.00, 5.00);

INSERT INTO contrato_detalle (
    contrato_id, direccion, ciudad, barrio, departamento,
    tipo_propiedad, area_m2, num_habitaciones, num_banos,
    parqueadero, valor_contrato, fecha_registro
) VALUES
(1, 'Calle 10 #10-10',    'Floridablanca', 'Cañaveral', 'Santander',
 'Casa',        120.00, 3, 2, TRUE, 180000000.00, '2025-03-01 10:00:00'),
(2, 'Carrera 20 #20-20',  'Floridablanca', 'Lagos',     'Santander',
 'Apartamento',  80.00, 2, 2, FALSE,   1200000.00, '2025-03-01 11:00:00');

INSERT INTO registro_pagos (
    contrato_id, fecha_pago, monto, id_metodo_pago, observacion
) VALUES
(2, '2025-03-10',   600000.00, 2, 'Primer pago parcial'),
(2, '2025-04-10',   600000.00, 1, 'Segundo pago'),
(1, '2025-03-15', 180000000.00, 2, 'Pago venta contado');
