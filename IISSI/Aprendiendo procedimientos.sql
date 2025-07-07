DELIMITER $$

CREATE PROCEDURE ejemplo()
BEGIN
   SELECT 'Hola mundo';
   SELECT NOW();
END$$

DELIMITER ;

CALL ejemplo();



DELIMITER //
CREATE OR REPLACE PROCEDURE saludar(IN nombre VARCHAR(50))
BEGIN
	DECLARE mensaje TEXT;
	SET mensaje = 'Hola ';
	SELECT CONCAT(mensaje, nombre) AS saludo;
END //

DELIMITER ;

CALL saludar('Alejandro');



DELIMITER //
CREATE OR REPLACE PROCEDURE clasificar_usuario(IN edad_usuario INT)
BEGIN
	DECLARE mensaje TEXT;
	IF edad_usuario < 18 THEN SET mensaje = 'El usuario es menor de edad';
	ELSEIF edad_usuario < 65 then SET mensaje = 'El usuario es adulto';
	ELSE SET mensaje = 'El usuario está jubilado';
	END IF;
	SELECT mensaje;
END //

CALL clasificar_usuario(10);



-- IF siempre hay que usarlo dentro de un PROCEDURE o similar, mientras que CASE se usa para evaluar condiciones y devolver un valor
-- ejemplo consulta
SELECT nombre,
       CASE
         WHEN puedeVenderseAMenores = TRUE THEN 'Para todas las edades'
         ELSE 'Solo mayores de edad'
       END AS restriccion_edad
FROM productos;

-- ejemplo actualizacion 		(si tubieramos una columna antiguedad INT funcionaría)
UPDATE empleados
SET salario = salario + 
  CASE
    WHEN antiguedad >= 10 THEN 1000
    WHEN antiguedad >= 5 THEN 500
    ELSE 0
  END;

-- ejemplo dentro de un procedimiento:

DELIMITER // 
CREATE or REPLACE PROCEDURE categorizar_cliente(IN edad INT, OUT categoria VARCHAR(20))
BEGIN
  SET categoria = 
    CASE
      WHEN edad >= 65 THEN 'Senior'
      WHEN edad >= 18 THEN 'Adulto'
      ELSE 'Menor'
    END;
END // 
DELIMITER ;

-- Creamos una variable temporal para almacenar el resultado
SET @resultado = '';

-- Llamamos al procedimiento y le pasamos la variable de salida
CALL categorizar_cliente(30, @resultado);

-- Mostramos el resultado
SELECT @resultado AS categoria;



DELIMITER //
DROP PROCEDURE if EXISTS registro_cliente;
CREATE PROCEDURE registro_cliente(
	IN p_direccionEnvio VARCHAR(255),
	IN p_codigoPostal VARCHAR(10),
	IN p_fechaNacimiento DATE,
	IN p_email VARCHAR(255),
	IN p_contraseña VARCHAR(255),
	IN p_nombre VARCHAR(255)
)

BEGIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION
   BEGIN
      ROLLBACK;
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Algo salió mal. Se canceló el registro';
   END;
   
   START TRANSACTION;
   
   INSERT INTO usuarios(email, contraseña, nombre)
	VALUES (p_email, p_contraseña, p_nombre);
	
   INSERT INTO clientes(usuarioId, direccionEnvio, codigoPostal, fechaNacimiento)
	VALUES (LAST_INSERT_ID(), p_direccionEnvio, p_codigoPostal, p_fechaNacimiento);
	
	COMMIT;
END //

DELIMITER ;

CALL registro_cliente('Calle transacciones', '14007', '2005-10-21', 'holamundo69xddd@gmail.com', 'password123', 'Cliente generado por procedimiento');

   




