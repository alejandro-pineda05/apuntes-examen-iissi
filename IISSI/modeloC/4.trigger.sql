/*
4. Trigger. 2 puntos
Incluya su solución en el fichero 4.solucionTrigger.sql.

Cree un trigger llamado p_limitar_unidades_mensuales_de_productos_fisicos que,
a partir de este momento, impida la venta de más de 1000 unidades al mes de cualquier producto físico.
*/

DELIMITER //
DROP TRIGGER IF EXISTS p_limitar_unidades_mensuales_de_productos_fisicos;

CREATE TRIGGER p_limitar_unidades_mensuales_de_productos_fisicos
BEFORE INSERT ON lineaspedido
FOR EACH ROW
BEGIN
	DECLARE v_unidades_vendidas_este_mes_prod_fisicos INT;
	
	SELECT IFNULL(SUM(lp.unidades),0) INTO v_unidades_vendidas_este_mes_prod_fisicos
	FROM lineaspedido lp
	JOIN productos pr ON pr.id=lp.productoId
	JOIN pedidos p ON p.id=lp.pedidoId
	WHERE pr.nombre='Físicos' AND p.id=NEW.pedidoId AND MONTH(p.fechaRealizacion) = MONTH(CURDATE()) AND YEAR(p.fechaRealizacion)=YEAR(CURDATE());
	
	SET v_unidades_vendidas_este_mes_prod_fisicos = v_unidades_vendidas_este_mes_prod_fisicos + NEW.unidades; -- sumo la actual
	
	IF v_unidades_vendidas_este_mes_prod_fisicos > 1000 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se pueden vender más de 1000 unidades mensuales de un producto físico.';
	END IF;

END //
DELIMITER ;