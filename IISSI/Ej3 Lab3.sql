/*
Ejercicio 3. Borrado de datos en tablas
Borra un tipo de producto de la tabla TiposProducto que no esté relacionado con ningún producto en Productos.
*/
DELETE FROM tiposproducto WHERE id=5;

/*
Borrado con efectos en cascada
Borra un usuario que tenga dependencias en Clientes (configurado con ON DELETE CASCADE).
Al realizar esta operación, los registros en Clientes asociados al usuario también deben eliminarse en cascada.
Asegurate que el usuario-cliente no tiene pedidos asociados.
*/
DELETE FROM usuarios WHERE id=7;

/*
Intenta borrar un cliente que tenga registros asociados en la tabla Pedidos.
Este borrado debería fallar debido a la configuración de ON DELETE RESTRICT, que impide eliminar un cliente con pedidos asociados.
*/
DELETE FROM clientes WHERE id=1; -- efectivamente da error 

/*
Borra un empleado que esté asociado a un pedido en Pedidos.
Esta operación está configurada con ON DELETE SET NULL, por lo que el campo empleadoId en la tabla Pedidos debería establecerse en NULL al eliminar el empleado.
*/
DELETE FROM empleados WHERE id=2; -- efectivamente, el pedido cuyo empleado era el 2 se ha puesto a NULL




