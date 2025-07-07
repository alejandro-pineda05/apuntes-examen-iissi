/*
Lab4: Data Query Language
Partiendo de la base de datos tiendaOnline e insertando datos, diseñe las consultas SQL que respondan a los siguientes ejercicios.

1. Consultas básicas de selección
Lista todos los usuarios en la tabla `Usuarios`, mostrando solo sus nombres y correos electrónicos.
*/
SELECT nombre, email FROM usuarios;
-- SELECT * FROM usuarios; si lo quisiera mostrar todo

/*
Muestra los empleados con su salario y el nombre correspondiente en la tabla `Usuarios`.
*/
SELECT e.salario, u.nombre
FROM empleados AS e
JOIN usuarios AS u
ON e.usuarioId=u.id;
-- ORDER BY e.salario DESC; para que se ordenen de mayor a menor salario

/*
Obtén los productos de la tabla `Productos` que tienen un precio mayor o igual a 20.00.
*/
SELECT * FROM productos AS p WHERE p.precio >= 20;-- ORDER BY p.precio; 


/*
Lista los clientes con su dirección de envío, código postal y fecha de nacimiento.
*/
SELECT c.direccionEnvio, c.codigoPostal, c.fechaNacimiento FROM clientes AS c;



/*
2. Consultas con condiciones específicas y funciones agregadas
Encuentra el salario promedio de los empleados.
*/
SELECT AVG(e.salario) AS salario_promedio FROM empleados AS e;


/*
Obtén el número total de productos agrupados por tipo de producto.
*/
SELECT tp.nombre AS tipo_producto, COUNT(p.id) AS numero_productos
FROM productos AS p JOIN tiposproducto AS tp
ON p.tipoProductoId=tp.id
GROUP BY tp.nombre; -- IMPORTANTE ESTO ÚLTIMO PARA CUANDO USE UNA FUNCION COMO COUNT( )

/*
Lista los pedidos realizados por cada cliente con su nombre y la fecha de realización.
*/
SELECT u.nombre AS nombre_cliente, p.fechaRealizacion AS fecha_realizacion
FROM pedidos AS p
JOIN clientes AS c ON p.clienteId = c.id -- relaciona cada pedido con el cliente que lo hizo.
JOIN usuarios AS u ON c.usuarioId = u.id; -- permite obtener el nombre del cliente desde la tabla usuarios.

/*
Cliente que ha pedido la menor variedad de productos.
*/
SELECT u.nombre AS cliente, COUNT(DISTINCT lp.productoId) AS numero_productos_distintos  
FROM clientes AS c
JOIN pedidos AS p ON c.id = p.clienteId
JOIN lineaspedido AS lp ON p.id = lp.pedidoId
JOIN usuarios AS u ON c.usuarioId = u.id
GROUP BY c.id, u.nombre;
ORDER BY numero_productos_distintos ASC
LIMIT 1;

/*
3. Consultas con JOIN y filtrado avanzado
Encuentra los pedidos realizados por clientes mayores de edad (18 años o más).
*/
SELECT p.* FROM pedidos p
JOIN clientes c ON p.clienteId=c.id 
WHERE TIMESTAMPDIFF(YEAR, c.fechaNacimiento, p.fechaRealizacion) >= 18;



/*
Encuentra los productos que no han sido pedidos por ningún cliente menor de 18 años.
*/
SELECT pr.*
FROM productos pr
WHERE pr.id NOT IN(
	SELECT lp.productoId FROM lineaspedido lp
	JOIN pedidos p ON p.id = lp.pedidoId
	JOIN clientes c ON p.clienteId=c.id 
	WHERE TIMESTAMPDIFF(YEAR, c.fechaNacimiento, p.fechaRealizacion) < 18
);

/*
Muestra los pedidos y las líneas de pedido asociadas, incluyendo el nombre del producto y las unidades solicitadas.
*/
SELECT p.id, lp.unidades, pr.nombre
FROM pedidos p JOIN lineaspedido lp ON lp.pedidoId = p.id
JOIN productos pr ON pr.id = lp.productoId;

/*
Lista los productos no permitidos para menores (`puedeVenderseAMenores = FALSE`) y sus precios.
*/
SELECT pr.nombre, pr.precio
FROM productos pr
WHERE pr.puedeVenderseAMenores = FALSE; 

/*
Lista los clientes cuya mayoría de productos pedidos (en cantidad total de unidades) son aquellos no permitidos para menores de 18 años.
*/
SELECT c.id, SUM(CASE WHEN pr.puedeVenderseAMenores = FALSE THEN lp.unidades ELSE 0 END) AS unidades_no_menores, SUM(lp.unidades) AS unidades_totales
FROM clientes c
JOIN pedidos p ON c.id = p.clienteId
JOIN lineaspedido lp ON lp.pedidoId = p.id
JOIN productos pr ON pr.id = lp.productoId
GROUP BY c.id
HAVING unidades_no_menores > unidades_totales / 2;

-- esto es un if: CASE WHEN pr.puedeVenderseAMenores = FALSE THEN lp.unidades ELSE 0 END
-- if (pr.puedeVenderseAMenores = FALSE) unidades_no_menores += lp. unidades
-- else unidades_no_menores += 0



/*
4. Consultas con subconsultas y cálculos
Encuentra el cliente con el mayor número de pedidos.
*/
SELECT u.nombre, SUM(lp.unidades) AS numero_pedidos
FROM usuarios u
JOIN clientes c ON c.usuarioId = u.id
JOIN pedidos p ON p.clienteId = c.id
JOIN lineaspedido lp ON lp.pedidoId = p.id
GROUP BY c.id
ORDER BY numero_pedidos DESC
LIMIT 1;


/*
Muestra los pedidos con un total calculado de precio para cada pedido (sumando `precio * unidades` de `LineasPedido`).
*/
SELECT p.id, SUM(lp.unidades * lp.precio) AS precio_total_pedido
FROM pedidos p
JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY p.id;


SELECT SUM(lp.unidades * lp.precio) AS precio_total_pedido
FROM pedidos p
JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY p.id
ORDER BY precio_total_pedido DESC
LIMIT 1






/*
Muestra los pedidos cuyo importe sea el máximo. Si hay más de un pedido con el mismo importe máximo, devolverlos todos.
*/
SELECT
	p.id,
	SUM(lp.unidades * lp.precio) AS importe_pedido,
	(SELECT MAX(t.total)
		FROM (SELECT SUM(lp2.unidades * lp2.precio) AS total
				FROM pedidos p2 JOIN lineaspedido lp2 ON p2.id = lp2.pedidoId
				GROUP BY p2.id	
		) AS t
	) AS importe_maximo
FROM pedidos p
JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY p.id
HAVING importe_pedido = importe_maximo;

/*
Lista los productos que no se han vendido.
*/
-- hecho a mi manera. Funciona pero no es lo que se pide:
SELECT pr.nombre
FROM productos pr
WHERE pr.id NOT IN (
	SELECT pr2.id
	FROM productos pr2
	JOIN lineaspedido lp2 ON lp2.productoId = pr2.id
);

-- Como hay que hacerlo
SELECT pr.nombre
FROM productos pr
LEFT JOIN lineaspedido lp ON pr.id = lp.productoId -- une la tabla de la izquierda (productos) con la de la derecha (lineaspedido)
WHERE lp.productoId IS NULL; -- entonces los productos que se quedan como null porque no tienen asignados pedidos son con los que nos quedamos
-- join normal devuelve solo las filas que coinciden en las tablas y left join pone todas las filas de la tabla de la izquierda y si no coinciden, rellena con null
-- (right join hace lo mismo pero con la tabla de la derecha)

/*
Ganancias mensuales obtenidas.
*/
-- Así está bien y es como viene en el solucionario
SELECT MONTH(p.fechaRealizacion) AS mes, SUM(lp.unidades * lp.precio) AS total_precio
FROM pedidos p JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY mes;


-- Pero si quiero tener en cuenta los años por si el mes no fuera del mismo año se haría asi:
SELECT 
  YEAR(p.fechaRealizacion) AS año,
  MONTH(p.fechaRealizacion) AS mes,
  SUM(lp.unidades * lp.precio) AS total_precio
FROM pedidos p 
JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY año, mes
ORDER BY año, mes;


/*
Empleado que ha gestionado más dinero en ventas.
*/
SELECT u.nombre AS Empleado, SUM(lp.precio * lp.unidades) AS dinero_gestionado
FROM usuarios u
JOIN empleados e ON e.usuarioId=u.id
JOIN pedidos p ON p.empleadoId = e.id
JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY u.nombre
ORDER BY dinero_gestionado DESC
LIMIT 1;

/*
Empleado que ha gestionado un total de más de 1000.00€ en ventas.
*/
SELECT u.nombre AS Empleado, SUM(lp.precio * lp.unidades) AS dinero_gestionado
FROM usuarios u
JOIN empleados e ON e.usuarioId=u.id
JOIN pedidos p ON p.empleadoId = e.id
JOIN lineaspedido lp ON p.id = lp.pedidoId
GROUP BY u.nombre
HAVING dinero_gestionado > 10000;


/*
5 pedidos con mayor importe de entre aquellos que tienen un importe menor al importe medio de todos los pedidos.
*/
SELECT SUM(lp.precio * lp.unidades) AS importe_pedido
FROM lineaspedido lp
JOIN pedidos p ON lp.pedidoId=p.id
GROUP BY p.id
HAVING importe_pedido < (
	SELECT AVG(sub.total)
	FROM (
			SELECT SUM(lp2.precio * lp2.unidades) AS total
			FROM lineaspedido lp2
			JOIN pedidos p2
			ON lp2.pedidoId=p2.id
			GROUP BY p2.id
	) AS sub)
ORDER BY importe_pedido DESC
LIMIT 5;



/*
Vista para facilitar la creación de consultas sobre importes de pedidos y empleados encargados.
*/

-- He puesto el LEFT JOIN para que salga null cuando un pedido no tiene asociado un empleado
-- pero en la version del profesor no lo ha hecho así, bastaría con quitar el LEFT
CREATE OR REPLACE VIEW v_importes_pedidos_extendida AS
SELECT p.id, SUM(lp.precio * lp.unidades) AS importe_pedido, u.nombre AS Empleado
FROM lineaspedido lp
JOIN pedidos p ON lp.pedidoId=p.id
LEFT JOIN empleados e ON p.empleadoId=e.id
LEFT JOIN usuarios u ON e.usuarioId=u.id
GROUP BY p.id;

SELECT importe_pedido, Empleado FROM v_importes_pedidos_extendida



/*
Clientes que han pedido en más de 3 meses distintos del último año uno de los 3 productos más vendidos de los últimos 5 años.
*/
-- Vista con los 3 productos más vendidos en los últimos 5 años
CREATE OR REPLACE VIEW v_top_3_productos_5y AS
SELECT pr.id AS producto_id
FROM productos pr
JOIN lineaspedido lp ON lp.productoId = pr.id
JOIN pedidos p ON p.id = lp.pedidoId
WHERE p.fechaRealizacion >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
GROUP BY pr.id
ORDER BY SUM(lp.unidades) DESC
LIMIT 3;

-- Consulta de clientes que han pedido uno de esos 3 productos en más de 3 meses distintos del último año
SELECT u.nombre
FROM usuarios u
JOIN clientes c ON c.usuarioId = u.id
JOIN pedidos p ON p.clienteId = c.id
JOIN lineaspedido lp ON lp.pedidoId = p.id
JOIN v_top_3_productos_5y top ON top.producto_id = lp.productoId
WHERE p.fechaRealizacion >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)
GROUP BY u.id, u.nombre
HAVING COUNT(DISTINCT DATE_FORMAT(p.fechaRealizacion, '%Y-%m')) > 3;




/*
Clientes que han pedido en al menos 3 meses distintos del último año 
uno de los 3 productos más vendidos de los últimos 5 años.
*/
-- SOLUCION DEL PROFESOR
SELECT c.id, u.nombre, c.fechaNacimiento, u.email
FROM clientes c
JOIN usuarios u ON c.usuarioId = u.id
JOIN pedidos p ON c.id = p.clienteId
JOIN lineaspedido lp ON p.id = lp.pedidoId
JOIN (
  SELECT lp.productoId
  FROM lineaspedido lp
  JOIN pedidos p ON lp.pedidoId = p.id
  WHERE p.fechaRealizacion >= DATE_SUB(CURDATE(), INTERVAL 5 YEAR)
  GROUP BY lp.productoId
  ORDER BY SUM(lp.unidades) DESC
  LIMIT 3
) AS top_productos ON lp.productoId = top_productos.productoId
WHERE p.fechaRealizacion >= DATE_FORMAT(CURDATE(), '%Y-01-01')
GROUP BY c.id
HAVING COUNT(DISTINCT DATE_FORMAT(p.fechaRealizacion, '%Y-%m')) >= 3;













