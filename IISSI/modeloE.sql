DROP TABLE IF EXISTS devoluciones;

CREATE TABLE devoluciones(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	lineaPedidoId INT NOT NULL,
	fechaDevolucion DATE NOT NULL,
	motivo TEXT NOT NULL,
	estado ENUM('Pendiente', 'Aceptada', 'Rechazada'),
	FOREIGN KEY (lineaPedidoId) REFERENCES lineaspedido(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);

/*
Identificador (PK)
Línea de pedido (FK)
Fecha de devolución
Motivo de la devolución (texto)
Estado de la devolución (Pendiente, Aceptada, Rechazada) - tipo ENUM o VARCHAR con restricción
*/



/* Devuelva el nombre del producto,
el nombre del tipo de producto
y el precio unitario con el que se vendieron los productos cuyo precio fue mayor a 100 euros. (1 punto)
*/
SELECT productos.nombre, tiposproducto.nombre, lineaspedido.precio
FROM productos
JOIN tiposproducto ON tiposproducto.id = productos.tipoProductoId
JOIN lineaspedido ON lineaspedido.productoId = productos.id
WHERE lineaspedido.precio > 100
GROUP BY productos.nombre;


/*
2.2. Devuelva el nombre del empleado,
el número de pedidos gestionados en los últimos 6 meses con importe total superior a 1000 euros,
y el importe total gestionado por empleado.
Incluya también empleados que no hayan gestionado pedidos.
Ordene por importe total gestionado descendente. (2 puntos)
*/
/*
SELECT u.nombre AS empleado, COUNT(lp.pedidoId) AS numero_pedidos, SUM(lp.unidades * lp.precio) AS importe_total
FROM usuarios u
JOIN empleados e ON u.id=e.usuarioId
JOIN pedidos p ON e.id=p.empleadoId
JOIN lineaspedido lp ON p.id=lp.pedidoId
WHERE DATEDIFF(CURDATE(), p.fechaRealizacion) <= 180 -- 180 dias son 6 meses
GROUP BY empleado
HAVING importe_total > 1000
ORDER BY importe_total DESC;
*/

SELECT u.nombre AS empleado,
       COUNT(DISTINCT p.id) AS numero_pedidos,
       IFNULL(SUM(lp.unidades * lp.precio), 0) AS importe_total
FROM empleados e
LEFT JOIN usuarios u ON u.id = e.usuarioId
LEFT JOIN pedidos p ON p.empleadoId = e.id
LEFT JOIN (
    SELECT pedidoId, SUM(unidades * precio) AS total_pedido
    FROM lineaspedido
    GROUP BY pedidoId
    HAVING total_pedido > 1000
) pedidos_filtrados ON pedidos_filtrados.pedidoId = p.id
LEFT JOIN lineaspedido lp ON lp.pedidoId = p.id
WHERE p.fechaRealizacion >= CURDATE() - INTERVAL 6 MONTH OR p.fechaRealizacion IS NULL
GROUP BY e.id
ORDER BY importe_total DESC;




/*
3. Procedimiento. Actualizar precio y líneas pendientes. (3,5 puntos)
Incluya su solución en el fichero 3.solucionProcedimiento.sql.

Cree un procedimiento que permita actualizar el precio de un producto dado
y que modifique el precio en las líneas de pedido asociadas a ese producto solo en aquellos pedidos que aún no hayan sido enviados (fechaEnvio IS NULL).

Asegure que el nuevo precio no sea inferior al 70% del precio actual.
En caso contrario, lance una excepción con el mensaje:
La reducción de precio supera el 30% permitida.
Garantice que las operaciones se realicen de forma atómica (transacción).
*/
DELIMITER //
DROP PROCEDURE IF EXISTS actualizar_precio;
CREATE PROCEDURE actualizar_precio(
	IN p_productoId INT,
	IN p_nuevo_precio DECIMAL(10,2)
)
BEGIN
	DECLARE v_precio_actual DECIMAL(10,2);
	START TRANSACTION;
		SELECT pr.precio INTO v_precio_actual
		FROM productos pr
		WHERE pr.id=p_productoId;
	
		IF p_nuevo_precio < 0.7*v_precio_actual THEN
			ROLLBACK;
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La reducción de precio supera el 30% permitida.';
		END IF;
	
		UPDATE productos pr
		SET pr.precio = p_nuevo_precio
		WHERE pr.id=p_productoId;
		
		UPDATE lineaspedido lp
		JOIN pedidos p ON lp.pedidoId=p.id
		SET lp.precio = p_nuevo_precio
		WHERE lp.productoId = p_productoId AND p.fechaEnvio IS NULL;
		
	COMMIT;
END //
DELIMITER ;



/*
4. Trigger. (2 puntos)
Incluya su solución en el fichero 4.solucionTrigger.sql.

Cree un trigger llamado t_no_mezclar_tipos_productos_en_pedido
que impida que un mismo pedido incluya productos de más de un tipo
(es decir, todos los productos de un pedido deben pertenecer al mismo tipoProductoId).
Lance error si se intenta insertar una línea que viola esta regla

*/
DELIMITER //
DROP TRIGGER IF EXISTS t_no_mezclar_tipos_productos_en_pedido;
CREATE TRIGGER t_no_mezclar_tipos_productos_en_pedido
BEFORE INSERT ON lineaspedido
FOR EACH ROW
BEGIN
	DECLARE v_id_tipo_producto_nuevo INT;
	DECLARE v_id_tipo_producto_distinto_en_mi_pedido INT;
	
	SELECT pr.tipoProductoId INTO v_id_tipo_producto_nuevo
	FROM productos pr
	WHERE pr.id=NEW.productoId;
	
	SELECT pr.tipoProductoId INTO v_id_tipo_producto_distinto_en_mi_pedido
	FROM pedidos p
	JOIN lineaspedido lp ON p.id = lp.pedidoId
	JOIN productos pr ON pr.id=lp.productoId
	WHERE p.id=NEW.pedidoId AND pr.tipoProductoId !=v_id_tipo_producto_nuevo
	LIMIT 1;
	
	IF v_id_tipo_producto_distinto_en_mi_pedido IS NOT NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'todos los productos de un pedido deben pertenecer al mismo tipoProductoId';
	END IF;

END //
DELIMITER ;





/*
5. Función. (2 puntos)
Incluya su solución en el fichero 5.solucionFuncion.sql.

Cree una función llamada f_total_cliente que reciba el clienteId y devuelva la suma total de dinero gastado en pedidos enviados
(es decir, solo aquellos pedidos con fechaEnvio no nulo), considerando el precio y las unidades de las líneas de pedido asociadas.

*/

DELIMITER //
DROP FUNCTION IF EXISTS f_total_cliente;
CREATE FUNCTION f_total_cliente(f_clienteId INT)
RETURNS DECIMAL(10, 2)
BEGIN 
	DECLARE v_dinero_gastado DECIMAL(10, 2);
	DECLARE v_existe BOOLEAN;
	-- La parte de ver si existe no creo que sea necesaria en el examen, pero bueno, aquí está
	SELECT EXISTS (
	SELECT * FROM clientes c
	WHERE c.id=f_clienteId) INTO v_existe;

	IF v_existe=FALSE THEN
     SIGNAL SQLSTATE '45000'
     SET MESSAGE_TEXT = 'No existe el cliente pasado como parámetro';
   END IF;
	
	SELECT IFNULL(SUM(lp.unidades * lp.precio), 0) INTO v_dinero_gastado
	FROM lineaspedido lp
	JOIN pedidos p ON p.id=lp.pedidoId
	WHERE p.clienteId=f_clienteId AND p.fechaEnvio IS NOT NULL;
	
	
	RETURN v_dinero_gastado;
	
END //
DELIMITER ;

SELECT f_total_cliente(2);


















