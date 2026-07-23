use calzado_db;
--1) Listado de clientes 

SELECT 
	c.id_cliente,
	c.nombres,
	c.apellidos,
	c.telefono,
	c.email,
	ci.nombre_ciudad AS ciudad
	FROM clientes AS c
	JOIN ciudades AS ci
	ON c.id_ciudad = ci.id_ciudad;

--2) Productos disponibles

SELECT * FROM productos;

SELECT 
	p.id_producto,
	p.nombre_producto,
	p.precio_venta_mayor,
	p.precio_unitario,
	i.stock
	FROM productos AS p
	JOIN inventario AS i
	ON p.id_producto = i.id_producto;

--3) Ventas por fecha

SELECT * FROM detalle_venta;

	SELECT 
		v.id_venta,
		v.fecha_venta,
		c.nombres + ' ' + c.apellidos AS Cliente,
		v.total_venta 
		FROM ventas AS v
		JOIN clientes AS c
		ON v.id_cliente = c.id_cliente;

-- 4) Proveedores registrados

SELECT * FROM proveedores;

	SELECT 
		p.id_proveedor,
		p.nombre_proveedor,
		c.pais,
		p.telefono
		FROM proveedores AS p
		JOIN ciudades AS c
		ON p.id_ciudad = c.id_ciudad

--5) Empleados por cargo

SELECT * FROM empleados;

	SELECT 
		e.id_empleado,
		e.nombres + ' ' + e.apellidos AS Nombre_empleado,
		e.cargo,
		e.salario
		FROM empleados AS e;

--6) Clientes coon sus compras 

	SELECT 
		c.nombres + ' ' + c.apellidos AS Cliente,
		v.fecha_venta,
		v.total_venta,
		v.tipo_venta
		FROM clientes AS c
		JOIN ventas AS v
		ON c.id_cliente = v.id_cliente;

--7) Ventas con vendedor

	SELECT 
		v.id_venta,
		c.nombres + ' ' + c.apellidos AS Cliente,
		e.nombres + ' ' + e.apellidos AS Vendedor,
		v.fecha_venta,
		v.total_venta

		FROM ventas AS v
		JOIN clientes AS c
		ON v.id_cliente = c.id_cliente
		JOIN empleados AS e
		ON v.id_empleado = e.id_empleado;

--8) Detalle productos vendidos 

	SELECT 
		dv.id_venta,
		p.nombre_producto,
		dv.cantidad,
		dv.precio_unitario,
		dv.cantidad * dv.precio_unitario AS Subtotal
		FROM detalle_venta AS dv
		JOIN productos AS p
		ON dv.id_producto = p.id_producto;

--9) Productos con proveedores

	SELECT 
		p.nombre_producto,
		c.nombre_categoria AS tipo_producto,
		pr.nombre_proveedor,
		ci.pais AS Pais_proveedor
		FROM productos AS p
		JOIN categorias AS c
		ON p.id_categoria = c.id_categoria
		JOIN proveedores AS pr
		ON p.id_proveedor = pr.id_proveedor
		JOIN ciudades AS ci
		ON pr.id_ciudad = ci.id_ciudad;


--10) Devoluciones con cliente y producto

	SELECT 
		c.nombres + ' ' + c.apellidos AS cliente,
		p.nombre_producto,
		d.fecha_devolucion,
		d.motivo,
		d.cantidad
		FROM devoluciones AS d
		JOIN productos AS p
		ON d.id_producto = p.id_producto
		JOIN proveedores AS pr
		ON pr.id_proveedor = p.id_proveedor
		JOIN ciudades AS ci
		ON pr.id_ciudad = ci.id_ciudad
		JOIN clientes AS c
		ON ci.id_ciudad = c.id_ciudad;
		

--11) Total vendido por vendedor 
	
	SELECT
		e.nombres+' '+e.apellidos as vendedor,
		COUNT(v.id_venta) as cantidad_venta,
		SUM(v.total_venta) as total_vendido
		FROM empleados e
		JOIN ventas v ON e.id_empleado = v.id_empleado
		GROUP BY e.nombres, e.apellidos;

--12) Productos más vendidos 

	SELECT
		p.nombre_producto as producto,
		SUM(dv.cantidad) as unidades_vendidas
		FROM productos p 
		JOIN detalle_venta dv ON dv.id_producto = p.id_producto
		GROUP BY p.nombre_producto;

--13) Ventas por mes 
	
	SELECT
		DATENAME(MONTH, v.fecha_venta) as mes,
		COUNT(v.id_venta) as total_ventas,
		SUM(v.total_venta) as monto_total
		FROM Ventas v
		GROUP BY DATENAME(MONTH, v.fecha_venta), MONTH(v.fecha_venta)
		ORDER BY MONTH(v.fecha_venta)

--14) Compras por cliente 
	
	SELECT
		c.nombres+' '+c.apellidos as cliente,
		COUNT(v.id_venta) as cantidad_compras,
		SUM(v.total_venta) as monto_acumulado
		FROM clientes c
		JOIN ventas v ON c.id_cliente = v.id_cliente
		GROUP BY c.nombres, c.apellidos;

--15) Devoluciones por vendedor 
	
	SELECT 
		e.nombres + ' ' + e.apellidos as vendedor,
		SUM(d.cantidad) as total_devoluciones
		FROM empleados e
		JOIN devoluciones d ON e.id_empleado = d.id_empleado
		GROUP BY e.nombres, e.apellidos;

--16) Clientes con compras superiores al promedio 

	SELECT 
		c.nombres + ' ' + c.apellidos AS cliente,
		SUM(v.total_venta) as total_comprado
		FROM clientes as c
		JOIN ventas as v ON c.id_cliente = v.id_cliente
		GROUP BY c.nombres, c.apellidos
		HAVING SUM(v.total_venta) > (SELECT AVG(total_venta) FROM ventas);

--17) Productos con precio mayor al promedio 

	SELECT 
		p.nombre_producto AS Producto,
		p.precio_unitario AS Precio
		FROM productos AS p
		WHERE p.precio_unitario > (SELECT AVG(precio_unitario) FROM productos);

--18) Vendedores con ventas superiores al promedio 

	SELECT 
		e.nombres + ' ' + e.apellidos AS Vendedor,
		SUM(v.total_venta) AS TotalVendido
		FROM empleados AS e
		JOIN ventas AS v
		ON e.id_empleado = v.id_empleado
		GROUP BY e.nombres, e.apellidos
		HAVING SUM(v.total_venta) > (SELECT AVG(total_venta) FROM ventas);

--19) Productos que nunca se han vendido 
	
	SELECT 
		p.id_producto AS IdProducto,
		p.nombre_producto AS NombreProducto,
		ISNULL(SUM(i.stock), 0) AS StockActual
		FROM productos AS p
		LEFT JOIN inventario AS i 
		ON p.id_producto = i.id_producto
		WHERE p.id_producto NOT IN (SELECT DISTINCT id_producto FROM detalle_venta)
		GROUP BY p.id_producto, p.nombre_producto;

--20) Clientes que no han realizado compras 
	
	SELECT 
		c.id_cliente AS IdCliente,
		c.nombres AS Nombres,
		c.apellidos AS Apellidos,p
		c.telefono AS Teléfono
		FROM clientes AS c
		WHERE c.id_cliente NOT IN (SELECT DISTINCT id_cliente FROM ventas);p