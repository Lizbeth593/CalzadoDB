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

--3) Calcular total vendido por sucursal 


CREATE FUNCTION total_ventas_sucursal
(
    @id_sucursal INT
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        s.nombre_sucursal,
        SUM(v.total_venta) AS total_ventas
    FROM sucursales AS s
    INNER JOIN ventas AS v
    ON s.id_sucursal = v.id_sucursal
    WHERE s.id_sucursal = @id_sucursal
    GROUP BY s.nombre_sucursal
);
GO

SELECT * FROM dbo.total_ventas_sucursal(1);








