/*
2. Consultas SQL (DQL). 3 puntos
Incluya su solución en el fichero 2.solucionConsultas.sql.


2.1. Devuelva el nombre del del empleado,
la fecha de realización del pedido
y el nombre del cliente de todos los pedidos realizados este mes. (1 puntos)


2.2. Devuelva el nombre,
las unidades totales pedidas
y el importe total gastado

de aquellos clientes que han realizado
más de 5 pedidos en el último año. (2 puntos
*/

SELECT ue.nombre AS nombre_empleado, p.fechaRealizacion, uc.nombre AS nombre_cliente
FROM pedidos p
JOIN empleados e ON e.id=p.empleadoId
JOIN usuarios ue ON ue.id=e.usuarioId
JOIN clientes c ON c.id=p.clienteId
JOIN usuarios uc ON uc.id=c.usuarioId
WHERE MONTH(p.fechaRealizacion) = MONTH(CURDATE()) AND YEAR(p.fechaRealizacion)=YEAR(CURDATE());




SELECT u.nombre,
	IFNULL(SUM(lp.unidades), 0) AS unidades_totales,
	IFNULL(SUM(lp.unidades * lp.precio), 0) AS importe_total
FROM clientes c
JOIN usuarios u ON u.id=c.usuarioId
JOIN pedidos p ON c.id=p.clienteId
JOIN lineaspedido lp ON p.id=lp.pedidoId
WHERE c.id IN (SELECT c2.id
	FROM clientes c2
	JOIN pedidos p2 ON c2.id=p2.clienteId
	WHERE YEAR(p2.fechaRealizacion) = YEAR(CURDATE())
	GROUP BY c2.id
	HAVING COUNT(p2.id) > 5
);



















