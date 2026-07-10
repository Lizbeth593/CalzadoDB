  --1) Crear Logins a nivel de servidor

USE [master]
GO

CREATE LOGIN usuario_admin WITH PASSWORD = 'Admin2026';
GO
CREATE LOGIN usuario_gerente WITH PASSWORD = 'Gerente2026';
GO
CREATE LOGIN usuario_cajero WITH PASSWORD = 'Cajero2026';
GO

--2) Crear usuario dentro de la base de datos 

USE [calzado_db]
GO

CREATE USER usuario_admin FOR LOGIN usuario_admin;
CREATE USER usuario_gerente FOR LOGIN usuario_gerente;
CREATE USER usuario_cajero FOR LOGIN usuario_cajero;
GO

--3) Administrador 

CREATE ROLE rol_administrador;

GRANT SELECT TO rol_administrador;
GRANT INSERT TO rol_administrador;
GRANT UPDATE TO rol_administrador;
GRANT DELETE TO rol_administrador;

GRANT CREATE TABLE TO rol_administrador;
GRANT CREATE VIEW TO rol_administrador;
GRANT CREATE PROCEDURE TO rol_administrador;

GRANT ALTER TO rol_administrador;

ALTER ROLE rol_administrador ADD MEMBER usuario_admin;


--4) Gerente

CREATE ROLE rol_gerente;

GRANT SELECT ON dbo.ventas TO rol_gerente;
GRANT SELECT ON dbo.clientes TO rol_gerente;
GRANT SELECT ON dbo.productos TO rol_gerente;


ALTER ROLE rol_gerente ADD MEMBER usuario_gerente;


--5) Cajero

CREATE ROLE rol_cajero;

GRANT SELECT ON dbo.clientes TO rol_cajero;
GRANT SELECT ON dbo.productos TO rol_cajero;

GRANT INSERT ON dbo.ventas TO rol_cajero;
GRANT INSERT ON dbo.detalle_venta TO rol_cajero;

ALTER ROLE rol_cajero ADD MEMBER usuario_cajero;


