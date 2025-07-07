/*
2. Trigger - Cantidad máxima de Pedidos
Diseña un trigger llamado limitar_cantidad_por_cliente
que imponga un límite dinámico en la cantidad total de unidades permitidas en un pedido. El límite dependerá del historial de compras del cliente:

Si el cliente tiene menos de 10 pedidos, el límite será fijo: 200 unidades por pedido.
Si el cliente tiene 10 o más pedidos, el límite será el doble de la media de unidades por pedido de ese cliente.
El trigger debe ejecutarse antes de insertar una nueva línea de pedido en la tabla LineasPedido.
Si la cantidad total de unidades del pedido supera el límite calculado para el cliente, se debe lanzar un error con un mensaje adecuado.

Inserte los datos que considere adecuados para probar que el trigger se comporta adecuadamente.
*/

DELIMITER //

DROP TRIGGER IF EXISTS limitar_cantidad_por_cliente;

CREATE TRIGGER limitar_cantidad_por_cliente BEFORE INSERT ON lineaspedido
FOR EACH ROW -- por cada fila que sea insertada, actualizada o eliminada
BEGIN 
   DECLARE v_limite_unidades_pedido INT DEFAULT NULL;
   DECLARE v_pedidos_cliente INT DEFAULT 0;
   DECLARE v_cliente_id INT DEFAULT NULL;
   DECLARE v_suma_unidades_por_pedido INT DEFAULT 0; -- primero sumo y luego divido para la media
   DECLARE v_num_pedidos_distintos INT DEFAULT 0; -- if antes de dividir por 0 por favor
   DECLARE v_media_unidades_por_pedido FLOAT DEFAULT 0;
   DECLARE v_cantidad_unidades_pedido INT DEFAULT 0;
   
   SELECT p.clienteId INTO v_cliente_id
   FROM pedidos p
   WHERE p.id=NEW.pedidoId;
   
   SELECT SUM(lp.unidades) INTO v_cantidad_unidades_pedido
   FROM lineaspedido lp
   WHERE lp.pedidoId = NEW.pedidoId;
   
   SELECT IFNULL(SUM(lp.unidades), 0) INTO v_cantidad_unidades_pedido
	FROM lineaspedido lp
	WHERE lp.pedidoId = NEW.pedidoId;
	
	SET v_cantidad_unidades_pedido = v_cantidad_unidades_pedido + NEW.unidades; -- se le suman las unidades nuevas

   
   SELECT COUNT(p.id) AS num_pedidos INTO v_pedidos_cliente
   FROM pedidos p
   WHERE p.clienteId = v_cliente_id;
   
   IF v_pedidos_cliente < 10 THEN
   	SET v_limite_unidades_pedido = 200;
   
   ELSEIF v_pedidos_cliente >= 10 THEN
		   SELECT SUM(lp.unidades) INTO v_suma_unidades_por_pedido
		   FROM lineaspedido lp
		   JOIN pedidos p ON lp.pedidoId=p.id
		   WHERE p.clienteId=v_cliente_id;
		   
		   SELECT COUNT(p.id) INTO v_num_pedidos_distintos
		   FROM pedidos p
		   WHERE p.clienteId=v_cliente_id;
		   
		   IF v_num_pedidos_distintos=0 THEN
		   	SIGNAL SQLSTATE '45000'
	      	SET MESSAGE_TEXT = 'Error de cálculo';
	      ELSE
				SET v_media_unidades_por_pedido = v_suma_unidades_por_pedido / v_num_pedidos_distintos;
			END IF;
			
			SET v_limite_unidades_pedido = 2 * FLOOR(v_media_unidades_por_pedido);
	END IF;
	
	IF v_cantidad_unidades_pedido > v_limite_unidades_pedido THEN
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'La cantidad total de unidades del pedido supera el límite calculado para el cliente';
   END IF;
   
END //

DELIMITER ;
   
   

