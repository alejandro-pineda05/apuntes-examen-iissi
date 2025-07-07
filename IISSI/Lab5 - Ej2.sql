/*
Diseña un trigger llamado limitar_cantidad_por_cliente que imponga un límite dinámico en la cantidad total de unidades permitidas en un pedido.
El límite dependerá del historial de compras del cliente:

Si el cliente tiene menos de 10 pedidos, el límite será fijo: 200 unidades por pedido.
Si el cliente tiene 10 o más pedidos, el límite será el doble de la media de unidades por pedido de ese cliente.
El trigger debe ejecutarse antes de insertar una nueva línea de pedido en la tabla LineasPedido.
Si la cantidad total de unidades del pedido supera el límite calculado para el cliente, se debe lanzar un error con un mensaje adecuado.

Inserte los datos que considere adecuados para probar que el trigger se comporta adecuadamente.
*/
-- Mi version
-- NO SE POR QUE DA ERROR CUANDO PONE CASI LO MISMO QUE EN EL DEL PROFESOR Y HE SEGUIDO LAS RECOMENDACIONES DE CHAT GPT

DELIMITER //

DROP TRIGGER IF EXISTS limitar_cantidad_por_cliente;
CREATE TRIGGER limitar_cantidad_por_cliente BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
	DECLARE v_clienteId INT DEFAULT NULL;
	DECLARE totalPedidos INT DEFAULT 0;
	DECLARE limiteUnidades INT DEFAULT 200;
	-- DECLARE totalPedidosCliente INT;
	DECLARE mediaUnidadesPorPedidoCliente DECIMAL(10,2) DEFAULT 0;
	DECLARE totalUnidadesDelPedido  INT DEFAULT 0; 
	DECLARE mensajeError VARCHAR(100);
	
	
	SELECT p.clienteId INTO v_clienteId
	FROM Pedidos p
	WHERE p.id=NEW.pedidoId;
	
	IF v_clienteId IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el cliente';
	END IF;
	

	SELECT COUNT(*) INTO totalPedidos
	FROM Pedidos p
	WHERE p.clienteId = v_clienteId;
	
	IF totalPedidos >= 10 THEN
		SELECT COALESCE(SUM(lp.unidades), 0) / COUNT(DISTINCT p.id) INTO mediaUnidadesPorPedidoCliente
      FROM Pedidos p
      LEFT JOIN LineasPedido lp ON p.id = lp.pedidoId
      WHERE p.clienteId = v_clienteId;

      IF mediaUnidadesPorPedidoCliente > 0 THEN
         SET limiteUnidades = FLOOR(mediaUnidadesPorPedidoCliente * 2);
      ELSE
         SET limiteUnidades = 200;
      END IF;
	
	
		-- el límite será el doble de la media de unidades por pedido de ese cliente.
		/*SELECT SUM(uni.unidades_por_pedido) INTO sumaUnidadesTotalesCliente
		FROM (SELECT p.id, SUM(lp.unidades) AS unidades_por_pedido
			FROM lineaspedido lp
			JOIN pedidos p ON p.id=lp.pedidoId
			JOIN clientes c ON c.id = p.clienteId
			WHERE c.id=v_clienteId
			GROUP BY p.id) AS uni;

		SELECT COUNT(*) INTO totalPedidosCliente
		FROM pedidos p
		WHERE p.clienteId = v_clienteId;
		
		SET mediaUnidadesPorPedidoCliente = sumaUnidadesTotalesCliente / totalPedidosCliente;
		IF mediaUnidadesPorPedidoCliente > 0 THEN 
			SET limiteUnidades = FLOOR(mediaUnidadesPorPedidoCliente * 2);
		ELSE
			SET limiteUnidades = 200;
		END IF;
		*/
			
	ELSE
		SET limiteUnidades = 200;
	END IF;
	
	
	SELECT SUM(lp.unidades) INTO totalUnidadesDelPedido
	FROM LineasPedido lp
	WHERE lp.pedidoId = NEW.pedidoId;
	
	-- Añadir las unidades nuevas
	SET totalUnidadesDelPedido  = COALESCE(totalUnidadesDelPedido , 0) + NEW.unidades;
	
	
	IF totalUnidadesDelPedido  = 0 THEN
		SET mensajeError = CONCAT('Error en cálculo: totalPedidos=', totalPedidos, 
                                  ', mediaUnidadesPorPedido=', CAST(mediaUnidadesPorPedidoCliente AS CHAR), 
                                  ', limiteUnidades=', CAST(limiteUnidades AS CHAR));
      SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = mensajeError;
      
   ELSEIF totalUnidadesDelPedido  > limiteUnidades
		SIGNAL SQLSTATE '45000'
      SET MESSAGE_TEXT = 'Se ha superado el limite de unidades permitidas para este cliente.';
   END IF;
   
END //
DELIMITER ;
      
	
	
	
		












-- Version profesor



DELIMITER //

CREATE OR REPLACE TRIGGER limitar_cantidad_por_cliente BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
   DECLARE clienteId INT DEFAULT NULL;
   DECLARE totalPedidos INT DEFAULT 0;
   DECLARE mediaUnidadesPorPedido DECIMAL(10, 2) DEFAULT 0.0;
   DECLARE limiteUnidades INT DEFAULT 200;
   DECLARE cantidadTotal INT DEFAULT 0;
   DECLARE mensajeError TEXT;

   -- Obtener el cliente asociado al pedido
   SELECT p.clienteId INTO clienteId
   FROM Pedidos p
   WHERE p.id = NEW.pedidoId;

   -- Validar si el cliente asociado al pedido existe
   IF clienteId IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El pedido no está asociado a un cliente válido.';
   END IF;

   -- Contar el número de pedidos realizados por el cliente
   SELECT COUNT(*) INTO totalPedidos
   FROM Pedidos
   WHERE clienteId = clienteId;

   -- Validar si el cliente tiene pedidos
   IF totalPedidos > 10 THEN
        -- Calcular la media de unidades por pedido del cliente usando LEFT JOIN
        SELECT COALESCE(SUM(lp.unidades), 0) / COUNT(p.id) INTO mediaUnidadesPorPedido
        FROM Pedidos p
        LEFT JOIN LineasPedido lp ON p.id = lp.pedidoId
        WHERE p.clienteId = clienteId;

        -- Establecer el límite de unidades (doble de la media si tiene 10 o más pedidos)
        IF mediaUnidadesPorPedido > 0 THEN
            SET limiteUnidades = FLOOR(mediaUnidadesPorPedido * 2);
        ELSE
            SET limiteUnidades = 200; -- Límite predeterminado si no hay líneas
        END IF;
    ELSE
        -- Si hay menos de 10 pedidos, el límite será el valor predeterminado
        SET limiteUnidades = 200;
    END IF;

    -- Sumar las unidades actuales del pedido
    SELECT SUM(unidades) INTO cantidadTotal
    FROM LineasPedido
    WHERE pedidoId = NEW.pedidoId;

    -- Incluir las unidades de la nueva línea
    SET cantidadTotal = COALESCE(cantidadTotal, 0) + NEW.unidades;

    -- Depuración: Usar una variable intermedia para el mensaje
    IF limiteUnidades = 0 THEN
        SET mensajeError = CONCAT('Error en cálculo: totalPedidos=', totalPedidos, 
                                  ', mediaUnidadesPorPedido=', CAST(mediaUnidadesPorPedido AS CHAR), 
                                  ', limiteUnidades=', CAST(limiteUnidades AS CHAR));
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = mensajeError;
    END IF;

    -- Verificar si la cantidad total supera el límite
    IF cantidadTotal > limiteUnidades THEN
        SET mensajeError = CONCAT('El pedido excede el límite de ', CAST(limiteUnidades AS CHAR), ' unidades permitidas para este cliente.');
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = mensajeError;
    END IF;
END //

DELIMITER ;




-- chat gpt

DELIMITER //

DROP TRIGGER IF EXISTS limitar_cantidad_por_cliente;

CREATE TRIGGER limitar_cantidad_por_cliente BEFORE INSERT ON LineasPedido
FOR EACH ROW
BEGIN
    DECLARE v_clienteId INT DEFAULT NULL;
    DECLARE totalPedidos INT DEFAULT 0;
    DECLARE limiteUnidades INT DEFAULT 200;
    DECLARE mediaUnidadesPorPedidoCliente DECIMAL(10,2) DEFAULT 0;
    DECLARE totalUnidadesDelPedido INT DEFAULT 0;
    DECLARE mensajeError VARCHAR(200);

    -- Obtener cliente
    SELECT clienteId INTO v_clienteId FROM Pedidos WHERE id = NEW.pedidoId;

    IF v_clienteId IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el cliente';
    END IF;

    -- Contar pedidos
    SELECT COUNT(*) INTO totalPedidos FROM Pedidos WHERE clienteId = v_clienteId;

    IF totalPedidos >= 10 THEN
        SELECT COALESCE(SUM(lp.unidades),0)/COUNT(DISTINCT p.id) INTO mediaUnidadesPorPedidoCliente
        FROM Pedidos p LEFT JOIN LineasPedido lp ON p.id = lp.pedidoId
        WHERE p.clienteId = v_clienteId;

        IF mediaUnidadesPorPedidoCliente > 0 THEN
            SET limiteUnidades = FLOOR(mediaUnidadesPorPedidoCliente * 2);
        END IF;
    END IF;

    -- Sumar unidades actuales + nueva línea
    SELECT COALESCE(SUM(unidades),0) INTO totalUnidadesDelPedido FROM LineasPedido WHERE pedidoId = NEW.pedidoId;
    SET totalUnidadesDelPedido = totalUnidadesDelPedido + NEW.unidades;

    -- Validar límite
    IF totalUnidadesDelPedido > limiteUnidades THEN
        SET mensajeError = CONCAT('Se ha superado el limite de unidades permitidas para este cliente: ', limiteUnidades);
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = mensajeError;
    END IF;

END //

DELIMITER ;

