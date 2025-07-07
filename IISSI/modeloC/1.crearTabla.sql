
/*
Incluya su solución en el fichero 1.solucionCreacionTabla.sql.
Necesitamos conocer la opinión de nuestros clientes sobre nuestros productos.
Para ello se propone la creación de una nueva tabla llamada Valoraciones.

Cada valoración versará sobre un producto y será realizada por un solo cliente.
Cada producto podrá ser valorado por muchos clientes.
Cada cliente podrá realizar muchas valoraciones.
Un cliente no puede valorar más de una vez un mismo producto.


Para cada valoración necesitamos conocer la puntuación de 1 a 5 (sólo se permiten enteros)
y la fecha en que se realiza la valoración.
*/

DROP TABLE IF EXISTS valoraciones;

CREATE TABLE valoraciones(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	clienteId INT NOT NULL,
	productoId INT NOT NULL,
	puntuacion INT NOT NULL CHECK (puntuacion >= 1 AND puntuacion <= 5),
	fecha DATE NOT NULL,

	FOREIGN KEY (clienteId) REFERENCES clientes(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
	FOREIGN KEY (productoId) REFERENCES productos(id)
		ON DELETE CASCADE 
		ON UPDATE CASCADE,
	UNIQUE(clienteId, productoId)
);



