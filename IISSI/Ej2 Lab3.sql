/*
Ejercicio 2: Actualización de datos en distintas tablas
Recuerde la sintaxis de la operación UPDATE. Consulte el manual de mariadb para los detalles sintácticos:https://mariadb.com/kb/en/update/

Actualiza el nombre de un usuario en la tabla Usuarios.
*/
UPDATE usuarios
SET nombre='Usuario 1'
WHERE id=5; 


/*
Actualiza el salario de un empleado en la tabla Empleados.
*/
UPDATE empleados SET salario=55000 WHERE id=3

/*
Modifica el precio de un producto en la tabla Productos para asegurarte de que el valor sea positivo y mayor o igual a cero.
*/
UPDATE productos SET precio=-1 WHERE id=1 -- da error porque no le puedes poner precio negarivo

/*
Actualizar un pedido para incluir la fecha de envío como la fecha actual. Use la función CURDATE() para obtener la fecha actual.
*/
UPDATE pedidos SET fechaRealizacion=CURDATE() WHERE id=15

/*
Actualizar un pedido para incluir el empleado que lo gestione.
*/
UPDATE pedidos SET empleadoId=3 WHERE id=14;


/*
ACTUALIZACIONES QUE DEBEN FALLAR

Intenta actualizar la contraseña de un usuario con una contraseña de menos de 8 caracteres para verificar que el CHECK de longitud se respeta.
*/
UPDATE usuarios SET contraseña='Tarara' WHERE id=1; -- falla

/*
Intenta modificar el precio de un producto en la tabla Productos a un valor negativo para verificar la restricción de precio mínimo.
*/
UPDATE productos SET precio=-1 WHERE id=1 -- falla

/*
Intenta actualizar el número de unidades en la tabla LineasPedido a un valor fuera del rango permitido (mayor a 100) y observa el error generado.
*/
UPDATE lineaspedido SET unidades=200 WHERE id=1 -- falla

