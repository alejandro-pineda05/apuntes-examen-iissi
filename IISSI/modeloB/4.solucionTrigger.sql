/*
Cree un trigger llamado t_limitar_importe_pedidos_de_menores que impida que
 a partir de ahora, los pedidos realizados por menores superen los 500€.
*/

DELIMITER //
DROP TRIGGER IF EXISTS t_limitar_importe_pedidos_de_menores;
CREATE TRIGGER t_limitar_importe_pedidos_de_menores
BEFORE INSERT ON lineaspedido
FOR EACH ROW
BEGIN
	DECLARE v_edad_cliente INT;
	SELECT (YEAR(CURDATE()) - YEAR(c.fechaNacimiento)) INTO v_edad_cliente
	FROM pedidos p
	JOIN clientes c ON c.id=p.clienteId
	WHERE NEW.pedidoId=p.id;
	
	IF (v_edad_cliente < 18 AND (NEW.precio * NEW.unidades) > 500) THEN
		SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Los pedidos realizados por menores no pueden superar los 500€.';
   END IF;
END //
DELIMITER ;