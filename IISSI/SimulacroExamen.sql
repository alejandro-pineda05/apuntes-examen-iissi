/*
Catálogo de requisitos
RI-1-01 Requisito de información
Como: Profesor de la asignatura
Quiero: Tener disponible información sobre las valoraciones que cada usuario haya podido realizar para cada juego,
teniendo en cuenta que un usuario puede valorar muchos juegos,
y un juego puede ser valorado por muchos usuarios. 
Es necesario guardar información de la fecha de la valoración,
la puntuación que ha otorgado cada usuario a cada juego,
su opinión en forma de texto,
el número de “likes” que ha recibido esa valoración por parte de otros usuarios
y el veredicto final sobre el juego.

Todos los atributos son obligatorios salvo el
número de “likes”, que por defecto será 0.

Para: Evaluar al estudiante


RN-1-01 Regla de negocio de la puntuación
Como: Profesor de la asignatura
Quiero: El usuario podrá otorgar a cada juego una puntuación entre 0 y 5, ambas inclusive.
Para: Evaluar al estudiante


RN-1-02 Regla de negocio del veredicto
Como: Profesor de la asignatura
Quiero: El usuario asignará un veredicto final a su valoración sobre cada juego, este veredicto podrá
ser ‘Imprescindible’, ‘Recomendado’, ‘Comprar en rebajas’, ‘No merece la pena’.
Para: Evaluar al estudiante


RN-1-03 Regla de negocio de valoraciones
Como: Profesor de la asignatura
Quiero: Un usuario no podrá hacer más de una valoración sobre un juego determinado.
Para: Evaluar al estudiante
*/

/*
Ejercicio-1 (2 puntos)
Implemente los requisitos proporcionados (RI/RN).
(La tabla puntúa 1 y cada restricción 0,5)
*/
DROP TABLE if EXISTS valoraciones;
DROP TABLE if EXISTS usuarios;
DROP TABLE if EXISTS juegos;

CREATE TABLE juegos(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nombre VARCHAR(100) NOT NULL,
	fechaLanzamiento DATE NOT NULL,
	fase ENUM('Beta', 'Terminado')
);

CREATE TABLE usuarios(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	nombre VARCHAR(100) NOT NULL
);

CREATE TABLE valoraciones(
	id INT PRIMARY KEY AUTO_INCREMENT NOT NULL,
	usuarioId INT NOT NULL,
	juegoId INT NOT NULL,
	fechaValoracion DATE NOT NULL,
	puntuacion DECIMAL(10,2) NOT NULL CHECK (puntuacion >= 0 AND puntuacion <= 5),
	opinion VARCHAR(255) NOT NULL,
	likes INT DEFAULT 0,
	veredicto ENUM('Imprescindible', 'Recomendado', 'Comprar en rebajas', 'No merece la pena') NOT NULL,
	
	UNIQUE (usuarioId, juegoId),
	
	FOREIGN KEY (usuarioId) REFERENCES usuarios(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE,
		
	FOREIGN KEY (juegoId) REFERENCES juegos(id)
		ON DELETE CASCADE
		ON UPDATE CASCADE
);


/*
Ejercicio-2 (2 puntos)
Codifique un procedimiento almacenado que inserte una nueva valoración de un usuario
concreto para un juego dado en la tabla creada en el ejercicio anterior, que será llamado
tantas veces como progresos se deseen añadir.
Para comprobar las RN y las restricciones de Integridad, se llamará al procedimiento con los
parámetros que aparecen en Prueba1-Inserción de valoración de juegos. Las valoraciones
en verde se insertarán y las marcadas en rojo serán rechazadas.
(Si la inserción se realizar directamente con varios comandos INSERT de SQL, entonces se
puntúa 0,5)
*/
DROP PROCEDURE if EXISTS insertar_valoracion;
DELIMITER //
CREATE PROCEDURE insertar_valoracion(
	IN p_usuarioId INT,
	IN p_juegoId INT,
	IN p_fechaValoracion DATE,
	IN p_puntuacion DECIMAL(10,2),
	IN p_opinion VARCHAR(255),
	IN p_likes INT,
	IN p_veredicto VARCHAR(255)
)
BEGIN
	INSERT INTO valoraciones(usuarioId, juegoId, fechaValoracion, puntuacion, opinion, likes, veredicto)
	VALUES (p_usuarioId, p_juegoId, p_fechaValoracion, p_puntuacion, p_opinion, p_likes, p_veredicto);
END //
DELIMITER ;
-- Poblar tabla usuarios (1 al 10)


/*
INSERT INTO usuarios (id, nombre) VALUES
(1, 'Ana García'),
(2, 'Luis Martínez'),
(3, 'Marta López'),
(4, 'Carlos Fernández'),
(5, 'Sofía Díaz'),
(6, 'Laura Sánchez'),
(7, 'Javier Torres'),
(8, 'Elena Ruiz'),
(9, 'Diego Morales'),
(10, 'Patricia Gómez');

-- Poblar tabla juegos (1 al 10)
INSERT INTO juegos (id, nombre, fechaLanzamiento, fase) VALUES
(1, 'The Legend of Zelda', '1986-02-21', 'Terminado'),
(2, 'Super Mario Odyssey', '2017-10-27', 'Terminado'),
(3, 'Minecraft', '2011-11-18', 'Terminado'),
(4, 'Among Us', '2018-06-15', 'Terminado'),
(5, 'Call of Duty', '2003-10-29', 'Terminado'),
(6, 'FIFA 21', '2020-10-09', 'Terminado'),
(7, 'Cyberpunk 2077', '2020-12-10', 'Beta');
*/



	
CALL insertar_valoracion(1, 2, CURDATE(), 5, 'Hola', 0, 'Imprescindible');
CALL insertar_valoracion(2, 4, CURDATE(), 3, 'Hola', 0, 'Comprar en rebajas');
CALL insertar_valoracion(3, 3, CURDATE(), 4, 'Hola', 0, 'Recomendado');
CALL insertar_valoracion(4, 5, CURDATE(), 1, 'Hola', 0, 'No merece la pena');
CALL insertar_valoracion(2, 3, CURDATE(), 4.5, 'Hola', 0, 'Imprescindible');

-- las siguientes deben fallar
CALL insertar_valoracion(1, 6, CURDATE(), 10, 'Hola', 0, 'Imprescindible');
CALL insertar_valoracion(3, 1, CURDATE(), 3, 'Hola', 0, 'Ni fu ni fa');
CALL insertar_valoracion(3, 3, CURDATE(), 2, 'No era para tanto', 0, 'No merece la pena');
CALL insertar_valoracion(1, 2, CURDATE(), 5, 'Hola', 0, 'Imprescindible');
CALL insertar_valoracion(6, 8, CURDATE(), 3, 'Hola', 0, 'Comprar en rebajas');

/*
Prueba1 Inserción de valoración de juegos
Como: Profesor de la asignatura
Quiero: ⦁ Insertar el progreso del usuario 1 en el juego 2, puntuación = 5, un comentario
de texto cualquiera, y veredicto ‘Imprescindible’, fecha de hoy.
⦁ Insertar el progreso del usuario 2 en el juego 4, puntuación = 3, un comentario
de texto cualquiera, y estado ‘Comprar en rebajas’, fecha de hoy.
⦁ Insertar el progreso del usuario 3 en el juego 3, puntuación = 4, un comentario
de texto cualquiera, y estado ‘Recomendado’, fecha de hoy.
⦁ Insertar el progreso del usuario 4 en el juego 5, puntuación = 1, un comentario
de texto cualquiera, y estado ‘No merece la pena’, fecha de hoy.
⦁ Insertar el progreso del usuario 2 en el juego 3, puntuación = 4.5, un
comentario de texto cualquiera, y estado ‘Imprescindible’, fecha de hoy.

⦁ Insertar el progreso del usuario 1 en el juego 6, puntuación = 10, un comentario
de texto cualquiera, y estado ‘Imprescindible’. (RN-1-01)
⦁ Insertar el progreso del usuario 3 en el juego 1, puntuación = 3, un comentario
de texto cualquiera, y estado ‘Ni fu ni fa’. (RN-1-02)
⦁ Insertar el progreso del usuario 3 en el juego 3, puntuación = 2, comentario ‘No
era para tanto’, y estado ‘No merece la pena’. (RN-1-03)
⦁ Insertar el progreso del usuario 6 en el juego 8, puntuación = 3, un comentario
de texto cualquiera, y estado ‘Comprar en rebajas’. (referencia no existente)
Para: Evaluar al estudiante.
*/






/*
Cree una consulta que devuelva todos los usuarios, sus juegos y las valoraciones
respectivas, ordenados por videojuegosId.
*/
SELECT u.nombre, j.nombre, v.*
FROM usuarios u
JOIN valoraciones v ON u.id=v.usuarioId
JOIN juegos j ON j.id=v.juegoId
ORDER BY v.juegoId

/*
Codifique un trigger para impedir que la fecha de una valoración sea anterior a la fecha de
lanzamiento del juego, y posterior a la fecha actual. Añada una instrucción que haga saltar el
trigger.
*/

DELIMITER //
DROP TRIGGER IF EXISTS comprueba_fechas;

CREATE TRIGGER comprueba_fechas
BEFORE INSERT ON valoraciones
FOR EACH ROW
BEGIN
	DECLARE v_fechaLanzamiento DATE;
	
	SELECT j.fechaLanzamiento INTO v_fechaLanzamiento
	FROM juegos j
	WHERE j.id=NEW.juegoId;

	IF NEW.fechaValoracion < v_fechaLanzamiento OR NEW.fechaValoracion > CURDATE() THEN
		SIGNAL SQLSTATE '45000'
	   SET MESSAGE_TEXT = 'Error de fechas';
	END IF;
	
END //

DELIMITER ;

-- probar trigger:
CALL insertar_valoracion(1, 7, '1750-10-21', 4.5, 'Hola', 0, 'Imprescindible');



/*
Codifique una función que devuelva el número de valoraciones de un usuario dado.
Realice una prueba de la función con UsuarioId=2.
*/

DELIMITER //
DROP FUNCTION if EXISTS numero_valoraciones;
CREATE FUNCTION numero_valoraciones(usuarioId INT)
RETURNS INT
BEGIN
	DECLARE v_numero_valoraciones INT DEFAULT 0;
	
	SELECT COUNT(v.id) INTO v_numero_valoraciones
	FROM valoraciones v
	WHERE v.usuarioId = usuarioId;
	
	RETURN v_numero_valoraciones;
END //
DELIMITER ;

-- probar la funcion
SELECT numero_valoraciones(2);



/*
Cree una consulta que devuelva los juegos y la media de las valoraciones recibidas,
ordenados de mayor a menor. En el listado deben aparecer todos los juegos, tengan o no
valoración.
*/
SELECT j.nombre, AVG(v.puntuacion) AS media_valoraciones
FROM juegos j
LEFT JOIN valoraciones v ON j.id=v.juegoId
GROUP BY j.id
ORDER BY media_valoraciones DESC;


/*
Ejercicio-7 (1 puntos)
Cree un trigger que impida valorar un juego que esté en fase ’Beta’. (1 punto)
*/
DELIMITER //
DROP TRIGGER if EXISTS impedir_valorar_beta;
CREATE TRIGGER impedir_valorar_beta
BEFORE INSERT ON valoraciones
FOR EACH ROW
BEGIN
	DECLARE v_fase_juego VARCHAR(100);
	
	SELECT j.fase INTO v_fase_juego
	FROM juegos j
	WHERE j.id=NEW.juegoId;
	
	 
	IF v_fase_juego = 'Beta' THEN
		SIGNAL SQLSTATE '45000'
	   SET MESSAGE_TEXT = 'Error. El juego aún está en fase Beta';
	END IF;
END //
DELIMITER ;
	
CALL insertar_valoracion(1, 7, CURDATE(), 5, 'Hola', 0, 'Imprescindible');



/*
Cree un procedimiento pAddUsuarioValoracion que, dentro de una transacción, inserte un
usuario y una valoración de dicho usuario a un videojuego dado. Incluya los parámetros que
considere oportunos.
Realice dos llamadas: una que inserte ambos (el usuario y la valoración) correctamente, y
una en la que el segundo rompa alguna restricción y aborte la transacción. Incluya capturas
de pantallas.
*/
DELIMITER //
DROP PROCEDURE IF EXISTS pAddUsuarioValoracion;
CREATE PROCEDURE pAddUsuarioValoracion(
	IN p_nombre VARCHAR(100),
	IN p_juegoId INT,
	IN p_fechaValoracion DATE,
	IN p_puntuacion INT,
	IN p_opinion VARCHAR(255),
	IN p_likes INT,
	IN p_veredicto VARCHAR(100)	
)
BEGIN 
	DECLARE v_usuarioId INT;
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
	   BEGIN
	      ROLLBACK;
	      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algo salió mal. Se canceló el registro';
	   END;
	START TRANSACTION;
		INSERT INTO usuarios(nombre) VALUES(p_nombre);
		SELECT LAST_INSERT_ID() INTO v_usuarioId;
		INSERT INTO valoraciones(usuarioId, juegoId, fechaValoracion, puntuacion, opinion, likes, veredicto)
		VALUES (v_usuarioId, p_juegoId, p_fechaValoracion, p_puntuacion, p_opinion, p_likes, p_veredicto);
	COMMIT;
END //
DELIMITER ;	
	
CALL pAddUsuarioValoracion('Alejandro Martín', 3, CURDATE(), 5, 'El maincra to chulo ompare', 15, 'Imprescindible');

-- falla
CALL pAddUsuarioValoracion('Alejandro Pineda Martín', 7, CURDATE(), 2, 'Basura', 1, 'Comprar en rebajas');




