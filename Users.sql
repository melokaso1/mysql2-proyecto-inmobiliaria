USE inmobiliaria_db;

CREATE USER IF NOT EXISTS 'admin_app'@'%' IDENTIFIED BY 'Admin123!';
CREATE USER IF NOT EXISTS 'agente_app'@'%' IDENTIFIED BY 'Agente123!';
CREATE USER IF NOT EXISTS 'contador_app'@'%' IDENTIFIED BY 'Contador123!';

GRANT ALL PRIVILEGES
ON inmobiliaria_db.*
TO 'admin_app'@'%';

GRANT SELECT, INSERT, UPDATE
ON inmobiliaria_db.propiedades
TO 'agente_app'@'%';

GRANT SELECT, INSERT, UPDATE
ON inmobiliaria_db.contratos
TO 'agente_app'@'%';

GRANT SELECT
ON inmobiliaria_db.registro_pagos
TO 'agente_app'@'%';

GRANT SELECT
ON inmobiliaria_db.contratos
TO 'contador_app'@'%';

GRANT SELECT, INSERT
ON inmobiliaria_db.registro_pagos
TO 'contador_app'@'%';

GRANT SELECT
ON inmobiliaria_db.auditoria_propiedades
TO 'contador_app'@'%';

FLUSH PRIVILEGES;
