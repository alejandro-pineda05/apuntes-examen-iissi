/*
1. Creación de tabla. (1,5 puntos)
Incluya su solución en el fichero 1.solucionCreacionTabla.sql.

Necesitamos conocer la garantía de nuestros productos.
Para ello se propone la creación de una nueva tabla llamada Garantias.
Cada producto tendrá como máximo una garantía (no todos los productos tienen garantía),
y cada garantía estará relacionada con un producto.

Para cada garantía necesitamos conocer la fecha de inicio de la garantía,
la fecha de fin de la garantía,
si tiene garantía extendida o no.
Asegure que la fecha de fin de la garantía es posterior a la fecha de inicio.
*/

DROP TABLE if EXISTS garantias;
CREATE TABLE garantias(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	productoId INT NOT NULL,
	fechaInicio DATE NOT NULL,
	fechaFin DATE NOT NULL CHECK(fechaFin > fechaInicio),
	garantiaExtendida BOOL DEFAULT FALSE,
	UNIQUE (productoId),
	FOREIGN KEY (productoId) REFERENCES productos(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);











