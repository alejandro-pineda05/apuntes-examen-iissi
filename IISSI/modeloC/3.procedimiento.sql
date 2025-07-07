/*
3. Procedimiento. Bonificar pedido retrasado. 3,5 puntos
Incluya su solución en el fichero 3.solucionProcedimiento.sql.

Cree un procedimiento que permita bonificar un pedido que se ha retrasado debido a la mala gestión del empleado a cargo.
Recibirá un identificador de pedido, asignará a otro empleado como gestor
y reducirá un 20% el precio unitario de cada línea de pedido asociada a ese pedido.
(1,5 puntos)

Asegure que el pedido estaba asociado a un empleado
y en caso contrario lance excepción con el siguiente mensaje: (1 punto) El pedido no tiene gestor.

Garantice que o bien se realizan todas las operaciones o bien no se realice ninguna. (1 punto)
*/

DELIMITER //
DROP PROCEDURE IF EXISTS bonificar_pedido_retrasado;

CREATE PROCEDURE bonificar_pedido_retrasado(
	IN p_pedidoId INT	
)
BEGIN
	DECLARE v_id_nuevo_empleado_asigando INT;
	DECLARE v_id_empleado_antiguo INT DEFAULT NULL;
	
	SELECT p.empleadoId INTO v_id_empleado_antiguo
	FROM pedidos p
	WHERE p.id=p_pedidoId;
	
	SELECT e.id INTO v_id_nuevo_empleado_asigando
	FROM empleados e
	JOIN pedidos p ON e.id=p.empleadoId
	WHERE e.id != p_pedidoId
	LIMIT 1;
	
	SELECT 
	START TRANSACTION;
	IF (ISNULL(v_id_empleado_antiguo)) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido no tiene gestor.';
	END IF;
	
	UPDATE lineaspedido lp
		SET lp.precio = lp.precio - (lp.precio*0.20)
		WHERE lp.pedidoId=p_pedidoId;
		
	UPDATE pedidos p
		SET p.empleadoId = v_id_nuevo_empleado_asigando
		WHERE p.id = p_pedidoId;
	
	
	COMMIT;
END //
DELIMITER ;