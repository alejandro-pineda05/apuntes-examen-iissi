/*
1. Creación de tabla. (1,5 puntos)
Incluya su solución en el fichero 1.solucionCreacionTabla.sql.
Necesitamos conocer los pagos que se realicen sobre los pedidos.
Para ello se propone la creación de una nueva tabla llamada Pagos.

Cada pedido podrá tener asociado varios pagos y cada pago solo corresponde con un pedido en concreto.
Para cada pago necesitamos conocer la fecha de pago,
la cantidad pagada (que no puede ser negativa)
y si el pago ha sido revisado o no
(por defecto no estará revisado).
*/

DROP TABLE if EXISTS pagos;

CREATE TABLE pagos(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	pedidoId INT NOT NULL,
	fechaRealizacion DATE NOT NULL,
	cantidadPagada DECIMAL(10,2) NOT NULL CHECK(cantidadPagada >= 0),
	revisado BOOLEAN DEFAULT FALSE,
	
	FOREIGN KEY (pedidoId) REFERENCES pedidos(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);




