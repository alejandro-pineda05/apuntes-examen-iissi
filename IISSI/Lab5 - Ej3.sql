/*
3. Función - Índice de fidelidad de cliente
Implementa una función llamada calcular_fidelidad_cliente que calcule un índice de fidelidad para un cliente en función de su historial de compras y gasto total.
Este índice se puede utilizar para clasificar a los clientes en niveles de fidelidad y definir estrategias como promociones, descuentos o beneficios.
Inserte los datos que sean necesarios para probar que la función se comporta como se espera.

Fórmula del Índice de Fidelidad
La fidelidad del cliente se calculará según los siguientes factores:

Número de Pedidos:
Cada pedido aumenta la fidelidad en un peso de 0.5.
Gasto Total:
Cada euro gastado aumenta la fidelidad en un peso de 0.05.
El cálculo del índice es: Índice de fidelidad = (Número de pedidos * 0.5)+(Gasto Total * 0.05)

Reglas
Si el cliente no tiene pedidos, el índice de fidelidad será 0.
La función debe ser determinística y devolver el índice como un número decimal con dos decimales.
Implementación de la Función
Crea una función en SQL con las siguientes características:

Nombre de la función: calcular_fidelidad_cliente.
Parámetro de entrada: clienteId (el identificador único del cliente).
Valor de retorno: Un número decimal (DECIMAL(10, 2)) que representa el índice de fidelidad del cliente.
*/

DELIMITER //

DROP FUNCTION IF EXISTS calcular_fidelidad_cliente;

CREATE FUNCTION calcular_fidelidad_cliente(clienteId INT)
RETURNS DECIMAL(10, 2)
DETERMINISTIC
BEGIN
	DECLARE v_fidelidad_cliente DECIMAL(10, 2) DEFAULT 0;
	DECLARE v_num_pedidos INT DEFAULT 0;
	DECLARE v_euros_gastados DECIMAL(10, 2) DEFAULT 0.0; -- cuidado, es decimal, hacer despues un FLOOR
	
	SELECT COUNT(p.id) INTO v_num_pedidos
	FROM pedidos p
	WHERE p.clienteId=clienteId;
	
	SELECT IFNULL(SUM(lp.unidades * lp.precio), 0) INTO v_euros_gastados
	FROM lineaspedido lp
	JOIN pedidos p ON lp.pedidoId=p.id
	WHERE p.clienteId=clienteId;
	
	SET v_fidelidad_cliente = (v_num_pedidos * 0.5)+(v_euros_gastados * 0.05);
	RETURN v_fidelidad_cliente;

END //
DELIMITER ;




