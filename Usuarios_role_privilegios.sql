  --1) Crear Logins a nivel de servidor

USE [master]
GO

CREATE LOGIN login_admin WITH PASSWORD = 'Admin2026';
GO
CREATE LOGIN login_gerente WITH PASSWORD = 'Gerente2026';
GO
CREATE LOGIN login_cajero WITH PASSWORD = 'Cajero2026';
GO
CREATE LOGIN login_vendedor WITH PASSWORD = 'Vendedor2026';
GO
CREATE LOGIN login_auditor WITH PASSWORD = 'Auditor2026';
GO

--2) Crear usuario dentro de la base de datos 

USE [calzado_db]
GO

CREATE USER usuario_admin FOR LOGIN login_admin;
CREATE USER usuario_gerente FOR LOGIN login_gerente;
CREATE USER usuario_cajero FOR LOGIN login_cajero;
CREATE USER usuario_vendedor FOR LOGIN login_vendedor;
CREATE USER usuario_auditor FOR LOGIN login_auditor;

GO

--4) Creacion de Roles

CREATE ROLE rol_administrador;
CREATE ROLE rol_gerente;
CREATE ROLE rol_cajero;
CREATE ROLE rol_vendedor;


--5) Administrador 


GRANT SELECT TO rol_administrador;
GRANT INSERT TO rol_administrador;
GRANT UPDATE TO rol_administrador;
GRANT DELETE TO rol_administrador;

GRANT CREATE TABLE TO rol_administrador;
GRANT CREATE VIEW TO rol_administrador;
GRANT CREATE PROCEDURE TO rol_administrador;

GRANT ALTER TO rol_administrador;

ALTER ROLE rol_administrador ADD MEMBER usuario_admin;


--6) Gerente


GRANT SELECT ON dbo.ventas TO rol_gerente;
GRANT SELECT ON dbo.clientes TO rol_gerente;
GRANT SELECT ON dbo.productos TO rol_gerente;


ALTER ROLE rol_gerente ADD MEMBER usuario_gerente;


--7) Cajero


GRANT SELECT ON dbo.clientes TO rol_cajero;
GRANT SELECT ON dbo.productos TO rol_cajero;

GRANT INSERT ON dbo.ventas TO rol_cajero;
GRANT INSERT ON dbo.detalle_venta TO rol_cajero;

ALTER ROLE rol_cajero ADD MEMBER usuario_cajero;


-- 8) Vendedor

GRANT SELECT ON dbo.clientes TO rol_vendedor;
GRANT SELECT ON dbo.productos TO rol_vendedor;
GRANT SELECT ON dbo.ventas TO rol_vendedor;

ALTER ROLE rol_vendedor ADD MEMBER usuario_vendedor;

-- 9) Auditor 
CREATE ROLE rol_auditor;

GRANT SELECT ON historial_actividades TO rol_auditor;
DENY INSERT, UPDATE, DELETE ON historial_actividades TO rol_auditor;

ALTER ROLE rol_auditor ADD MEMBER usuario_auditor;
