-- Procedimientos Almacenados (Stored Procedures)

USE calzado_db;
GO

-- 1) Registrar Clientes
CREATE PROCEDURE sp_RegistrarCliente
    @identificacion VARCHAR(13),
    @nombres VARCHAR(100),
    @apellidos VARCHAR(100),
    @telefono VARCHAR(15),
    @correo VARCHAR(100)
AS BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM clientes WHERE identificacion = @identificacion OR correo = @correo)
        BEGIN
            RAISERROR('El cliente con esa identificacion o correo existe.', 16, 1);
            RETURN;
        END

        INSERT INTO clientes (identificacion, nombres, apellidos, telefono, correo)
        VALUES (@identificacion, @nombres, @apellidos, @telefono, @correo);

        PRINT 'Cliente registrado correctamente.';
    END TRY
    BEGIN CATCH
        RAISERROR('Error al registrar el cliente.', 16, 1);
    END CATCH
END;
GO

-- 2) Registrar Producto

CREATE PROCEDURE sp_RegistrarProducto
    @nombre VARCHAR(100),
    @precio DECIMAL(10,2),
    @stock INT,
    @tipoProducto VARCHAR(20), -- Nacional o Import
    @id_categoria INT,
    @id_sucursal INT
AS BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @id_prod INT;

        INSERT INTO productos (nombre_producto, precio_unitario, tipo_producto, id_categoria)
        VALUES (@nombre, @precio, @tipoProducto, @id_categoria);

        SET @id_prod = SCOPE_IDENTITY();

        INSERT INTO inventario (id_producto, id_sucursal, stock)
        VALUES (@id_prod, @id_sucursal, @stock);

        COMMIT TRANSACTION;
        PRINT 'Producto e inventario registrados correctamente.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Error al registrar el producto.', 16, 1);
    END CATCH
END;
GO

-- 3) Registrar Ventas

CREATE PROCEDURE sp_RegistrarVenta
    @id_cliente INT,
    @id_empleado INT,
    @id_sucursal INT,
    @id_producto INT,
    @cantidad INT,
    @id_promocion INT = NULL
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @stock_actual INT; -- stock disponible
        SELECT @stock_actual = stock FROM inventario WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;

        IF @stock_actual IS NULL OR @stock_actual < @cantidad
        BEGIN
            RAISERROR('No hay suficiente stock para realizar la venta.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @precio DECIMAL(10,2), @total DECIMAL(10,2), @id_venta INT;
        SELECT @precio = precio_unitario FROM productos WHERE id_producto = @id_producto;
        SET @total = @precio * @cantidad;

        INSERT INTO ventas (fecha_venta, total_venta, id_cliente, id_empleado, id_promocion)
        VALUES (GETDATE(), @total, @id_cliente, @id_empleado, @id_promocion);

        SET @id_venta = SCOPE_IDENTITY();

        INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
        VALUES (@id_venta, @id_producto, @cantidad, @precio);

        UPDATE inventario
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;

        COMMIT TRANSACTION;
        PRINT 'Venta registrada con exito';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Error al procesar la venta', 16, 1);
    END CATCH
END;
GO

-- 4) Registro Devolucion 
CREATE PROCEDURE sp_RegistrarDevolucion
    @id_venta INT,
    @id_producto INT,
    @id_sucursal INT,
    @id_empleado INT,
    @cantidad INT,
    @motivo VARCHAR(255)
AS BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO devoluciones (fecha_devolucion, cantidad, motivo, id_venta, id_producto, id_empleado)
        VALUES (GETDATE(), @cantidad, @motivo, @id_venta, @id_producto, @id_empleado);

        -- Incrementar stock
        UPDATE inventario
        SET stock = stock + @cantidad
        WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;

        COMMIT TRANSACTION;
        PRINT 'Devolucipn registrada';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        RAISERROR('Error al registrar la devolucion.', 16, 1);
    END CATCH
END;
GO

-- 5) Aplicar Promo

CREATE PROCEDURE sp_AplicarPromocion
    @id_promocion INT,
    @monto DECIMAL(10,2)
AS BEGIN
    BEGIN TRY
        DECLARE @porcentaje INT;
        SELECT @porcentaje = porcentaje_descuento FROM promociones WHERE id_promocion = @id_promocion;

        IF @porcentaje IS NOT NULL
        BEGIN
            SELECT @monto AS MontoOriginal, 
                   (@monto * @porcentaje / 100.0) AS DescuentoCalculado,
                   (@monto - (@monto * @porcentaje / 100.0)) AS TotalConDescuento;
        END
        ELSE
        BEGIN
            RAISERROR('La promocion no existe', 16, 1);
        END
    END TRY
    BEGIN CATCH
        RAISERROR('Error al calcular la promocion.', 16, 1);
    END CATCH
END;
GO

-- 6) Calcular Ventas Mensuales
CREATE PROCEDURE sp_CalcularVentasMensuales
    @anio INT
AS BEGIN
    BEGIN TRY
        SELECT 
            MONTH(fecha_venta) AS Mes, 
            COUNT(id_venta) AS TotalTransacciones,
            SUM(total_venta) AS TotalVentas
        FROM ventas
        WHERE YEAR(fecha_venta) = @anio
        GROUP BY MONTH(fecha_venta);
    END TRY
    BEGIN CATCH
        RAISERROR('Error al calcular las ventas mensuales.', 16, 1);
    END CATCH
END;
GO

-- 7) Registrar Proveedor
CREATE PROCEDURE sp_RegistrarProveedor
    @ruc VARCHAR(13),
    @nombre VARCHAR(100),
    @telefono VARCHAR(15),
    @correo VARCHAR(100),
    @direccion VARCHAR(200)
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM proveedores WHERE ruc = @ruc)
        BEGIN
            RAISERROR('El RUC del proveedor ya esta registrado.', 16, 1);
            RETURN;
        END

        INSERT INTO proveedores (ruc, nombre_proveedor, telefono, correo, direccion)
        VALUES (@ruc, @nombre, @telefono, @correo, @direccion);

        PRINT 'Proveedor registrado correctamente.';
    END TRY
    BEGIN CATCH
        RAISERROR('Error al registrar el proveedor.', 16, 1);
    END CATCH
END;

-- 8)  Actualizar Inventario
CREATE PROCEDURE sp_ActualizarInventario
    @id_producto INT,
    @id_sucursal INT,
    @cantidad INT,
    @tipo VARCHAR(20) -- incrementar /disminuir
AS
BEGIN
    BEGIN TRY
        IF @tipo = 'incrementar'
        BEGIN
            UPDATE inventario 
            SET stock = stock + @cantidad 
            WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;
        END
        ELSE IF @tipo = 'disminuir'
        BEGIN
            UPDATE inventario 
            SET stock = stock - @cantidad 
            WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;
        END
        ELSE
        BEGIN
            RAISERROR('Tipo de movimiento invalido', 16, 1);
            RETURN;
        END

        PRINT 'Inventario actualizado';
    END TRY
    BEGIN CATCH
        RAISERROR('Error al actualizar el inventario.', 16, 1);
    END CATCH
END;
GO

-- 9) Registrar Queja
CREATE PROCEDURE sp_RegistrarQueja
    @id_cliente INT,
    @tipo VARCHAR(20), -- reclamo/ sug3rencia
    @descripcion VARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        INSERT INTO quejas_sugerencias (fecha_registro, tipo, descripcion, id_cliente)
        VALUES (GETDATE(), @tipo, @descripcion, @id_cliente);

        PRINT 'Queja/Sugerencia registrada exitosamente.';
    END TRY
    BEGIN CATCH
        RAISERROR('Error al registrar la queja o sugerencia.', 16, 1);
    END CATCH
END;
GO

-- 10) Registro Auditoria

CREATE PROCEDURE sp_RegistrarAuditoria
    @accion VARCHAR(50),
    @usuario VARCHAR(50),
    @tabla VARCHAR(50)
AS
BEGIN
    BEGIN TRY
        INSERT INTO auditoria (accion, usuario, fecha_accion, tabla_afectada)
        VALUES (@accion, @usuario, GETDATE(), @tabla);

        PRINT 'Registro de auditoria guardado';
    END TRY
    BEGIN CATCH
        RAISERROR('Error al guardar la auditoria', 16, 1);
    END CATCH
END;
GO