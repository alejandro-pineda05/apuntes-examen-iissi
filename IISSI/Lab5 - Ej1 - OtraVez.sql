/*
Lab5: SQL Avanzado
Parta del archivo 1.creacionTablas.sql para crear la base de datos tiendaOnline y ejecute el archivo 2.popularBD.sql para insertar datos de prueba para comenzar con el laboratorio y realice los siguientes ejercicios.

1. Stored Procedure - Registrar cliente premium
Diseñe un stored procedure llamado registrar_cliente_premium que permita registrar un cliente premium cumpliendo las siguientes condiciones:

Se podrá registrar un cliente premium por cada 5000 euros de facturación total de la empresa
en pedidos del mes anterior al de la creación del cliente premium.
Es decir, si hemos facturado 12.000 € en septiembre, en octubre solo podremos registrar 2 clientes premium.

Para contabilizar el número de clientes premium registrados este mes, se considerarán aquellos clientes que tienen un pedido
con una línea de pedido que contenga el producto 'Smartphone' y cuyo precio sea 0.

Se debe controlar un límite máximo de clientes premium por mes:

Si al registrar un nuevo cliente premium se superaría el límite mensual,
se debe impedir el registro y lanzar una excepción con el mensaje: "Límite de clientes premium alcanzado".
Si se cumple que se pueden crear clientes premium:

El cliente premium será registrado como un cliente normal en las tablas Usuarios y Clientes.
Se generará un pedido por defecto para este cliente que contendrá una única línea de pedido:
Producto: 'Smartphone'.
Precio: 0.

Instrucciones
Implementa el stored procedure registrar_cliente_premium.
Asegúrate de verificar las condiciones de facturación y el límite de clientes premium antes de registrar al cliente.
Usa transacciones para garantizar que todas las operaciones se realicen de manera consistente.
Introduzca los datos necesarios para probar casos positivos como negativos de su solución.
Ejemplo de uso
CALL registrar_cliente_premium('email@domain.com', 'password123', 'Nombre Cliente', 'Dirección Cliente', '12345', '1990-01-01');
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

DECLARE v_num_clientes_premium_que_se_pueden_registrar_este_mes INT DEFAULT NULL;
DECLARE v_num_clientes_premium_que_se_pueden_registrar_este_mes_actualmente INT DEFAULT NULL;
DECLARE v_num_clientes_premium_registrados_este_mes INT DEFAULT NULL;
DECLARE v_facturacion_total_mes_anterior INT DEFAULT NULL;
DECLARE v_id_smartphone INT DEFAULT NULL;

DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algo salió mal. Se canceló el registro';
   END;
START TRANSACTION;

/*
Se podrá registrar un cliente premium por cada 5000 euros de facturación total de la empresa
en pedidos del mes anterior al de la creación del cliente premium.
Es decir, si hemos facturado 12.000 € en septiembre, en octubre solo podremos registrar 2 clientes premium.

Para contabilizar el número de clientes premium registrados este mes, se considerarán aquellos clientes que tienen un pedido
con una línea de pedido que contenga el producto 'Smartphone' y cuyo precio sea 0.
*/

-- funciona
SELECT SUM(lp.precio * lp.unidades) AS ingresos INTO v_facturacion_total_mes_anterior
FROM lineaspedido lp
JOIN pedidos p ON lp.pedidoId=p.id
WHERE MONTH(p.fechaRealizacion) = MONTH(DATE_SUB(CURDATE(), INTERVAL 1 MONTH))
AND YEAR(p.fechaRealizacion) = YEAR(DATE_SUB(CURDATE(), INTERVAL 1 MONTH));

-- no funciona porque usa todos los años
/*
SELECT SUM(lp.precio * lp.unidades) AS ingresos -- INTO v_facturacion_total_mes_anterior
FROM lineaspedido lp
JOIN pedidos p ON lp.pedidoId=p.id
WHERE MONTH(p.fechaRealizacion) = MONTH(CURDATE()) - 1;
*/
IF v_facturacion_total_mes_anterior IS NULL THEN
	SET v_facturacion_total_mes_anterior = 0;
END IF;


SET v_num_clientes_premium_que_se_pueden_registrar_este_mes = FLOOR(v_facturacion_total_mes_anterior/5000);

/*
Para contabilizar el número de clientes premium registrados este mes, se considerarán aquellos clientes que tienen un pedido
con una línea de pedido que contenga el producto 'Smartphone' y cuyo precio sea 0.
*/
SELECT COUNT(DISTINCT c.id) AS numero_clientes_premium INTO v_num_clientes_premium_registrados_este_mes
FROM clientes c
JOIN pedidos p ON p.clienteId=c.id
JOIN lineaspedido lp ON p.id=lp.pedidoId
JOIN productos pr ON pr.id=lp.productoId
WHERE pr.nombre='Smartphone'
	AND lp.precio=0
	AND MONTH(p.fechaRealizacion) = MONTH(CURDATE())
	AND YEAR(p.fechaRealizacion) = YEAR(CURDATE());
	
SET v_num_clientes_premium_que_se_pueden_registrar_este_mes_actualmente = v_num_clientes_premium_que_se_pueden_registrar_este_mes - v_num_clientes_premium_registrados_este_mes;


/*
Si al registrar un nuevo cliente premium se superaría el límite mensual,
se debe impedir el registro y lanzar una excepción con el mensaje: "Límite de clientes premium alcanzado".
Si se cumple que se pueden crear clientes premium:
*/
IF v_num_clientes_premium_que_se_pueden_registrar_este_mes_actualmente IS NULL OR v_num_clientes_premium_que_se_pueden_registrar_este_mes_actualmente <= 0 THEN
ROLLBACK;
   SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Límite de clientes premium alcanzado';
END IF;


SELECT pr.id INTO v_id_smartphone
FROM productos pr WHERE pr.nombre='Smartphone';


IF v_id_smartphone IS NULL THEN
  SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se encontró el producto Smartphone';
END IF;


/*
El cliente premium será registrado como un cliente normal en las tablas Usuarios y Clientes.
Se generará un pedido por defecto para este cliente que contendrá una única línea de pedido:
Producto: 'Smartphone'.
Precio: 0.
*/

INSERT INTO usuarios(email, contraseña, nombre)
VALUES (p_email, p_contraseña, p_nombre);
INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
VALUES(LAST_INSERT_ID(), p_direccionEnvio, p_codigoPostal, p_fechaNacimiento);

INSERT INTO pedidos(fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId)
VALUES (CURDATE(), CURDATE(), 'Calle Premium', 'Comentario premium', LAST_INSERT_ID(), NULL);
INSERT INTO lineaspedido(pedidoId, productoId, unidades, precio)
VALUES (LAST_INSERT_ID(), v_id_smartphone, 1, 0);


COMMIT;

END //
DELIMITER ;





