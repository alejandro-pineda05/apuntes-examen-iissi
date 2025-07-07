/*
3. Procedimiento. 3,5 puntos Incluya su solución en el fichero 3.solucionProcedimiento.sql.
Cree un procedimiento que permita crear un nuevo producto con posibilidad de que sea para regalo.

Si el producto está destinado a regalo se creará un pedido con ese producto y costes 0€ para el cliente más antiguo. (1,5 puntos)

Asegure que el precio del producto para regalo no debe superar los 50 euros
y lance excepción si se da el caso con el siguiente mensaje: (1 punto)
No se permite crear un producto para regalo de más de 50€.

Garantice que o bien se realizan todas las operaciones o bien no se realice ninguna. (1 punto)
*/

DELIMITER //
DROP PROCEDURE if EXISTS crear_producto_posibilidad_regalo;

CREATE PROCEDURE crear_producto_posibilidad_regalo(
	IN p_nombre VARCHAR(100),
	IN p_descripcion VARCHAR(255),
	IN p_precio DECIMAL(10,2),
	IN p_tipoProductoId INT,
	IN p_puedeVenderseAMenores BOOLEAN,
	IN p_esRegalo BOOLEAN
)
BEGIN
	DECLARE v_id_cliente_mas_antiguo INT;
	DECLARE v_direccion_cliente_mas_antiguo VARCHAR(100);
	DECLARE v_productoId INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error inesperado al crear el producto o pedido.';
	END;
	
	START TRANSACTION;
		INSERT INTO productos(nombre, descripcion, precio, tipoProductoId, puedeVenderseAMenores)
		VALUES (p_nombre, p_descripcion, p_precio, p_tipoProductoId, p_puedeVenderseAMenores);
		
		SET v_productoId = LAST_INSERT_ID();
		
		IF (p_esRegalo) THEN
			IF (p_precio>50) THEN
				SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite un producto para regalo de mas de 50€';
			END IF;
			
			SELECT p.clienteId INTO v_id_cliente_mas_antiguo
			FROM pedidos p
			ORDER BY p.fechaRealizacion ASC
			LIMIT 1;
			
			SELECT c.direccionEnvio INTO v_direccion_cliente_mas_antiguo
			FROM clientes c
			WHERE c.id=v_id_cliente_mas_antiguo;
			
			INSERT INTO pedidos(fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId)
			VALUES (CURDATE(), NULL, v_direccion_cliente_mas_antiguo, 'Regalo', v_id_cliente_mas_antiguo, NULL);
			
			INSERT INTO lineaspedido(pedidoId, productoId, unidades, precio)
			VALUES (LAST_INSERT_ID(), v_productoId, 1, 0);
			
		END IF;
		
		
	COMMIT;
END //



CALL crear_producto_posibilidad_regalo('Regalo', 'A la mejor mamá', 15, 1, TRUE, FALSE);















