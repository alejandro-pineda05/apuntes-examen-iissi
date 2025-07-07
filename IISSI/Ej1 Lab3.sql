/*Ejercicio 1: Inserciones en distintas tablas
Recuerde la sintaxis de la operación INSERT. Consulte el manual de mariadb para los detalles sintácticos: https://mariadb.com/kb/en/insert/
*/
/*
Inserta datos válidos en la tabla Usuarios para cuatro usuarios diferentes,
asegurándote de que la contraseña cumpla con la longitud mínima de 8 caracteres y el email sea único.
*/
INSERT INTO usuarios(email, contraseña, nombre)
VALUES ('user1@gmail.com', 'password123', 'user1'),
('user2@gmail.com', 'password123', 'user2'),
('user3@gmail.com', 'password123', 'user3'),
('user4@gmail.com', 'password123', 'user4');
-- CORRECTO !!!

/*
Inserta un cliente con una edad superior a 14 años en la tabla Clientes, relacionado con uno de los usuarios previamente creados.
*/
INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
VALUES (6, 'Calle Habichuela', 14007, '2005-10-21'); -- Mayor de 14 años
-- CORRECTO !!!


/*
Inserta un cliente con una edad superior a 14 años y menor de 18 años en la tabla Clientes, relacionado con uno de los usuarios previamente creados.
*/
INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
VALUES (7, 'Calle Lenteja', 14007, '2009-10-21'); -- Mayor de 14, menor de 18
-- CORRECTO !!!

/*
Inserta un cliente con que no tendrá ningun pedido..
*/
-- se refiere simplemente a insertar un cliente en la tabla Clientes sin añadir luego ningún Pedido asociado a él en la tabla Pedidos.
INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
VALUES (8, 'Calle De No Hacer Pedidos', 14007, '2005-10-21');
-- CORRECTO !!!

/*
Inserta un empleado en la tabla Empleados, relacionado con uno de los usuarios previamente creados.
*/
INSERT INTO empleados(usuarioId, salario)
VALUES (5, 50000);
-- CORRECTO !!!

/*
Añade tipos de producto en la tabla TiposProducto para categorías de productos (por ejemplo, "Electrónica", "Alimentos" y "Droguería").
*/

INSERT INTO tiposproducto(nombre)
VALUES ('Electrónica'), ('Alimentos'), ('Droguería');
-- CORRECTO !!!


/*
Inserta productos en la tabla Productos, asociándolos a los tipos de producto creados previamente. Asegúrate de cumplir con las siguientes características para cada producto:
Auriculares: Producto de tipo Electrónica, con un precio de 25.00, permitido para menores.
Vino Tinto: Producto de tipo Alimentos, con un precio de 15.00, no permitido para menores.
Chocolate: Producto de tipo Alimentos, con un precio de 3.50, permitido para menores.
Cargador USB: Producto de tipo Electrónica, con un precio de 10.00, permitido para menores.
Whisky: Producto de tipo Alimentos, con un precio de 45.00, no permitido para menores.
*/
-- Inserción de productos con sus características y tipoProductoId correcto
INSERT INTO Productos (nombre, descripción, precio, tipoProductoId, puedeVenderseAMenores)
VALUES 
('Auriculares', 'Auriculares con micrófono y reducción de ruido', 25.00, 3, TRUE),
('Vino Tinto', 'Botella de vino tinto reserva 750ml', 15.00, 4, FALSE),
('Chocolate', 'Tableta de chocolate negro 70%', 3.50, 4, TRUE),
('Cargador USB', 'Cargador rápido USB tipo C', 10.00, 3, TRUE),
('Whisky', 'Botella de whisky escocés 700ml', 45.00, 4, FALSE);




/* Inserta un pedido para el cliente con clienteId = 1 */
INSERT INTO pedidos(fechaRealizacion, fechaEnvio, direccionEntrega, comentarios, clienteId, empleadoId)
VALUES (CURDATE(), CURDATE(), 'Calle Ejemplo 45', 'Entrega urgente', 1, 1);

/* Añade líneas de pedido válidas al pedido anterior */
INSERT INTO lineaspedido(pedidoId, productoId, unidades, precio)
VALUES 
(16, 4, 1, 59.99);

/* ============================= */
/* INSERCIONES QUE DEBEN FALLAR */
/* ============================= */

-- ❌ Error por superar límite de unidades (más de 100)
INSERT INTO lineapedido(pedidoId, productoId, unidades, precioUnitario)
VALUES (1, 3, 150, 20.00);

-- ❌ Error por precio negativo
INSERT INTO lineapedido(pedidoId, productoId, unidades, precioUnitario)
VALUES (1, 3, 2, -5.00);

-- ❌ Error: producto no permitido para menores, cliente menor de 18 años
-- Asumiendo clienteId 2 es menor y productoId 5 = Whisky (no apto menores)
INSERT INTO pedidos(clienteId, fechaRealizacion, direccionEntrega, comentarios)
VALUES (2, CURDATE(), 'Calle Riesgo 13', 'Test restricción menor');

INSERT INTO lineapedido(pedidoId, productoId, unidades, precioUnitario)
VALUES (2, 5, 1, 45.00);

-- ❌ Error: producto repetido en el mismo pedido (violación UNIQUE)
INSERT INTO lineapedido(pedidoId, productoId, unidades, precioUnitario)
VALUES (1, 1, 2, 25.00);

-- ❌ Error: contraseña con menos de 8 caracteres
INSERT INTO usuarios(email, contraseña, nombre)
VALUES ('user5@gmail.com', 'short', 'user5');

-- ❌ Error: cliente menor de 14 años (trigger cliente_edad_minima)
INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
VALUES (5, 'Calle Infante', 14007, '2015-01-01');

-- ❌ Error: producto con precio negativo
INSERT INTO productos(nombre, descripción, precio, tipoProductoId, puedeVenderseAMenores)
VALUES ('ErrorProducto', 'Producto inválido', -10.00, 1, TRUE);