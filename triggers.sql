-- TRIGGERS
--Nueva tabla para el registro de los tgr

USE calzado_db;

CREATE TABLE auditoria_clientes (
    id_auditoria     INT IDENTITY(1,1) CONSTRAINT pk_auditoria_clientes PRIMARY KEY,
    id_cliente       INT            NOT NULL,
    accion           VARCHAR(10)    NOT NULL,
    campo_modificado VARCHAR(50)    NULL,
    valor_anterior   VARCHAR(200)   NULL,
    valor_nuevo      VARCHAR(200)   NULL,
    usuario          VARCHAR(100)   NOT NULL CONSTRAINT df_auditoria_clientes_usuario DEFAULT SYSTEM_USER,
    fecha_accion     DATETIME       NOT NULL CONSTRAINT df_auditoria_clientes_fecha DEFAULT GETDATE()
);

--1) Auditoria INSERT Clientes
--Telefono 
CREATE TRIGGER trg_clientes_insert
ON clientes
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO auditoria_clientes (id_cliente, accion, valor_nuevo)
    SELECT
        i.id_cliente,
        'INSERT',
        i.telefono
    FROM inserted AS i;
END;
GO

select * from clientes;

--2) Auditorias UPDATE Clientes 
CREATE TRIGGER trg_clientes_update_email
ON clientes
AFTER UPDATE
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO auditoria_clientes
        (id_cliente, accion, campo_modificado, valor_anterior, valor_nuevo)

    SELECT
        i.id_cliente,
        'UPDATE',
        'email',
        d.email,
        i.email
    FROM inserted i
    INNER JOIN deleted d 
        ON i.id_cliente = d.id_cliente
    WHERE d.email <> i.email;
END;
GO


--3)Audiotira DELETE Clientes

-- ----- 3. Auditoria DELETE en clientes -----
CREATE TRIGGER trg_clientes_delete
ON clientes
AFTER DELETE
AS
BEGIN
	SET NOCOUNT ON;
    INSERT INTO auditoria_clientes
        (id_cliente, accion, campo_modificado, valor_anterior)

    SELECT
        d.id_cliente,
        'DELETE',
        'cliente',
        d.nombres
    FROM deleted d;
END;
GO

--4) Desconectar Stock por Venta 

CREATE TRIGGER trg_descontar_stock_venta
ON detalle_venta
AFTER INSERT
AS
BEGIN
	SET NOCOUNT ON;
    UPDATE i
    SET i.stock = i.stock - ins.cantidad
    FROM inventario AS i
    INNER JOIN inserted AS ins
	ON ins.id_producto = i.id_producto
    INNER JOIN ventas AS v 
	ON v.id_venta = ins.id_venta
    WHERE i.id_sucursal = v.id_sucursal;
END;
GO

--5) Incrementar stock por devolucion

CREATE TRIGGER trg_IncrementarStockPorDevolucion
ON devoluciones
AFTER INSERT
AS BEGIN
    UPDATE i
    SET i.stock = i.stock + ins.cantidad
    FROM inventario i
    INNER JOIN inserted ins ON i.id_producto = ins.id_producto;
END;
GO

--6) Control stock negativo

CREATE TRIGGER trg_ControlStockNegativo
ON inventario
AFTER INSERT, UPDATE
AS BEGIN
    IF EXISTS (SELECT 1 FROM inserted WHERE stock < 0)
    BEGIN
        RAISERROR('Error: El stock de un producto no puede ser menor a cero', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- 7) Registro de cambio de precio

CREATE TRIGGER trg_RegistroCambioPrecio
ON productos
AFTER UPDATE
AS BEGIN
    IF UPDATE(precio_unitario)
    BEGIN
        INSERT INTO auditoria (accion, usuario, fecha_accion, tabla_afectada)
        SELECT 
            'CAMBIO PRECIO: Anterior $' + CAST(d.precio_unitario AS VARCHAR) + ' / Nuevo $' + CAST(i.precio_unitario AS VARCHAR),
            SYSTEM_USER,
            GETDATE(),
            'productos'
        FROM inserted i
        JOIN deleted d ON i.id_producto = d.id_producto;
    END
END;
GO

-- 8) Registro de aacceso

CREATE TRIGGER trg_RegistroAcceso
ON auditoria
AFTER INSERT
AS
BEGIN
    INSERT INTO auditoria (accion, usuario, fecha_accion, tabla_afectada)
    VALUES ('Acceso al sistema - Hora: ' + CAST(CAST(GETDATE() AS TIME) AS VARCHAR(8)), SYSTEM_USER, GETDATE(), 'auditoria'
    );
END;
GO