/*
Diseñe un stored procedure llamado registrar_cliente_premium que permita registrar un cliente premium cumpliendo las siguientes condiciones:

1.Se podrá registrar un cliente premium por cada 5000 euros de facturación total de la empresa
en pedidos del mes anterior al de la creación del cliente premium.
Es decir, si hemos facturado 12.000 € en septiembre,
en octubre solo podremos registrar 2 clientes premium.

2.Para contabilizar el número de clientes premium registrados este mes,
se considerarán aquellos clientes que tienen un pedido
con una línea de pedido que contenga el producto 'Smartphone' y cuyo precio sea 0.

3.Se debe controlar un límite máximo de clientes premium por mes:
Si al registrar un nuevo cliente premium se superaría el límite mensual,
se debe impedir el registro y lanzar una excepción con el mensaje:
"Límite de clientes premium alcanzado".


4.Si se cumple que se pueden crear clientes premium:

El cliente premium será registrado como un cliente normal en las tablas Usuarios y Clientes.
Se generará un pedido por defecto para este cliente que contendrá una única línea de pedido:
Producto: 'Smartphone'.
Precio: 0.
*/



DELIMITER //

DROP PROCEDURE IF EXISTS registrar_cliente_premium;

CREATE PROCEDURE registrar_cliente_premium(
	IN p_email VARCHAR(100),
	IN p_contraseña VARCHAR(100),
	IN p_nombre VARCHAR(100),
	IN p_direccionEnvio VARCHAR(100),
	IN p_codigoPostal INT,
	IN p_fechaNacimiento DATE
)

BEGIN
	DECLARE v_num_clientes_premium_permitidos INT;
	DECLARE v_ingresos_mes_pasado DECIMAL(10,2);
	DECLARE v_num_clientes_premium_actuales INT;
	DECLARE v_num_clientes_premium_posibles INT;
	DECLARE v_id_Smartphone INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algo salió mal. Se canceló el registro';
   END;
   
   
	SELECT SUM(lp.unidades * lp.precio) AS ingresos INTO v_ingresos_mes_pasado
		FROM lineaspedido lp
		JOIN pedidos p ON p.id=lp.pedidoId
   	WHERE MONTH(p.fechaRealizacion) = MONTH(CURDATE()) - 1
			AND YEAR(p.fechaRealizacion) = YEAR(CURDATE());
	
	SET v_num_clientes_premium_permitidos = FLOOR(v_ingresos_mes_pasado / 5000);
	
	SELECT COUNT(DISTINCT c.id) AS clientes_premium_mes_actual INTO v_num_clientes_premium_actuales
	FROM clientes c
	JOIN pedidos p ON p.clienteId=c.id
	JOIN lineaspedido lp ON lp.pedidoId=p.id
	JOIN productos pr ON lp.productoId=pr.id
	WHERE pr.nombre='Smartphone'
		AND lp.precio=0
		AND MONTH(p.fechaRealizacion) = MONTH(CURDATE())
	   AND YEAR(p.fechaRealizacion) = YEAR(CURDATE());
	
	SET v_num_clientes_premium_posibles = v_num_clientes_premium_permitidos - v_num_clientes_premium_actuales;  
	
	SELECT pr.id INTO v_id_Smartphone FROM productos pr WHERE pr.nombre='Smartphone';
   
   
   START TRANSACTION;
   IF v_num_clientes_premium_posibles IS NULL OR v_num_clientes_premium_posibles <= 0 THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Límite de clientes premium alcanzado';
   END IF;
   
   
   INSERT INTO usuarios(email, contraseña, nombre)
   VALUES(p_email, p_contraseña, p_nombre);
   
   INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
   VALUES(LAST_INSERT_ID(), p_direccionEnvio, p_codigoPostal, p_fechaNacimiento);
   
   INSERT INTO pedidos(fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId)
   VALUES (CURDATE(), CURDATE(), 'Direccion premium', 'Pedido premium', LAST_INSERT_ID(), NULL);
   
   INSERT INTO lineaspedido(pedidoId, productoId, unidades, precio)
   VALUES (LAST_INSERT_ID(), v_id_Smartphone, 1, 0);
	
	COMMIT;
	
	
END //

DELIMITER ;

CALL registrar_cliente_premium('premium@gmail.com', 'password123', 'Pepe', 'Calle Premium', 14007, '2005-10-21');




-- Version chat gpt ligeramente mejorada:

DELIMITER //

DROP PROCEDURE IF EXISTS registrar_cliente_premium;

CREATE PROCEDURE registrar_cliente_premium(
	IN p_email VARCHAR(100),
	IN p_contraseña VARCHAR(100),
	IN p_nombre VARCHAR(100),
	IN p_direccionEnvio VARCHAR(100),
	IN p_codigoPostal INT,
	IN p_fechaNacimiento DATE
)

BEGIN
	DECLARE v_num_clientes_premium_permitidos INT;
	DECLARE v_ingresos_mes_pasado DECIMAL(10,2);
	DECLARE v_num_clientes_premium_actuales INT;
	DECLARE v_num_clientes_premium_posibles INT;
	DECLARE v_id_Smartphone INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	BEGIN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algo salió mal. Se canceló el registro';
	END;

	-- Ingresos del mes anterior
	SELECT SUM(lp.unidades * lp.precio) INTO v_ingresos_mes_pasado
	FROM lineaspedido lp
	JOIN pedidos p ON p.id = lp.pedidoId
	WHERE MONTH(p.fechaRealizacion) = MONTH(CURDATE()) - 1
	  AND YEAR(p.fechaRealizacion) = YEAR(CURDATE());

	IF v_ingresos_mes_pasado IS NULL THEN
		SET v_ingresos_mes_pasado = 0;
	END IF;

	SET v_num_clientes_premium_permitidos = FLOOR(v_ingresos_mes_pasado / 5000);

	-- Clientes premium ya registrados este mes
	SELECT COUNT(DISTINCT c.id) INTO v_num_clientes_premium_actuales
	FROM clientes c
	JOIN pedidos p ON p.clienteId = c.id
	JOIN lineaspedido lp ON lp.pedidoId = p.id
	JOIN productos pr ON lp.productoId = pr.id
	WHERE pr.nombre = 'Smartphone'
	  AND lp.precio = 0
	  AND MONTH(p.fechaRealizacion) = MONTH(CURDATE())
	  AND YEAR(p.fechaRealizacion) = YEAR(CURDATE());

	SET v_num_clientes_premium_posibles = v_num_clientes_premium_permitidos - v_num_clientes_premium_actuales;

	-- Obtener ID del producto Smartphone
	SELECT pr.id INTO v_id_Smartphone
	FROM productos pr
	WHERE pr.nombre = 'Smartphone'
	LIMIT 1;

	IF v_id_Smartphone IS NULL THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el producto Smartphone';
	END IF;

	-- Comprobación de email duplicado
	IF EXISTS (SELECT 1 FROM usuarios WHERE email = p_email) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email ya está registrado';
	END IF;

	-- Transacción principal
	START TRANSACTION;

	IF v_num_clientes_premium_posibles <= 0 THEN
		ROLLBACK;
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Límite de clientes premium alcanzado';
	END IF;

	-- Crear usuario
	INSERT INTO usuarios(email, contraseña, nombre)
	VALUES(p_email, p_contraseña, p_nombre);

	-- Crear cliente
	INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
	VALUES(LAST_INSERT_ID(), p_direccionEnvio, p_codigoPostal, p_fechaNacimiento);

	-- Crear pedido premium
	INSERT INTO pedidos(fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId)
	VALUES (CURDATE(), CURDATE(), 'Direccion premium', 'Pedido premium', LAST_INSERT_ID(), NULL);

	-- Línea del pedido gratis
	INSERT INTO lineaspedido(pedidoId, productoId, unidades, precio)
	VALUES (LAST_INSERT_ID(), v_id_Smartphone, 1, 0);

	COMMIT;
END //

DELIMITER ;


CALL registrar_cliente_premium('holahola@gmail.com', 'password123', 'Alejandro', 'Calle Premium', 14007, '2005-10-21');





