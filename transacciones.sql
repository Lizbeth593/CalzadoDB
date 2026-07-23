USE calzado_db;

--Transacciones 
--1) Venta Completa 

BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO ventas (id_cliente, id_empleado, id_sucursal, fecha_venta, tipo_venta, forma_pago, total_venta)
    VALUES (1, 1, 1, GETDATE(), 'Minorista', 'Efectivo', 200.90);

    INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
    VALUES (SCOPE_IDENTITY(), 1, 5, 40.18);
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	PRINT 'Error al registrar la venta: ' + ERROR_MESSAGE();
END CATCH;

--2. Devolución Completa

BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO devoluciones (id_venta, id_producto, id_empleado, cantidad, motivo, fecha_devolucion)
    VALUES (1, 14, 1, 2, 'Talla incorrecta', GETDATE());

    UPDATE inventario 
	SET stock = stock + 2 
	WHERE id_producto = 14 AND id_sucursal = 1;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	PRINT 'Error al registrar la devolucion: ' + ERROR_MESSAGE();

END CATCH;

--3. Compra a Proveedor

BEGIN TRY
    BEGIN TRANSACTION;
    INSERT INTO movimientos_inventario (id_producto, id_sucursal, id_empleado, tipo_movimiento, cantidad, motivo, fecha_movimiento)
    VALUES (3, 1, 1, 'Entrada', 50, 'Compra a proveedor', GETDATE());

    UPDATE inventario 
	SET stock = stock + 50 
	WHERE id_producto = 3 AND id_sucursal = 1;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
	PRINT 'Error al registrar la compra: ' + ERROR_MESSAGE();

END CATCH;

-- 4. Actualización Masiva de Inventario (ACID)

BEGIN TRY
    BEGIN TRANSACTION;
    UPDATE inventario 
	SET stock = stock + 10 
	WHERE id_sucursal = 1;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error en la actualizacion masiva: ' + ERROR_MESSAGE();

END CATCH;
