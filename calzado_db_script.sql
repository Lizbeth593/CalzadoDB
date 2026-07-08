
CREATE DATABASE calzado_db;
GO

USE calzado_db;
GO

-- =====================================================================
-- 1. TABLA ciudades
-- =====================================================================
CREATE TABLE ciudades (
    id_ciudad     INT IDENTITY(1,1) CONSTRAINT pk_ciudades PRIMARY KEY,
    nombre_ciudad VARCHAR(60) NOT NULL,
    provincia     VARCHAR(60) NOT NULL,
    pais          VARCHAR(50) NOT NULL
);
GO

-- =====================================================================
-- 2. TABLA categorias
-- =====================================================================
CREATE TABLE categorias (
    id_categoria     INT IDENTITY(1,1) CONSTRAINT pk_categorias PRIMARY KEY,
    nombre_categoria VARCHAR(60) NOT NULL,
    descripcion      VARCHAR(200) NULL
);
GO

-- =====================================================================
-- 3. TABLA proveedores
-- =====================================================================
CREATE TABLE proveedores (
    id_proveedor     INT IDENTITY(1,1) CONSTRAINT pk_proveedores PRIMARY KEY,
    nombre_proveedor VARCHAR(120) NOT NULL,
    contacto         VARCHAR(100) NULL,
    telefono         VARCHAR(25) NULL,
    email            VARCHAR(100) NULL,
    direccion        VARCHAR(150) NULL,
    id_ciudad        INT NOT NULL,
    CONSTRAINT fk_proveedores_ciudades FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
);
GO

-- =====================================================================
-- 4. TABLA sucursales (soporte logistico / distribucion nacional)
-- =====================================================================
CREATE TABLE sucursales (
    id_sucursal     INT IDENTITY(1,1) CONSTRAINT pk_sucursales PRIMARY KEY,
    nombre_sucursal VARCHAR(100) NOT NULL,
    id_ciudad       INT NOT NULL,
    direccion       VARCHAR(150) NULL,
    telefono        VARCHAR(25) NULL,
    CONSTRAINT fk_sucursales_ciudades FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
);
GO

-- =====================================================================
-- 5. TABLA productos
-- =====================================================================
CREATE TABLE productos (
    id_producto        INT IDENTITY(1,1) CONSTRAINT pk_productos PRIMARY KEY,
    nombre_producto    VARCHAR(120) NOT NULL,
    id_categoria       INT NOT NULL,
    id_proveedor       INT NOT NULL,
    talla              VARCHAR(15) NULL,
    color              VARCHAR(40) NULL,
    material           VARCHAR(60) NULL,
    precio_compra      DECIMAL(10,2) NOT NULL,
    precio_venta_mayor DECIMAL(10,2) NOT NULL,
    precio_venta_menor DECIMAL(10,2) NOT NULL,
    estado             VARCHAR(20) NOT NULL CONSTRAINT df_productos_estado DEFAULT 'Activo',
    CONSTRAINT fk_productos_categorias FOREIGN KEY (id_categoria) REFERENCES categorias(id_categoria),
    CONSTRAINT fk_productos_proveedores FOREIGN KEY (id_proveedor) REFERENCES proveedores(id_proveedor)
);
GO

-- =====================================================================
-- 6. TABLA clientes
-- =====================================================================
CREATE TABLE clientes (
    id_cliente     INT IDENTITY(1,1) CONSTRAINT pk_clientes PRIMARY KEY,
    nombres        VARCHAR(60) NOT NULL,
    apellidos      VARCHAR(60) NOT NULL,
    tipo_cliente   VARCHAR(20) NOT NULL,
    cedula_ruc     VARCHAR(13) NULL,
    telefono       VARCHAR(25) NULL,
    email          VARCHAR(100) NULL,
    direccion      VARCHAR(150) NULL,
    id_ciudad      INT NOT NULL,
    fecha_registro DATE NOT NULL CONSTRAINT df_clientes_fecha_registro DEFAULT GETDATE(),
    CONSTRAINT fk_clientes_ciudades FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad),
    CONSTRAINT ck_clientes_tipo CHECK (tipo_cliente IN ('Mayorista','Minorista'))
);
GO

-- =====================================================================
-- 7. TABLA empleados
-- =====================================================================
CREATE TABLE empleados (
    id_empleado        INT IDENTITY(1,1) CONSTRAINT pk_empleados PRIMARY KEY,
    nombres            VARCHAR(60) NOT NULL,
    apellidos          VARCHAR(60) NOT NULL,
    cargo              VARCHAR(60) NOT NULL,
    id_sucursal        INT NOT NULL,
    telefono           VARCHAR(25) NULL,
    email              VARCHAR(100) NULL,
    fecha_contratacion DATE NOT NULL,
    salario            DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_empleados_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal)
);
GO

-- =====================================================================
-- 8. TABLA promociones
-- =====================================================================
CREATE TABLE promociones (
    id_promocion         INT IDENTITY(1,1) CONSTRAINT pk_promociones PRIMARY KEY,
    nombre_promocion     VARCHAR(120) NOT NULL,
    descripcion          VARCHAR(200) NULL,
    porcentaje_descuento DECIMAL(5,2) NOT NULL,
    fecha_inicio         DATE NOT NULL,
    fecha_fin            DATE NOT NULL,
    estado               VARCHAR(20) NOT NULL CONSTRAINT df_promociones_estado DEFAULT 'Activa',
    CONSTRAINT ck_promociones_fechas CHECK (fecha_fin >= fecha_inicio)
);
GO

-- =====================================================================
-- 9. TABLA ventas
-- =====================================================================
CREATE TABLE ventas (
    id_venta     INT IDENTITY(1,1) CONSTRAINT pk_ventas PRIMARY KEY,
    id_cliente   INT NOT NULL,
    id_empleado  INT NOT NULL,
    id_sucursal  INT NOT NULL,
    id_promocion INT NULL,
    fecha_venta  DATE NOT NULL,
    tipo_venta   VARCHAR(20) NOT NULL,
    forma_pago   VARCHAR(30) NOT NULL,
    total_venta  DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_ventas_clientes FOREIGN KEY (id_cliente) REFERENCES clientes(id_cliente),
    CONSTRAINT fk_ventas_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT fk_ventas_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
    CONSTRAINT fk_ventas_promociones FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion),
    CONSTRAINT ck_ventas_tipo CHECK (tipo_venta IN ('Mayorista','Minorista'))
);
GO

-- =====================================================================
-- 10. TABLA detalle_venta
-- =====================================================================
CREATE TABLE detalle_venta (
    id_detalle_venta INT IDENTITY(1,1) CONSTRAINT pk_detalle_venta PRIMARY KEY,
    id_venta         INT NOT NULL,
    id_producto      INT NOT NULL,
    cantidad         INT NOT NULL,
    precio_unitario  DECIMAL(10,2) NOT NULL,
    subtotal         AS (CAST(cantidad * precio_unitario AS DECIMAL(10,2))) PERSISTED,
    CONSTRAINT fk_detalle_venta_ventas FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    CONSTRAINT fk_detalle_venta_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO

-- =====================================================================
-- 11. TABLA inventario
-- =====================================================================
CREATE TABLE inventario (
    id_inventario         INT IDENTITY(1,1) CONSTRAINT pk_inventario PRIMARY KEY,
    id_producto           INT NOT NULL,
    id_sucursal           INT NOT NULL,
    stock                 INT NOT NULL CONSTRAINT df_inventario_stock DEFAULT 0,
    stock_minimo          INT NOT NULL CONSTRAINT df_inventario_stock_minimo DEFAULT 5,
    ultima_actualizacion  DATETIME NOT NULL CONSTRAINT df_inventario_fecha DEFAULT GETDATE(),
    CONSTRAINT fk_inventario_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_inventario_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
    CONSTRAINT uq_inventario_producto_sucursal UNIQUE (id_producto, id_sucursal)
);
GO

-- =====================================================================
-- 12. TABLA movimientos_inventario (kardex / logistica)
-- =====================================================================
CREATE TABLE movimientos_inventario (
    id_movimiento    INT IDENTITY(1,1) CONSTRAINT pk_movimientos_inventario PRIMARY KEY,
    id_producto      INT NOT NULL,
    id_sucursal      INT NOT NULL,
    id_empleado      INT NOT NULL,
    tipo_movimiento  VARCHAR(20) NOT NULL,
    cantidad         INT NOT NULL,
    motivo           VARCHAR(200) NULL,
    fecha_movimiento DATETIME NOT NULL,
    CONSTRAINT fk_mov_inv_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_mov_inv_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
    CONSTRAINT fk_mov_inv_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado),
    CONSTRAINT ck_mov_inv_tipo CHECK (tipo_movimiento IN ('Entrada','Salida'))
);
GO

-- =====================================================================
-- 13. TABLA devoluciones
-- =====================================================================
CREATE TABLE devoluciones (
    id_devolucion    INT IDENTITY(1,1) CONSTRAINT pk_devoluciones PRIMARY KEY,
    id_venta         INT NOT NULL,
    id_producto      INT NOT NULL,
    id_empleado      INT NOT NULL,
    cantidad         INT NOT NULL,
    motivo           VARCHAR(200) NOT NULL,
    fecha_devolucion DATETIME NOT NULL,
    estado           VARCHAR(20) NOT NULL CONSTRAINT df_devoluciones_estado DEFAULT 'Procesada',
    CONSTRAINT fk_devoluciones_ventas FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    CONSTRAINT fk_devoluciones_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_devoluciones_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);
GO

-- =====================================================================
-- 14. TABLA auditoria (trazabilidad de cambios criticos)
-- =====================================================================
CREATE TABLE auditoria (
    id_auditoria   INT IDENTITY(1,1) CONSTRAINT pk_auditoria PRIMARY KEY,
    tabla_afectada VARCHAR(60) NOT NULL,
    accion         VARCHAR(20) NOT NULL,
    usuario_bd     VARCHAR(60) NOT NULL,
    fecha_hora     DATETIME NOT NULL,
    detalle        VARCHAR(300) NULL,
    CONSTRAINT ck_auditoria_accion CHECK (accion IN ('INSERT','UPDATE','DELETE'))
);
GO

-- =====================================================================
-- CARGA DE DATOS
-- =====================================================================

-- ----- ciudades (15) -----
INSERT INTO ciudades (nombre_ciudad, provincia, pais) VALUES
('Quito', 'Pichincha', 'Ecuador'),
('Guayaquil', 'Guayas', 'Ecuador'),
('Cuenca', 'Azuay', 'Ecuador'),
('Ambato', 'Tungurahua', 'Ecuador'),
('Manta', 'Manabi', 'Ecuador'),
('Loja', 'Loja', 'Ecuador'),
('Riobamba', 'Chimborazo', 'Ecuador'),
('Ibarra', 'Imbabura', 'Ecuador'),
('Machala', 'El Oro', 'Ecuador'),
('Santo Domingo', 'Santo Domingo de los Tsachilas', 'Ecuador'),
('Guangzhou', 'Guangdong', 'China'),
('Yiwu', 'Zhejiang', 'China'),
('Shenzhen', 'Guangdong', 'China'),
('Wenzhou', 'Zhejiang', 'China'),
('Quanzhou', 'Fujian', 'China');
GO

-- ----- categorias (5) -----
INSERT INTO categorias (nombre_categoria, descripcion) VALUES
('Zapatos Casuales', 'Calzado de uso diario para hombre y mujer'),
('Zapatos Deportivos', 'Calzado deportivo y para actividad fisica'),
('Botas', 'Botas de cuero y sinteticas para todo tipo de clima'),
('Sandalias', 'Calzado abierto de uso casual y playero'),
('Zapatos Formales', 'Calzado de vestir para hombre y mujer');
GO

-- ----- proveedores (10) -----
INSERT INTO proveedores (nombre_proveedor, contacto, telefono, email, direccion, id_ciudad) VALUES
('Curtiembre Tungurahua S.A.', 'Carlos Nunez', '032845112', 'ventas@curtiembretn.ec', 'Av. Cevallos 12-45', 4),
('Cueros del Austro Cia. Ltda.', 'Maria Ochoa', '072456781', 'contacto@cuerosaustro.ec', 'Parque Industrial s/n', 3),
('Distribuidora Textil Quito', 'Andres Salazar', '022987654', 'info@textilquito.ec', 'Av. Eloy Alfaro 34-20', 1),
('Suelas y Componentes Guayas', 'Lorena Vera', '042334567', 'contacto@suelasguayas.ec', 'Km 8.5 Via Daule', 2),
('Insumos Industriales Manabi', 'Jorge Pico', '052678123', 'ventas@insumosmanabi.ec', 'Av. 4 de Noviembre', 5),
('Guangzhou Rubber Sole Co. Ltd.', 'Li Wei', '+862087001122', 'sales@gzrubber.cn', 'No. 88 Industrial Rd', 11),
('Yiwu Synthetic Materials Co.', 'Zhang Min', '+865797002233', 'trade@yiwusynth.cn', 'Block C, Futian Market', 12),
('Shenzhen Footwear Machinery', 'Chen Hao', '+867551003344', 'export@szmachinery.cn', 'Bao''an District 5th St', 13),
('Wenzhou Leather Import Export', 'Wang Fang', '+865771004455', 'info@wzleather.cn', 'Ouhai Industrial Zone', 14),
('Quanzhou Adhesives & Textiles', 'Liu Yang', '+865951005566', 'sales@qzadhesives.cn', 'Jinjiang Shoe Park', 15);
GO

-- ----- sucursales (5) -----
INSERT INTO sucursales (nombre_sucursal, id_ciudad, direccion, telefono) VALUES
('Matriz Quito', 1, 'Av. Amazonas N34-120', '022500111'),
('Sucursal Guayaquil', 2, 'Av. 9 de Octubre 1200', '042500222'),
('Sucursal Cuenca', 3, 'Av. Solano 4-56', '072500333'),
('Sucursal Ambato', 4, 'Av. Cevallos 8-30', '032500444'),
('Sucursal Manta', 5, 'Malecon Escenico s/n', '052500555');
GO

-- ----- productos (20) -----
INSERT INTO productos (nombre_producto, id_categoria, id_proveedor, talla, color, material, precio_compra, precio_venta_mayor, precio_venta_menor) VALUES
('Zapato Casual Cuero Marron', 1, 6, '39-44', 'Marron', 'Cuero genuino', 26.71, 37.59, 49.06),
('Zapato Casual Cuero Negro', 1, 2, '38-43', 'Negro', 'Cuero genuino', 17.13, 27.77, 38.47),
('Zapatilla Running Air Flex', 2, 6, '36-44', 'Azul/Blanco', 'Malla sintetica', 32.52, 46.38, 61.89),
('Zapatilla Urban Sport', 2, 7, '36-43', 'Gris', 'Malla y goma', 12.69, 18.6, 25.13),
('Zapatilla Training Pro', 2, 8, '37-44', 'Negro/Rojo', 'Sintetico transpirable', 12.61, 18.41, 25.41),
('Bota Industrial Alta', 3, 9, '39-45', 'Negro', 'Cuero reforzado', 24.53, 35.96, 49.19),
('Bota Campo Impermeable', 3, 1, '38-44', 'Cafe', 'Cuero engrasado', 30.62, 42.93, 60.58),
('Bota Militar Tactica', 3, 6, '39-45', 'Negro', 'Cuero y lona', 28.06, 42.15, 54.0),
('Sandalia Playera Unisex', 4, 10, '35-42', 'Varios', 'Caucho EVA', 34.02, 51.06, 64.77),
('Sandalia Confort Dama', 4, 7, '34-40', 'Beige', 'Sintetico suave', 14.22, 23.52, 32.24),
('Sandalia Trekking', 4, 8, '38-45', 'Verde', 'Poliuretano', 30.56, 49.47, 67.14),
('Zapato Formal Oxford', 5, 2, '39-44', 'Negro', 'Cuero pulido', 34.38, 52.04, 70.8),
('Zapato Formal Derby', 5, 3, '38-43', 'Cafe', 'Cuero legitimo', 31.08, 49.28, 70.09),
('Zapato Formal Mocasin', 5, 1, '38-44', 'Negro', 'Cuero suave', 25.28, 40.74, 51.3),
('Zapatilla Kids Colorful', 2, 9, '28-34', 'Multicolor', 'Sintetico ligero', 17.24, 25.63, 32.45),
('Zapato Casual Lona', 1, 4, '37-43', 'Azul', 'Lona reforzada', 17.35, 24.82, 32.4),
('Bota Dama Taco Cuadrado', 3, 3, '35-40', 'Negro', 'Cuero sintetico', 26.62, 40.18, 53.2),
('Sandalia Sport Velcro', 4, 5, '36-43', 'Gris/Verde', 'EVA y velcro', 16.82, 24.9, 35.79),
('Zapato Formal Charol', 5, 10, '38-43', 'Negro', 'Charol', 26.9, 42.58, 54.68),
('Zapatilla Skate Classic', 2, 5, '37-44', 'Blanco', 'Lona y goma', 28.77, 41.69, 55.28);
GO

-- ----- clientes (30) -----
INSERT INTO clientes (nombres, apellidos, tipo_cliente, cedula_ruc, telefono, email, direccion, id_ciudad) VALUES
('Juan', 'Perez', 'Mayorista', '1795899313', '0984752529', 'juan.perez0@correo.com', 'Calle Secundaria 88-51', 1),
('Maria', 'Gomez', 'Minorista', '1740742311', '0914308421', 'maria.gomez1@correo.com', 'Calle Los Rosales 52-44', 2),
('Pedro', 'Torres', 'Minorista', '1738317637', '0986125617', 'pedro.torres2@correo.com', 'Calle Los Rosales 28-93', 8),
('Ana', 'Vasquez', 'Mayorista', '1763100814', '0996282117', 'ana.vasquez3@correo.com', 'Calle El Bosque 19-43', 3),
('Luis', 'Ramirez', 'Minorista', '1743101783', '0985345555', 'luis.ramirez4@correo.com', 'Calle Las Palmas 34-84', 7),
('Carla', 'Castillo', 'Minorista', '1788320463', '0963606628', 'carla.castillo5@correo.com', 'Calle Los Rosales 29-27', 9),
('Diego', 'Chavez', 'Mayorista', '1776238574', '0922201654', 'diego.chavez6@correo.com', 'Calle Principal 15-29', 3),
('Sofia', 'Ortiz', 'Minorista', '1766661351', '0990048665', 'sofia.ortiz7@correo.com', 'Calle Principal 50-58', 10),
('Manuel', 'Moreno', 'Minorista', '1772820592', '0981016525', 'manuel.moreno8@correo.com', 'Calle Los Rosales 71-11', 2),
('Paola', 'Rios', 'Mayorista', '1782070937', '0945812670', 'paola.rios9@correo.com', 'Calle Los Rosales 15-47', 7),
('Jorge', 'Aguilar', 'Minorista', '1731227574', '0970897765', 'jorge.aguilar10@correo.com', 'Calle Principal 93-43', 9),
('Elena', 'Suarez', 'Minorista', '1733978249', '0978139880', 'elena.suarez11@correo.com', 'Calle Principal 81-48', 9),
('Ricardo', 'Paredes', 'Mayorista', '1791734598', '0936697396', 'ricardo.paredes12@correo.com', 'Calle Secundaria 48-30', 9),
('Gabriela', 'Herrera', 'Minorista', '1781182864', '0910076758', 'gabriela.herrera13@correo.com', 'Calle Las Palmas 42-72', 1),
('Fernando', 'Cordova', 'Minorista', '1725014631', '0958718453', 'fernando.cordova14@correo.com', 'Calle Los Rosales 31-17', 4),
('Monica', 'Villacis', 'Mayorista', '1786149359', '0920570592', 'monica.villacis15@correo.com', 'Calle Principal 94-72', 2),
('Andres', 'Naranjo', 'Minorista', '1781498611', '0926879290', 'andres.naranjo16@correo.com', 'Calle Secundaria 85-70', 9),
('Veronica', 'Chiriboga', 'Minorista', '1732162965', '0945575298', 'veronica.chiriboga17@correo.com', 'Calle Las Palmas 78-64', 4),
('Carlos', 'Espinoza', 'Mayorista', '1782383095', '0936998038', 'carlos.espinoza18@correo.com', 'Calle Los Rosales 52-95', 6),
('Daniela', 'Salinas', 'Minorista', '1768800797', '0979467853', 'daniela.salinas19@correo.com', 'Calle El Bosque 16-41', 4),
('Miguel', 'Bravo', 'Minorista', '1718593410', '0955377076', 'miguel.bravo20@correo.com', 'Calle Principal 76-80', 4),
('Patricia', 'Mora', 'Mayorista', '1788979095', '0939557077', 'patricia.mora21@correo.com', 'Calle Principal 10-90', 1),
('Roberto', 'Cevallos', 'Minorista', '1740728046', '0919046318', 'roberto.cevallos22@correo.com', 'Calle Principal 43-19', 9),
('Silvia', 'Andrade', 'Minorista', '1741944441', '0947376585', 'silvia.andrade23@correo.com', 'Calle El Bosque 28-79', 3),
('Oscar', 'Zambrano', 'Mayorista', '1786644106', '0987337818', 'oscar.zambrano24@correo.com', 'Calle El Bosque 32-70', 7),
('Adriana', 'Freire', 'Minorista', '1735556386', '0922660194', 'adriana.freire25@correo.com', 'Calle Principal 85-65', 6),
('Xavier', 'Guerrero', 'Minorista', '1766851760', '0965177213', 'xavier.guerrero26@correo.com', 'Calle El Bosque 94-16', 2),
('Cristina', 'Tapia', 'Mayorista', '1718135295', '0964038913', 'cristina.tapia27@correo.com', 'Calle Los Rosales 14-41', 4),
('Marcelo', 'Quinde', 'Minorista', '1735529407', '0981979055', 'marcelo.quinde28@correo.com', 'Calle El Bosque 18-64', 3),
('Johanna', 'Loor', 'Minorista', '1747385696', '0972092888', 'johanna.loor29@correo.com', 'Calle Secundaria 10-66', 9);
GO

-- ----- empleados (10) -----
INSERT INTO empleados (nombres, apellidos, cargo, id_sucursal, telefono, email, fecha_contratacion, salario) VALUES
('Ana', 'Lopez', 'Gerente de Sucursal', 1, '099111222', 'ana.lopez@calzadoec.com', '2019-03-15', 1400.0),
('Luis', 'Mendoza', 'Vendedor', 1, '099222333', 'luis.mendoza@calzadoec.com', '2020-06-01', 550.0),
('Karla', 'Vera', 'Bodeguero', 1, '099333444', 'karla.vera@calzadoec.com', '2021-01-10', 520.0),
('Pedro', 'Salinas', 'Gerente de Sucursal', 2, '099444555', 'pedro.salinas@calzadoec.com', '2018-11-20', 1400.0),
('Monica', 'Reyes', 'Vendedor', 2, '099555666', 'monica.reyes@calzadoec.com', '2020-09-05', 550.0),
('Diego', 'Castillo', 'Supervisor de Logistica', 2, '099666777', 'diego.castillo@calzadoec.com', '2019-07-22', 900.0),
('Sofia', 'Andrade', 'Gerente de Sucursal', 3, '099777888', 'sofia.andrade@calzadoec.com', '2019-02-14', 1400.0),
('Ricardo', 'Ortiz', 'Vendedor', 3, '099888999', 'ricardo.ortiz@calzadoec.com', '2021-04-18', 550.0),
('Paola', 'Naranjo', 'Contador', 1, '099000111', 'paola.naranjo@calzadoec.com', '2018-05-30', 950.0),
('Fernando', 'Bravo', 'Bodeguero', 4, '099123456', 'fernando.bravo@calzadoec.com', '2022-02-11', 520.0);
GO

-- ----- promociones (10) -----
INSERT INTO promociones (nombre_promocion, descripcion, porcentaje_descuento, fecha_inicio, fecha_fin, estado) VALUES
('Descuento Fin de Temporada', 'Descuento en linea de sandalias y casuales', 15.0, '2026-01-05', '2026-01-31', 'Finalizada'),
('Black Friday Calzado', 'Descuento especial en toda la tienda', 25.0, '2025-11-28', '2025-11-30', 'Finalizada'),
('Promo Dia de la Madre', 'Descuento en linea formal y casual dama', 20.0, '2026-05-01', '2026-05-14', 'Finalizada'),
('Vuelta a Clases', 'Descuento en zapatillas escolares y deportivas', 10.0, '2026-04-01', '2026-04-20', 'Finalizada'),
('Promo Mayoristas Q1', 'Descuento por volumen para clientes mayoristas', 12.0, '2026-02-01', '2026-03-31', 'Finalizada'),
('Navidad Calzado 2025', 'Descuento navideno en toda la coleccion', 18.0, '2025-12-10', '2025-12-24', 'Finalizada'),
('Aniversario de la Empresa', 'Descuento por aniversario corporativo', 22.0, '2026-06-01', '2026-06-10', 'Finalizada'),
('Promo Botas Invierno', 'Descuento en linea de botas', 15.0, '2026-06-15', '2026-06-30', 'Activa'),
('Liquidacion Stock Antiguo', 'Descuento para renovar inventario', 30.0, '2026-07-01', '2026-07-15', 'Activa'),
('Promo Clientes Frecuentes', 'Descuento fidelidad clientes recurrentes', 8.0, '2026-01-01', '2026-12-31', 'Activa');
GO

-- ----- ventas (50) -----
INSERT INTO ventas (id_cliente, id_empleado, id_sucursal, id_promocion, fecha_venta, tipo_venta, forma_pago, total_venta) VALUES
(4, 1, 1, NULL, '2026-01-03', 'Minorista', 'Tarjeta de Credito', 205.2),
(16, 4, 2, NULL, '2026-02-13', 'Minorista', 'Efectivo', 388.04),
(23, 9, 1, NULL, '2026-02-10', 'Minorista', 'Tarjeta de Credito', 54.68),
(24, 6, 2, NULL, '2026-05-28', 'Mayorista', 'Tarjeta de Credito', 281.26),
(28, 3, 1, 4, '2026-04-04', 'Mayorista', 'Tarjeta de Credito', 1153.07),
(30, 5, 2, NULL, '2026-02-09', 'Mayorista', 'Cheque', 446.88),
(11, 2, 1, NULL, '2026-05-04', 'Mayorista', 'Efectivo', 1409.21),
(12, 5, 2, NULL, '2026-06-10', 'Mayorista', 'Efectivo', 924.48),
(29, 2, 1, 5, '2026-05-07', 'Minorista', 'Transferencia', 259.08),
(9, 1, 1, NULL, '2026-03-02', 'Mayorista', 'Efectivo', 922.57),
(18, 7, 3, 3, '2026-05-02', 'Minorista', 'Transferencia', 289.59),
(12, 1, 1, 4, '2026-06-04', 'Minorista', 'Transferencia', 407.36),
(1, 3, 1, 7, '2026-06-28', 'Minorista', 'Tarjeta de Credito', 119.28),
(28, 8, 3, NULL, '2026-04-12', 'Mayorista', 'Transferencia', 210.75),
(22, 4, 2, 2, '2026-03-12', 'Minorista', 'Cheque', 285.97),
(19, 5, 2, NULL, '2026-03-24', 'Mayorista', 'Transferencia', 875.6),
(9, 1, 1, 9, '2026-06-24', 'Minorista', 'Tarjeta de Credito', 252.72),
(22, 2, 1, 5, '2026-06-14', 'Minorista', 'Transferencia', 306.8),
(22, 7, 3, NULL, '2026-05-19', 'Minorista', 'Transferencia', 132.51),
(7, 7, 3, NULL, '2026-03-15', 'Minorista', 'Cheque', 291.51),
(10, 9, 1, NULL, '2026-01-27', 'Minorista', 'Tarjeta de Credito', 234.7),
(8, 8, 3, NULL, '2026-04-14', 'Minorista', 'Tarjeta de Credito', 445.95),
(29, 2, 1, 9, '2026-04-02', 'Minorista', 'Tarjeta de Credito', 64.9),
(26, 8, 3, NULL, '2026-05-11', 'Minorista', 'Cheque', 552.72),
(15, 5, 2, NULL, '2026-03-25', 'Minorista', 'Cheque', 258.93),
(9, 6, 2, NULL, '2026-02-05', 'Minorista', 'Tarjeta de Credito', 298.38),
(14, 6, 2, NULL, '2026-02-27', 'Minorista', 'Cheque', 273.4),
(16, 1, 1, 7, '2026-04-18', 'Minorista', 'Tarjeta de Credito', 367.2),
(1, 7, 3, NULL, '2026-04-24', 'Minorista', 'Tarjeta de Credito', 95.5),
(3, 7, 3, NULL, '2026-01-09', 'Mayorista', 'Cheque', 1557.72),
(25, 7, 3, NULL, '2026-04-09', 'Mayorista', 'Efectivo', 850.02),
(21, 2, 1, NULL, '2026-01-08', 'Minorista', 'Tarjeta de Credito', 110.56),
(8, 3, 1, 4, '2026-04-23', 'Minorista', 'Transferencia', 196.76),
(4, 10, 4, 7, '2026-04-23', 'Mayorista', 'Tarjeta de Credito', 510.96),
(4, 5, 2, NULL, '2026-01-26', 'Minorista', 'Efectivo', 213.96),
(17, 6, 2, NULL, '2026-04-04', 'Mayorista', 'Cheque', 638.07),
(24, 9, 1, 9, '2026-04-15', 'Minorista', 'Cheque', 483.99),
(29, 8, 3, NULL, '2026-05-22', 'Mayorista', 'Cheque', 1246.5),
(16, 4, 2, 5, '2026-05-23', 'Minorista', 'Transferencia', 427.1),
(18, 4, 2, NULL, '2026-04-15', 'Minorista', 'Efectivo', 64.48),
(13, 4, 2, NULL, '2026-04-18', 'Minorista', 'Transferencia', 390.57),
(9, 5, 2, 4, '2026-03-04', 'Mayorista', 'Tarjeta de Credito', 858.6),
(9, 10, 4, NULL, '2026-03-04', 'Minorista', 'Tarjeta de Credito', 309.57),
(1, 9, 1, 1, '2026-05-10', 'Mayorista', 'Tarjeta de Credito', 1221.22),
(15, 6, 2, 8, '2026-01-27', 'Mayorista', 'Efectivo', 429.22),
(5, 3, 1, NULL, '2026-01-08', 'Minorista', 'Efectivo', 445.2),
(10, 10, 4, 10, '2026-01-20', 'Minorista', 'Efectivo', 181.74),
(22, 2, 1, 2, '2026-02-01', 'Mayorista', 'Cheque', 974.92),
(8, 5, 2, NULL, '2026-04-03', 'Minorista', 'Tarjeta de Credito', 160.66),
(18, 4, 2, NULL, '2026-02-03', 'Minorista', 'Efectivo', 96.72);
GO

-- ----- detalle_venta (101) -----
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 14, 4, 51.3),
(2, 9, 4, 64.77),
(2, 10, 4, 32.24),
(3, 19, 1, 54.68),
(4, 17, 7, 40.18),
(5, 20, 6, 41.69),
(5, 20, 7, 41.69),
(5, 14, 15, 40.74),
(6, 10, 19, 23.52),
(7, 7, 13, 42.93),
(7, 5, 16, 18.41),
(7, 3, 12, 46.38),
(8, 18, 14, 24.9),
(8, 4, 9, 18.6),
(8, 9, 8, 51.06),
(9, 9, 4, 64.77),
(10, 5, 13, 18.41),
(10, 6, 19, 35.96),
(11, 18, 2, 35.79),
(11, 14, 2, 51.3),
(11, 2, 3, 38.47),
(12, 14, 2, 51.3),
(12, 8, 2, 54.0),
(12, 6, 4, 49.19),
(13, 6, 1, 49.19),
(13, 13, 1, 70.09),
(14, 8, 5, 42.15),
(15, 18, 3, 35.79),
(15, 1, 1, 49.06),
(15, 9, 2, 64.77),
(16, 20, 8, 41.69),
(16, 13, 11, 49.28),
(17, 14, 1, 51.3),
(17, 11, 3, 67.14),
(18, 10, 2, 32.24),
(18, 7, 4, 60.58),
(19, 18, 1, 35.79),
(19, 10, 3, 32.24),
(20, 7, 4, 60.58),
(20, 6, 1, 49.19),
(21, 10, 2, 32.24),
(21, 7, 2, 60.58),
(21, 1, 1, 49.06),
(22, 13, 4, 70.09),
(22, 13, 2, 70.09),
(22, 5, 1, 25.41),
(23, 15, 2, 32.45),
(24, 17, 4, 53.2),
(24, 18, 4, 35.79),
(24, 6, 4, 49.19),
(25, 8, 3, 54.0),
(25, 15, 1, 32.45),
(25, 10, 2, 32.24),
(26, 5, 2, 25.41),
(26, 3, 4, 61.89),
(27, 19, 1, 54.68),
(27, 19, 4, 54.68),
(28, 8, 3, 54.0),
(28, 14, 4, 51.3),
(29, 5, 1, 25.41),
(29, 13, 1, 70.09),
(30, 7, 19, 42.93),
(30, 11, 15, 49.47),
(31, 1, 6, 37.59),
(31, 12, 12, 52.04),
(32, 20, 2, 55.28),
(33, 6, 1, 49.19),
(33, 6, 3, 49.19),
(34, 19, 12, 42.58),
(35, 18, 4, 35.79),
(35, 12, 1, 70.8),
(36, 15, 9, 25.63),
(36, 14, 10, 40.74),
(37, 19, 3, 54.68),
(37, 11, 2, 67.14),
(37, 3, 3, 61.89),
(38, 1, 20, 37.59),
(38, 11, 10, 49.47),
(39, 1, 2, 49.06),
(39, 3, 2, 61.89),
(39, 14, 4, 51.3),
(40, 10, 2, 32.24),
(41, 18, 3, 35.79),
(41, 12, 4, 70.8),
(42, 7, 20, 42.93),
(43, 8, 3, 54.0),
(43, 6, 3, 49.19),
(44, 16, 8, 24.82),
(44, 1, 14, 37.59),
(44, 16, 20, 24.82),
(45, 16, 7, 24.82),
(45, 19, 6, 42.58),
(46, 14, 2, 51.3),
(46, 17, 4, 53.2),
(46, 15, 4, 32.45),
(47, 7, 3, 60.58),
(48, 20, 20, 41.69),
(48, 10, 6, 23.52),
(49, 19, 2, 54.68),
(49, 14, 1, 51.3),
(50, 10, 3, 32.24);
GO

-- ----- inventario (100) -----
INSERT INTO inventario (id_producto, id_sucursal, stock, stock_minimo) VALUES
(1, 1, 66, 5),
(1, 2, 69, 10),
(1, 3, 48, 10),
(1, 4, 61, 8),
(1, 5, 74, 10),
(2, 1, 73, 8),
(2, 2, 20, 10),
(2, 3, 15, 8),
(2, 4, 104, 8),
(2, 5, 87, 8),
(3, 1, 13, 5),
(3, 2, 39, 10),
(3, 3, 117, 10),
(3, 4, 85, 5),
(3, 5, 107, 10),
(4, 1, 115, 8),
(4, 2, 83, 5),
(4, 3, 107, 5),
(4, 4, 70, 10),
(4, 5, 93, 8),
(5, 1, 45, 5),
(5, 2, 84, 8),
(5, 3, 91, 8),
(5, 4, 21, 8),
(5, 5, 54, 8),
(6, 1, 52, 8),
(6, 2, 95, 5),
(6, 3, 119, 5),
(6, 4, 52, 8),
(6, 5, 98, 8),
(7, 1, 46, 10),
(7, 2, 61, 10),
(7, 3, 14, 8),
(7, 4, 21, 8),
(7, 5, 42, 8),
(8, 1, 24, 8),
(8, 2, 120, 10),
(8, 3, 115, 5),
(8, 4, 94, 10),
(8, 5, 69, 8),
(9, 1, 16, 5),
(9, 2, 76, 8),
(9, 3, 89, 8),
(9, 4, 90, 8),
(9, 5, 107, 5),
(10, 1, 36, 8),
(10, 2, 80, 5),
(10, 3, 46, 8),
(10, 4, 99, 8),
(10, 5, 25, 5),
(11, 1, 90, 10),
(11, 2, 112, 5),
(11, 3, 100, 5),
(11, 4, 49, 10),
(11, 5, 11, 10),
(12, 1, 62, 5),
(12, 2, 38, 5),
(12, 3, 69, 5),
(12, 4, 92, 5),
(12, 5, 73, 10),
(13, 1, 47, 10),
(13, 2, 100, 8),
(13, 3, 63, 8),
(13, 4, 70, 5),
(13, 5, 68, 10),
(14, 1, 28, 8),
(14, 2, 34, 10),
(14, 3, 75, 10),
(14, 4, 27, 5),
(14, 5, 45, 8),
(15, 1, 53, 10),
(15, 2, 44, 5),
(15, 3, 46, 10),
(15, 4, 48, 10),
(15, 5, 84, 10),
(16, 1, 72, 5),
(16, 2, 67, 10),
(16, 3, 71, 8),
(16, 4, 52, 10),
(16, 5, 107, 10),
(17, 1, 58, 8),
(17, 2, 51, 5),
(17, 3, 99, 5),
(17, 4, 83, 8),
(17, 5, 39, 8),
(18, 1, 15, 8),
(18, 2, 105, 8),
(18, 3, 100, 8),
(18, 4, 59, 10),
(18, 5, 111, 10),
(19, 1, 29, 8),
(19, 2, 14, 5),
(19, 3, 74, 10),
(19, 4, 52, 5),
(19, 5, 118, 8),
(20, 1, 22, 10),
(20, 2, 68, 5),
(20, 3, 102, 5),
(20, 4, 62, 10),
(20, 5, 29, 5);
GO

-- ----- movimientos_inventario (20) -----
INSERT INTO movimientos_inventario (id_producto, id_sucursal, id_empleado, tipo_movimiento, cantidad, motivo, fecha_movimiento) VALUES
(16, 3, 6, 'Salida', 8, 'Merma por dano en bodega', '2026-06-28 16:24:00'),
(11, 4, 9, 'Entrada', 7, 'Compra a proveedor', '2026-06-22 12:14:00'),
(3, 4, 2, 'Entrada', 31, 'Compra a proveedor', '2026-06-10 08:02:00'),
(11, 1, 5, 'Salida', 26, 'Transferencia a otra sucursal', '2026-02-08 16:26:00'),
(19, 2, 3, 'Entrada', 8, 'Transferencia entre sucursales', '2026-04-20 18:15:00'),
(16, 5, 3, 'Entrada', 32, 'Transferencia entre sucursales', '2026-03-15 12:42:00'),
(1, 4, 5, 'Entrada', 7, 'Devolucion de cliente reintegrada a stock', '2026-03-19 12:40:00'),
(14, 3, 8, 'Salida', 15, 'Transferencia a otra sucursal', '2026-04-04 11:24:00'),
(19, 3, 10, 'Salida', 21, 'Venta al por menor', '2026-06-13 12:00:00'),
(19, 1, 10, 'Salida', 21, 'Venta al por mayor', '2026-05-26 13:14:00'),
(7, 5, 5, 'Entrada', 9, 'Transferencia entre sucursales', '2026-06-02 12:50:00'),
(15, 1, 10, 'Salida', 11, 'Venta al por menor', '2026-03-11 14:11:00'),
(7, 2, 9, 'Salida', 36, 'Merma por dano en bodega', '2026-02-09 15:51:00'),
(10, 3, 2, 'Salida', 7, 'Venta al por mayor', '2026-02-28 18:46:00'),
(13, 5, 6, 'Entrada', 28, 'Compra a proveedor', '2026-03-18 09:29:00'),
(12, 3, 10, 'Salida', 26, 'Venta al por menor', '2026-06-08 15:01:00'),
(20, 5, 6, 'Entrada', 7, 'Transferencia entre sucursales', '2026-04-23 12:41:00'),
(14, 1, 3, 'Entrada', 5, 'Devolucion de cliente reintegrada a stock', '2026-04-04 09:15:00'),
(18, 2, 7, 'Salida', 26, 'Transferencia a otra sucursal', '2026-05-24 10:56:00'),
(14, 1, 8, 'Salida', 20, 'Venta al por menor', '2026-06-12 11:28:00');
GO

-- ----- devoluciones (20) -----
INSERT INTO devoluciones (id_venta, id_producto, id_empleado, cantidad, motivo, fecha_devolucion, estado) VALUES
(29, 5, 6, 1, 'Cambio por otro modelo', '2026-05-21 14:03:00', 'Pendiente'),
(26, 3, 4, 1, 'Cliente insatisfecho', '2026-06-07 09:03:00', 'Procesada'),
(22, 13, 3, 3, 'Producto defectuoso', '2026-05-07 12:52:00', 'Procesada'),
(15, 1, 3, 3, 'Talla incorrecta', '2026-02-05 17:16:00', 'Pendiente'),
(12, 14, 1, 1, 'Talla incorrecta', '2026-02-19 14:01:00', 'Pendiente'),
(12, 8, 1, 1, 'Cambio por otro modelo', '2026-05-04 10:30:00', 'Pendiente'),
(29, 13, 9, 3, 'Talla incorrecta', '2026-05-08 09:46:00', 'Pendiente'),
(43, 6, 8, 3, 'Talla incorrecta', '2026-04-28 15:27:00', 'Procesada'),
(44, 16, 8, 3, 'Cliente insatisfecho', '2026-01-11 11:04:00', 'Procesada'),
(9, 9, 10, 3, 'Dano en el transporte', '2026-06-11 15:38:00', 'Rechazada'),
(34, 19, 8, 3, 'Dano en el transporte', '2026-01-26 10:54:00', 'Pendiente'),
(42, 7, 7, 2, 'Producto defectuoso', '2026-03-27 16:25:00', 'Pendiente'),
(27, 19, 6, 2, 'Color no era el solicitado', '2026-03-12 11:43:00', 'Rechazada'),
(31, 1, 2, 1, 'Talla incorrecta', '2026-01-24 14:51:00', 'Pendiente'),
(9, 9, 10, 3, 'Dano en el transporte', '2026-06-04 15:22:00', 'Pendiente'),
(43, 6, 1, 2, 'Dano en el transporte', '2026-03-04 17:13:00', 'Pendiente'),
(10, 6, 4, 1, 'Color no era el solicitado', '2026-03-04 13:36:00', 'Rechazada'),
(15, 1, 9, 3, 'Dano en el transporte', '2026-06-18 09:38:00', 'Rechazada'),
(43, 6, 1, 1, 'Color no era el solicitado', '2026-03-11 14:00:00', 'Rechazada'),
(12, 14, 10, 3, 'Cliente insatisfecho', '2026-02-24 09:05:00', 'Procesada');
GO

-- ----- auditoria (15) -----
INSERT INTO auditoria (tabla_afectada, accion, usuario_bd, fecha_hora, detalle) VALUES
('promociones', 'DELETE', 'usr_ventas', '2026-04-14 15:21:00', 'Operacion DELETE registrada sobre la tabla promociones'),
('inventario', 'UPDATE', 'usr_bodega', '2026-06-11 20:36:00', 'Operacion UPDATE registrada sobre la tabla inventario'),
('devoluciones', 'INSERT', 'sa_admin', '2026-02-06 20:39:00', 'Operacion INSERT registrada sobre la tabla devoluciones'),
('ventas', 'DELETE', 'sa_admin', '2026-03-15 18:27:00', 'Operacion DELETE registrada sobre la tabla ventas'),
('productos', 'DELETE', 'usr_contabilidad', '2026-04-09 11:48:00', 'Operacion DELETE registrada sobre la tabla productos'),
('devoluciones', 'INSERT', 'usr_bodega', '2026-04-04 12:43:00', 'Operacion INSERT registrada sobre la tabla devoluciones'),
('promociones', 'DELETE', 'usr_contabilidad', '2026-05-22 12:02:00', 'Operacion DELETE registrada sobre la tabla promociones'),
('inventario', 'UPDATE', 'sa_admin', '2026-01-07 12:13:00', 'Operacion UPDATE registrada sobre la tabla inventario'),
('empleados', 'INSERT', 'usr_bodega', '2026-03-11 09:00:00', 'Operacion INSERT registrada sobre la tabla empleados'),
('productos', 'DELETE', 'usr_contabilidad', '2026-02-05 14:34:00', 'Operacion DELETE registrada sobre la tabla productos'),
('promociones', 'INSERT', 'usr_bodega', '2026-01-13 19:02:00', 'Operacion INSERT registrada sobre la tabla promociones'),
('productos', 'INSERT', 'usr_contabilidad', '2026-01-28 13:36:00', 'Operacion INSERT registrada sobre la tabla productos'),
('productos', 'DELETE', 'usr_contabilidad', '2026-06-21 14:18:00', 'Operacion DELETE registrada sobre la tabla productos'),
('ventas', 'UPDATE', 'sa_admin', '2026-03-06 20:39:00', 'Operacion UPDATE registrada sobre la tabla ventas'),
('productos', 'DELETE', 'usr_bodega', '2026-01-14 09:15:00', 'Operacion DELETE registrada sobre la tabla productos');
GO



