/*
2. Consultas SQL (DQL). (3 puntos)
Incluya su solución en el fichero 2.solucionConsultas.sql.


2.1. Devuelva el nombre del producto,
nombre del tipo de producto,
y precio unitario al que se vendieron los productos digitales (1 punto)


2.2. Consulta que devuelva el nombre del empleado,
el número de pedidos de más de 500 euros gestionados en este año
y el importe total de cada uno de ellos,
ordenados de mayor a menor importe gestionado.
Los empleados que no hayan gestionado ningún pedido,
también deben aparecer. (2 puntos)

*/
SELECT pr.nombre, tp.nombre, lp.precio
FROM productos pr
JOIN tiposproducto tp ON tp.id=pr.tipoProductoId
JOIN lineaspedido lp ON pr.id=lp.productoId
WHERE tp.nombre='Digitales'
GROUP BY pr.id, pr.nombre, tp.nombre;



SELECT u.nombre AS empleado,
       COUNT(filtrados.pedidoId) AS pedidos_gestionados,
       IFNULL(SUM(filtrados.total_pedido), 0) AS importe_total
FROM usuarios u
JOIN empleados e ON u.id = e.usuarioId
LEFT JOIN ( -- subconsulta de los pedidos que cumplen las restriccionees con su precio agrupados por empleados
    SELECT p.id AS pedidoId,
           p.empleadoId,
           SUM(lp.unidades * lp.precio) AS total_pedido
    FROM pedidos p
    JOIN lineaspedido lp ON p.id = lp.pedidoId
    WHERE YEAR(p.fechaRealizacion) = YEAR(CURDATE())
    GROUP BY p.id
    HAVING total_pedido > 500
) AS filtrados ON filtrados.empleadoId = e.id
GROUP BY e.id, u.nombre
ORDER BY importe_total DESC;




