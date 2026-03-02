USE Inmobiliaria;

CREATE USER IF NOT EXISTS 'admin_app'@'localhost' IDENTIFIED BY 'AdminPass!';
CREATE USER IF NOT EXISTS 'agente_app'@'localhost' IDENTIFIED BY 'AgentePass!';
CREATE USER IF NOT EXISTS 'contador_app'@'localhost' IDENTIFIED BY 'ContadorPass!';

GRANT ALL PRIVILEGES
ON Inmobiliaria.*
TO 'admin_app'@'localhost';

GRANT SELECT, INSERT, UPDATE
ON Inmobiliaria.propiedades
TO 'agente_app'@'localhost';

GRANT SELECT, INSERT
ON Inmobiliaria.contratos
TO 'agente_app'@'localhost';

GRANT SELECT, INSERT, UPDATE
ON Inmobiliaria.registro_pagos
TO 'contador_app'@'localhost';

GRANT SELECT
ON Inmobiliaria.*
TO 'contador_app'@'localhost';

FLUSH PRIVILEGES;
