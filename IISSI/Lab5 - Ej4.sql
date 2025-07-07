/*
4. Ejercicio: Vista - Pedidos, Facturación y Fidelidad del Último Mes
Crea una vista llamada VistaPedidosFidelidad que consolide información clave de los clientes sobre los pedidos realizados en el último mes, el total facturado y el índice de fidelidad. Esta vista permitirá analizar de forma rápida el comportamiento de los clientes más relevantes.

Requisitos de la Vista
La vista debe mostrar los siguientes datos:

Cliente:
ID del cliente.
Nombre del cliente.
Email del cliente.
Pedidos del Último Mes:
Número total de pedidos realizados por el cliente en el último mes.
Facturación del Último Mes:
Total de euros facturados en el último mes por el cliente.
Índice de Fidelidad:
Calculado usando la función calcular_fidelidad_cliente.

Detalles Técnicos
Pedidos del Último Mes:
Solo se incluirán los pedidos cuya fecha de realización (fechaRealizacion) sea del mes anterior al actual.
Se considerará el mes actual con la función CURDATE() y se calculará el mes anterior.
Facturación:
Se calculará sumando las cantidades (unidades) multiplicadas por el precio (precio) de las líneas de pedido correspondientes al cliente en el último mes.
Fidelidad:
El índice de fidelidad se obtendrá invocando la función calcular_fidelidad_cliente para cada cliente.
*/

CREATE OR REPLACE VIEW VistaPedidosFidelidad AS
SELECT c.id, u.nombre, u.email, COUNT(p.id) AS pedidos_ultimo_mes, SUM(lp.unidades*lp.precio) AS facturacion_ultimo_mes, calcular_fidelidad_cliente(c.id) AS fidelidad
FROM clientes c
JOIN usuarios u ON c.usuarioId=u.id
LEFT JOIN pedidos p ON p.clienteId=c.id AND (MONTH(p.fechaRealizacion) = MONTH(CURDATE()) - 1 AND YEAR(p.fechaRealizacion) = YEAR(CURDATE()))
LEFT JOIN lineaspedido lp ON lp.pedidoId=p.id
GROUP BY c.id, u.nombre, u.email;

SELECT * FROM VistaPedidosFidelidad;


