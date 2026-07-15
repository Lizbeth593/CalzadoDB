--FUNCIONES

--1) Calcular IVA

CREATE FUNCTION calcular_iva 
(
@monto DECIMAL(10,2)
)

RETURNS DECIMAL(10,2)
AS
BEGIN
	
	DECLARE @iva DECIMAL(8,2);

	SET @iva = @monto * 0.15;

    RETURN @iva
END;
GO

SELECT dbo.calcular_iva(20) AS IVA;

--2) Calcular descuento

CREATE FUNCTION calcular_descuento (

	@monto DECIMAL(8,2),
	@porjentaje_descuento DECIMAL(8,2)

)
RETURNS DECIMAL(8,2)
AS
BEGIN
	DECLARE @descuento DECIMAL(8,2);

	SET @descuento = @monto * @porjentaje_descuento / 100;

	RETURN @descuento;

END;

SELECT dbo.calcular_descuento(200.00, 15) AS Descuento;


-- 3) Calcular edad

CREATE FUNCTION calcular_edad (
    @fecha_nacimiento DATE
)
RETURNS INT
AS
BEGIN
    DECLARE @edad INT;
    
    IF @fecha_nacimiento IS NULL
        SET @edad = 0;
    ELSE
        SET @edad = DATEDIFF(YEAR, @fecha_nacimiento, GETDATE()) - 
                    CASE 
                        WHEN (MONTH(@fecha_nacimiento) > MONTH(GETDATE())) OR 
                             (MONTH(@fecha_nacimiento) = MONTH(GETDATE()) AND DAY(@fecha_nacimiento) > DAY(GETDATE())) 
                        THEN 1 
                        ELSE 0 
                    END;
                    
    RETURN @edad;
END;
GO

-- 4) Calcular Comision

CREATE FUNCTION calcular_comision (
    @id_empleado INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total_ventas DECIMAL(10,2);
    DECLARE @comision DECIMAL(10,2);

    SELECT @total_ventas = SUM(total_venta) 
    FROM ventas 
    WHERE id_empleado = @id_empleado;

    IF @total_ventas IS NOT NULL
    BEGIN
        SET @comision = @total_ventas * 0.03;
    END

    RETURN @comision;
END;
GO

-- 5) Productos Bajo Stock

CREATE FUNCTION productos_bajo_stock (
    @stock_minimo INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        p.id_producto AS id_producto,
        p.nombre_producto AS nombre_producto,
        cat.nombre_categoria AS categoria,
        SUM(i.stock) AS StockActual
    FROM productos p
    JOIN categorias cat ON p.id_categoria = cat.id_categoria
    JOIN inventario i ON p.id_producto = i.id_producto
    GROUP BY p.id_producto, p.nombre_producto, cat.nombre_categoria
    HAVING SUM(i.stock) < @stock_minimo
);
GO

-- 6) Clientes frecuentes

CREATE FUNCTION clientes_frecuentes (
    @min_compras INT,
    @min_monto DECIMAL(10,2)
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        c.id_cliente as id_cliente,
        c.nombres + ' ' + c.apellidos AS cliente,
        COUNT(v.id_venta) as cantidad_compras,
        SUM(v.total_venta) as monto
    FROM clientes c
    JOIN ventas v ON c.id_cliente = v.id_cliente
    GROUP BY c.id_cliente, c.nombres, c.apellidos
    HAVING COUNT(v.id_venta) >= @min_compras 
       OR SUM(v.total_venta) >= @min_monto
);
GO


