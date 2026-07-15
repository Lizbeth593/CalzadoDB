USE calzado_db
GO

-- VISTAS
--1) Clientes frecuentes 

CREATE VIEW vw_clientes_frecuentes 
AS
SELECT 
	c.id_cliente,
	c.nombres + ' ' + c.apellidos AS Cliente,
	ci.provincia,
	COUNT(v.id_venta) AS Total_compras,
	SUM(v.total_venta) AS Total_acumulado
	FROM clientes AS c
	JOIN ciudades AS ci
	ON c.id_ciudad = ci.id_ciudad
	JOIN ventas AS v
	ON v.id_cliente = c.id_cliente
	GROUP BY c.id_cliente, c.nombres, c.apellidos, ci.provincia;
GO	

SELECT * FROM vw_clientes_frecuentes;


--2) Ventas Consolidadas

CREATE VIEW vw_ventas_consolidadas 
AS
SELECT 

	v.id_venta,
	v.fecha_venta,
	c.nombres + ' ' + c.apellidos AS Cliente,
	e.nombres + ' ' + e.apellidos AS Vendedor,
	v.tipo_venta,
	SUM(dv.cantidad * dv.precio_unitario) AS Subtotal,
	p.porcentaje_descuento,
	v.total_venta AS Total
	FROM ventas AS v
	JOIN clientes AS c
	ON v.id_cliente = c.id_cliente
	JOIN empleados AS e
	ON e.id_empleado = v.id_empleado
	JOIN detalle_venta AS dv
	ON dv.id_venta = v.id_venta
	LEFT JOIN promociones AS p
	ON v.id_promocion = p.id_promocion
	GROUP BY v.id_venta, v.fecha_venta, c.nombres, c.apellidos, e.nombres, e.apellidos,
         v.tipo_venta, p.porcentaje_descuento, v.total_venta;
GO


SELECT * FROM vw_ventas_consolidadas;


--3) Productos con Bajo Stock 

CREATE VIEW vw_prooductos_stock
AS
SELECT 
	p.id_producto,
	p.nombre_producto AS Producto,
	c.nombre_categoria AS Categoria,
	i.stock AS Stock_Actual
	FROM productos AS p
	JOIN categorias AS c
	ON p.id_categoria = c.id_categoria
	JOIN inventario AS i
	ON i.id_producto = p.id_producto

GO

SELECT * FROM vw_prooductos_stock;

--4) Promociones aplicada

CREATE VIEW vw_promociones_aplicadas as
SELECT 
    v.id_venta AS IdVenta,
    c.nombres + ' ' + c.apellidos as cliente,
    pr.nombre_promocion as promocion,
    ISNULL(ROUND((SELECT SUM(dv.cantidad * dv.precio_unitario) 
	FROM detalle_venta dv WHERE dv.id_venta = v.id_venta) * (pr.porcentaje_descuento / 100.0), 2), 0) as descuento_aplicado,
    v.fecha_venta AS fecha_venta
FROM ventas v
JOIN clientes c ON v.id_cliente = c.id_cliente
JOIN promociones pr ON v.id_promocion = pr.id_promocion;
GO

-- 5) Devoluciones

CREATE VIEW vw_devoluciones AS
SELECT 
    d.id_devolucion AS IdDevolución,
    d.fecha_devolucion as fecha,
    c.nombres + ' ' + c.apellidos as cliente,
    p.nombre_producto as producto,
    d.cantidad as cantidad,
    d.motivo as motivo
FROM devoluciones d
JOIN productos p ON d.id_producto = p.id_producto
JOIN ventas v ON d.id_venta = v.id_venta
JOIN clientes c ON v.id_cliente = c.id_cliente;
GO

-- 6) desempeno vendedoress

CREATE VIEW v_DesempenoVendedores AS
SELECT 
    e.id_empleado AS IdEmpleado,
    e.nombres + ' ' + e.apellidos as nombre_empleado,
    COUNT(DISTINCT v.id_venta) as total_ventas,
    ISNULL(SUM(v.total_venta), 0) as monto,
    ISNULL((SELECT SUM(d.cantidad) FROM devoluciones d WHERE d.id_empleado = e.id_empleado), 0) as total_devoluciones
FROM empleados e
LEFT JOIN ventas v ON e.id_empleado = v.id_empleado
GROUP BY e.id_empleado, e.nombres, e.apellidos;
GO











