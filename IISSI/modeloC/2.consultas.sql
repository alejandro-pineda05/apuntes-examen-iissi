/*
2. Consultas SQL (DQL). 3 puntos
Incluya su solución en el fichero 2.solucionConsultas.sql.

2.1. Devuelva el nombre del producto,
el precio unitario y
las unidades compradas para las 5 líneas de pedido con más unidades. (1 punto)


2.3. Devuelva el nombre del empleado,
la fecha de realización del pedido,
el precio total del pedido
y las unidades totales del pedido para todos los pedidos que de más 7 días de antigüedad desde que se realizaron.
Si un pedido no tiene asignado empleado, también debe aparecer en el listado devuelto. (2 puntos)
*/

-- 2.1
SELECT pr.nombre, lp.precio AS precio_unitario, SUM(lp.unidades) AS unidades_compradas
FROM lineaspedido lp
JOIN productos pr ON pr.id=lp.productoId
GROUP BY lp.id
ORDER BY unidades_compradas DESC
LIMIT 5;

-- 2.2
SELECT u.nombre AS nombre_empleado, p.fechaRealizacion, SUM(lp.unidades * lp.precio) AS precio_total, SUM(lp.unidades) AS unidades_totales
FROM lineaspedido lp
JOIN pedidos p ON p.id = lp.pedidoId
LEFT JOIN empleados e ON e.id=p.empleadoId
LEFT JOIN usuarios u ON u.id=e.usuarioId
WHERE DATEDIFF(CURDATE(), p.fechaRealizacion) > 7
GROUP BY p.id, u.nombre, p.fechaRealizacion




