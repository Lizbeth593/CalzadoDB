-- Procedimientos Almacenados (Stored Procedures)

USE calzado_db;
GO

-- 1) Registrar Clientes
CREATE PROCEDURE sp_RegistrarCliente
    @nombres VARCHAR(100),
    @apellidos VARCHAR(100),
    @tipo_cliente VARCHAR(20),
    @cedula_ruc VARCHAR(13),
    @telefono VARCHAR(15),
    @email VARCHAR(100),
    @direccion VARCHAR(200),
    @id_ciudad INT
AS BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM clientes WHERE cedula_ruc = @cedula_ruc OR email = @email)
        BEGIN
            RAISERROR('El cliente con esa identificacion o correo ya existe.', 16, 1);
            RETURN;
        END

        INSERT INTO clientes (
            nombres, 
            apellidos, 
            tipo_cliente, 
            cedula_ruc, 
            telefono, 
            email, 
            direccion, 
            id_ciudad
        )
        VALUES (
            @nombres, 
            @apellidos, 
            @tipo_cliente, 
            @cedula_ruc, 
            @telefono, 
            @email, 
            @direccion, 
            @id_ciudad
        );

        PRINT 'Cliente registrado correctamente.';
    END TRY
    BEGIN CATCH
        RAISERROR('Error al registrar el cliente.', 16, 1);
    END CATCH
END;
GO

EXEC sp_RegistrarCliente 
    @nombres = 'Carlos',
    @apellidos = 'Mendoza',
    @tipo_cliente = 'Final',
    @cedula_ruc = '1725489630',
    @telefono = '0991234567',
    @email = 'carlos.mendoza@email.com',
    @direccion = 'Av. Amazonas y Colón',
    @id_ciudad = 1;
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

        INSERT INTO productos (nombre_producto, precio_unitario, id_categoria)
        VALUES (@nombre, @precio, @id_categoria);

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

EXEC sp_RegistrarProducto 
    @nombre = 'Zapato Deportivo Runner',
    @precio = 65.50,
    @stock = 25,
    @tipoProducto = 'Nacional',
    @id_categoria = 1,
    @id_sucursal = 1;
GO

-- 3) Registrar Ventas

ALTER PROCEDURE sp_RegistrarVenta
    @id_cliente INT,
    @id_empleado INT,
    @id_sucursal INT,
    @id_producto INT,
    @cantidad INT,
    @tipo_venta VARCHAR(20) = 'Minorista',  
    @forma_pago VARCHAR(30) = 'Efectivo',   
    @id_promocion INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @stock_actual INT;
        SELECT @stock_actual = stock 
        FROM inventario 
        WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;

        IF @stock_actual IS NULL OR @stock_actual < @cantidad
        BEGIN
            RAISERROR('No hay suficiente stock para realizar la venta.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        DECLARE @precio DECIMAL(10,2), @total DECIMAL(10,2), @id_vepnta INT;
        SELECT @precio = precio_unitario FROM productos WHERE id_producto = @id_producto;

        IF @precio IS NULL
        BEGIN
            RAISERROR('El producto especificado no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END

        SET @total = @precio * @cantidad;

        -- 3. Insertar la cabecera en la tabla ventas
        INSERT INTO ventas (
            id_cliente, 
            id_empleado, 
            id_sucursal, 
            id_promocion, 
            fecha_venta, 
            tipo_venta, 
            forma_pago, 
            total_venta
        )
        VALUES (
            @id_cliente, 
            @id_empleado, 
            @id_sucursal, 
            @id_promocion, 
            GETDATE(), 
            @tipo_venta, 
            @forma_pago, 
            @total
        );

        SET @id_venta = SCOPE_IDENTITY();

        INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario)
        VALUES (@id_venta, @id_producto, @cantidad, @precio);

        UPDATE inventario
        SET stock = stock - @cantidad
        WHERE id_producto = @id_producto AND id_sucursal = @id_sucursal;

        COMMIT TRANSACTION;
        PRINT 'Venta registrada con éxito.';
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION;

        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO


EXEC sp_RegistrarVenta 
    @id_cliente = 1,
    @id_empleado = 1,
    @id_sucursal = 1,
    @id_producto = 1,
    @cantidad = 2,
    @id_promocion = NULL;
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

EXEC sp_RegistrarDevolucion 
    @id_venta = 1,
    @id_producto = 1,
    @id_sucursal = 1,
    @id_empleado = 1,
    @cantidad = 1,
    @motivo = 'Talla incorrecta';
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

EXEC sp_AplicarPromocion 
    @id_promocion = 1,
    @monto = 120.00;
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


EXEC sp_CalcularVentasMensuales 
    @anio = 2026;
GO
-- 7) Registrar Proveedor

ALTER PROCEDURE sp_RegistrarProveedor
    @nombre_proveedor VARCHAR(120),
    @id_ciudad INT,                     
    @contacto VARCHAR(100) = NULL,
    @telefono VARCHAR(25) = NULL,
    @email VARCHAR(100) = NULL,
    @direccion VARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM proveedores WHERE nombre_proveedor = @nombre_proveedor)
        BEGIN
            RAISERROR('El proveedor ya se encuentra registrado.', 16, 1);
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM ciudades WHERE id_ciudad = @id_ciudad)
        BEGIN
            RAISERROR('La ciudad especificada no existe.', 16, 1);
            RETURN;
        END

        INSERT INTO proveedores (
            nombre_proveedor, 
            contacto, 
            telefono, 
            email, 
            direccion, 
            id_ciudad
        )
        VALUES (
            @nombre_proveedor, 
            @contacto, 
            @telefono, 
            @email, 
            @direccion, 
            @id_ciudad
        );

        PRINT 'Proveedor registrado correctamente.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

EXEC sp_RegistrarProveedor
    @nombre_proveedor = 'Calzados del Ecuador S.A.',
    @id_ciudad = 1,
    @contacto = 'Juan Perez',
    @telefono = '022345678',
    @email = 'contacto@calzadecu.com',
    @direccion = 'Zona Industrial Norte';
GO

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

EXEC sp_ActualizarInventario 
    @id_producto = 1,
    @id_sucursal = 1,
    @cantidad = 10,
    @tipo = 'incrementar';
GO

-- 9) Registrar Queja

ALTER PROCEDURE sp_RegistrarQueja
    @id_empleado INT,
    @tipo VARCHAR(20),
    @descripcion VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        DECLARE @detalle_completo VARCHAR(300);
        SET @detalle_completo = CONCAT('[', UPPER(@tipo), '] ', @descripcion);

        INSERT INTO historial_actividades (fecha, id_empleado, descripcion)
        VALUES (CAST(GETDATE() AS DATE), @id_empleado, @detalle_completo);

        PRINT 'Queja/Sugerencia registrada en el historial de actividades.';
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END;
GO

EXEC sp_RegistrarQueja
    @id_empleado = 1,
    @tipo = 'Reclamo',
    @descripcion = 'Cliente reporta demora en la entrega del producto.';
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

EXEC sp_RegistrarAuditoria
    @accion = 'INSERT',
    @usuario = 'admin_user',
    @tabla = 'productos';
GO