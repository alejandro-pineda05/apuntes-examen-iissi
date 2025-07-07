/*
4. Trigger. 2 puntos. Incluya su solución en el fichero 4.solucionTrigger.sql.

Cree un trigger llamado t_asegurar_mismo_tipo_producto_en_pedidos
que impida que, a partir de ahora,
un mismo pedido incluya productos físicos y digitales.
*/
DELIMITER //
DROP TRIGGER IF EXISTS t_asegurar_mismo_tipo_producto_en_pedidos;
CREATE TRIGGER t_asegurar_mismo_tipo_producto_en_pedidos
BEFORE INSERT ON lineaspedido
FOR EACH ROW
BEGIN
	DECLARE v_tipo_producto_id_actual INT;
	DECLARE v_tipo_producto_id_existente INT;
		SELECT pr.tipoProductoId INTO v_tipo_producto_id_actual
		FROM productos pr
		WHERE pr.id=NEW.productoId;
		
		SELECT pr.tipoProductoId INTO v_tipo_producto_id_existente
		FROM lineaspedido lp
		JOIN productos pr ON pr.id=lp.productoId
		WHERE lp.pedidoId = NEW.pedidoId AND pr.tipoProductoId != v_tipo_producto_id_actual
		LIMIT 1;
		
		IF v_tipo_producto_id_existente IS NOT NULL THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Un mismo pedido incluye distintos tipos de producto';
		END IF;
END //
DELIMITER ;	

-- Probar el trigger 
INSERT INTO lineaspedido(pedidoId, productoId, unidades, precio) VALUES (1, 5, 1, 15);



















DELIMITER //

DROP TRIGGER IF EXISTS t_asegurar_mismo_tipo_producto_en_pedidos //

CREATE TRIGGER t_asegurar_mismo_tipo_producto_en_pedidos
BEFORE INSERT ON lineaspedido
FOR EACH ROW
BEGIN
    DECLARE v_nuevo_tipo INT;
    DECLARE v_tipo_existente INT;

    -- Obtener el tipo de producto del nuevo producto que se va a insertar
    SELECT tipoProductoId INTO v_nuevo_tipo
    FROM productos
    WHERE id = NEW.productoId;

    -- Verificar si ya hay líneas en el pedido con un tipo de producto distinto
    SELECT tipoProductoId INTO v_tipo_existente
    FROM lineaspedido lp
    JOIN productos pr ON lp.productoId = pr.id
    WHERE lp.pedidoId = NEW.pedidoId
      AND pr.tipoProductoId != v_nuevo_tipo
    LIMIT 1;

    -- Si se encontró un producto de tipo diferente, lanzamos un error
    IF v_tipo_existente IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede mezclar productos físicos y digitales en el mismo pedido.';
    END IF;
END //

DELIMITER ;

	