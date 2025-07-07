/*
3. Procedimiento.
Actualizar precio de un producto y líneas de pedido no enviadas. (3,5 puntos)
Incluya su solución en el fichero 3.solucionProcedimiento.sql.

Cree un procedimiento que permita actualizar el precio de un producto dado
y que modifique los precios de las líneas de pedido asociadas al producto dado
solo en aquellos pedidos que aún no hayan sido enviados. (1,5 puntos)

Asegure que el nuevo precio no sea un 50% menor que el precio actual
y lance excepción si se da el caso con el siguiente mensaje: (1 punto) No se permite rebajar el precio más del 50%.

Garantice que o bien se realizan todas las operaciones o bien no se realice ninguna. (1 punto)
*/
DELIMITER //

DROP PROCEDURE if EXISTS actualizar_precio_producto;

CREATE PROCEDURE actualizar_precio_producto(
	IN p_id INT,
	IN p_precio DECIMAL(10, 2)
)
BEGIN
	DECLARE v_precio_actual DECIMAL(10,2);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
	   ROLLBACK;
	   -- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al actualizar precio';
	END;

	
	START TRANSACTION;
		SELECT pr.precio INTO v_precio_actual
		FROM productos pr WHERE pr.id=p_id;
		
		IF p_precio < v_precio_actual/2 THEN
      	SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite rebajar el precio más del 50%.';
  	   END IF;
	
	
		UPDATE productos pr
		SET pr.precio=p_precio
		WHERE pr.id=p_id;
		
		UPDATE lineaspedido lp
		JOIN pedidos p ON p.id=lp.pedidoId
		SET lp.precio = p_precio
		WHERE lp.productoId=p_id AND (p.fechaRealizacion < p.fechaEnvio OR ISNULL(p.fechaRealizacion));
	COMMIT;
END //
DELIMITER ;
		
		
		
	





