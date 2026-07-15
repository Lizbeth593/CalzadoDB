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