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
		ON pr.id_proveedor = pr.id_proveedor
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
		