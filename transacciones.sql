-- TRANSACCIONES
USE calzado_db;
GO

--1) Venta Completa
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_cliente INT = 1;
    DECLARE @id_empleado INT = 1;
    DECLARE @id_sucursal INT = 1;
    DECLARE @id_producto INT = 1;
    DECLARE @cantidad INT = 2;
    DECLARE @id_promocion INT = 1;
    
    DECLARE @precio DECIMAL(10,2), @subtotal DECIMAL(10,2), @descuento DECIMAL(10,2) = 0, @total DECIMAL(10,2);
    
    -- Obtener precio del producto
    SELECT @precio = precio_unitario FROM productos WHERE id_producto = @id_producto;
    SET @subtotal = @precio * @cantidad;

    -- Verificar si aplica promoción
    IF @id_promocion IS NOT NULL
    BEGIN
        DECLARE @porcentaje INT;
        SELECT @porcentaje = porcentaje_descuento FROM promociones WHERE id_promocion = @id_promocion;
        IF @porcentaje IS NOT NULL 
            SET @descuento = (@subtotal * @porcentaje) / 100.0;
    END

    SET @total = @subtotal - @descuento;

    -- Registro venta
    INSERT INTO ventas (fecha_venta, total_venta, id_cliente, id_empleado, id_promocion)
    VALUES (GETDATE(), @total, @id_cliente, @id_empleado, @id_promocion);

    DECLARE @id_venta INT = SCOPE_IDENTITY();

    -- Registrar detalle
    INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (@id_venta, @id_producto, @cantidad, @precio);

    --Actualizar inventario
    UPDATE inventario
    SET stock = stock - @cantidad
    WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;

    COMMIT TRANSACTION;
    PRINT 'Transacción "Venta Completa" ejecutada con exito (COMMIT)';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error en la venta';
END CATCH;
GO

-- 2) Devolucion Completa

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_venta_dev INT = 1;
    DECLARE @id_producto_dev INT = 1;
    DECLARE @id_sucursal_dev INT = 1;
    DECLARE @id_empleado_dev INT = 1;
    DECLARE @cantidad_dev INT = 1;

    -- Registro Devolucion
    INSERT INTO devoluciones (fecha_devolucion, cantidad, motivo, id_venta, id_producto, id_empleado)
    VALUES (GETDATE(), @cantidad_dev, 'Talla incorrecta', @id_venta_dev, @id_producto_dev, @id_empleado_dev);

    -- Reingresar stock al inventario
    UPDATE inventario
    SET stock = stock + @cantidad_dev
    WHERE id_producto = @id_producto_dev AND id_sucursal = @id_sucursal_dev;

    COMMIT TRANSACTION;
    PRINT 'Devolución Completa realizada con exito';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error en devolucion';
END CATCH;
GO

--3) Compra a proveedor

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @id_proveedor INT = 1;
    DECLARE @id_producto_compra INT = 1;
    DECLARE @id_sucursal_compra INT = 1;
    DECLARE @cant_comprada INT = 50;
    DECLARE @precio_compra DECIMAL(10,2) = 25.00;
    DECLARE @total_compra DECIMAL(10,2) = @cant_comprada * @precio_compra;

    INSERT INTO compras (fecha_compra, total_compra, id_proveedor)
    VALUES (GETDATE(), @total_compra, @id_proveedor);

    DECLARE @id_compra INT = SCOPE_IDENTITY();

    -- registrar detalle de compra
    INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio_compra)
    VALUES (@id_compra, @id_producto_compra, @cant_comprada, @precio_compra);

    -- incrementar el stock en inventario
    UPDATE inventario
    SET stock = stock + @cant_comprada
    WHERE id_producto = @id_producto_compra AND id_sucursal = @id_sucursal_compra;

    COMMIT TRANSACTION;
    PRINT 'Compra a Proveedor exitosa';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al registrar la compra a proveedor';
END CATCH;
GO

--4) Actualizacion masiva inventario

BEGIN TRY
    BEGIN TRANSACTION;

    UPDATE inventario
    SET stock = stock + 10
    WHERE id_sucursal = 1;

    COMMIT TRANSACTION;
    PRINT 'Actualización Masiva exitosa ';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error en la actualizacion masiva';
END CATCH;
GO