SELECT  per.nombre  AS nombre_vendedor,
        per.apellido,
        COUNT(c.id_contrato) AS total_propiedades_vendidas
FROM contratos c
JOIN tipos_contrato tc
      ON tc.id_tipo_contrato = c.id_tipo_contrato
JOIN agentes_inmobiliarios a
      ON a.id_agente = c.agente_id
JOIN personas per
      ON per.id_persona = a.id_agente
WHERE tc.nombre = 'Venta'
GROUP BY per.id_persona, per.nombre, per.apellido
ORDER BY total_propiedades_vendidas DESC;

SELECT  p.id_propiedad,
        p.direccion,
        c.id_contrato,
        c.valor AS valor_venta
FROM contratos c
JOIN tipos_contrato tc
      ON tc.id_tipo_contrato = c.id_tipo_contrato
JOIN propiedades p
      ON p.id_propiedad = c.propiedad_id
WHERE tc.nombre = 'Venta'
  AND c.valor BETWEEN 150000000 AND 400000000
ORDER BY c.valor;

SELECT  cli.id_cliente,
        per.nombre,
        per.apellido
FROM clientes cli
JOIN personas per
      ON per.id_persona = cli.id_cliente
WHERE per.nombre LIKE '%Carlos%';

SELECT  per.nombre  AS nombre_vendedor,
        per.apellido,
        p.id_propiedad,
        p.direccion,
        c.id_contrato,
        c.valor       AS valor_venta
FROM contratos c
RIGHT JOIN agentes_inmobiliarios a
       ON c.agente_id = a.id_agente
RIGHT JOIN personas per
       ON per.id_persona = a.id_agente
LEFT JOIN tipos_contrato tc
       ON tc.id_tipo_contrato = c.id_tipo_contrato
LEFT JOIN propiedades p
       ON p.id_propiedad = c.propiedad_id
WHERE tc.nombre = 'Venta' OR tc.nombre IS NULL
ORDER BY per.id_persona, c.id_contrato;

CREATE OR REPLACE VIEW vista_resumen_ventas AS
SELECT  a.id_agente,
        per.nombre  AS nombre_vendedor,
        per.apellido,
        IFNULL(SUM(CASE WHEN tc.nombre = 'Venta' THEN c.valor END), 0)              AS total_vendido,
        IFNULL(COUNT(DISTINCT CASE WHEN tc.nombre = 'Venta' THEN c.cliente_id END), 0) AS numero_clientes_atendidos
FROM agentes_inmobiliarios a
JOIN personas per
      ON per.id_persona = a.id_agente
LEFT JOIN contratos c
      ON c.agente_id = a.id_agente
LEFT JOIN tipos_contrato tc
      ON tc.id_tipo_contrato = c.id_tipo_contrato
GROUP BY a.id_agente, per.nombre, per.apellido;
