
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
    nombre_categoria VARCHAR(60) NOT NULL
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
    precio_venta_mayor DECIMAL(10,2) NOT NULL,
    precio_unitario    DECIMAL(10,2) NOT NULL,
    estado             VARCHAR(20) NOT NULL,
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
    CONSTRAINT fk_clientes_ciudades FOREIGN KEY (id_ciudad) REFERENCES ciudades(id_ciudad)
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
    estado               VARCHAR(20) NOT NULL CONSTRAINT df_promociones_estado DEFAULT 'Activa'
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
    CONSTRAINT fk_ventas_promociones FOREIGN KEY (id_promocion) REFERENCES promociones(id_promocion)
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
    CONSTRAINT fk_detalle_venta_ventas FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    CONSTRAINT fk_detalle_venta_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto)
);
GO

-- =====================================================================
-- 11. TABLA inventario 
-- =====================================================================
CREATE TABLE inventario (
    id_inventario     INT IDENTITY(1,1) CONSTRAINT pk_inventario PRIMARY KEY,
    id_producto       INT NOT NULL,
    id_sucursal       INT NOT NULL,
    stock             INT NOT NULL CONSTRAINT df_inventario_stock DEFAULT 0,
    estado_inventario VARCHAR(20) NOT NULL CONSTRAINT df_inventario_estado DEFAULT 'Disponible',
    observaciones     VARCHAR(150) NULL,
    CONSTRAINT fk_inventario_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_inventario_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
    CONSTRAINT uq_inventario_producto_sucursal UNIQUE (id_producto, id_sucursal)
);
GO

-- =====================================================================
-- 12. TABLA movimientos_inventario 
-- =====================================================================
CREATE TABLE movimientos_inventario (
    id_movimiento    INT IDENTITY(1,1) CONSTRAINT pk_movimientos_inventario PRIMARY KEY,
    id_producto      INT NOT NULL,
    id_sucursal      INT NOT NULL,
    id_empleado      INT NOT NULL,
    tipo_movimiento  VARCHAR(20) NOT NULL,
    cantidad         INT NOT NULL,
    motivo           VARCHAR(200) NULL,
    fecha_movimiento DATE NOT NULL,
    CONSTRAINT fk_mov_inv_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_mov_inv_sucursales FOREIGN KEY (id_sucursal) REFERENCES sucursales(id_sucursal),
    CONSTRAINT fk_mov_inv_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
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
    fecha_devolucion DATE NOT NULL,
    CONSTRAINT fk_devoluciones_ventas FOREIGN KEY (id_venta) REFERENCES ventas(id_venta),
    CONSTRAINT fk_devoluciones_productos FOREIGN KEY (id_producto) REFERENCES productos(id_producto),
    CONSTRAINT fk_devoluciones_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
);
GO

-- =====================================================================
-- 14. TABLA historial_actividades 
-- =====================================================================
CREATE TABLE historial_actividades (
    id_historial   INT IDENTITY(1,1) CONSTRAINT pk_historial_actividades PRIMARY KEY,
    fecha          DATE NOT NULL,
    id_empleado    INT NOT NULL,
    descripcion    VARCHAR(300) NOT NULL,
    CONSTRAINT fk_historial_empleados FOREIGN KEY (id_empleado) REFERENCES empleados(id_empleado)
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
INSERT INTO categorias (nombre_categoria) VALUES
('Zapatos Casuales'),
('Zapatos Deportivos'),
('Botas'),
('Sandalias'),
('Zapatos Formales');
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
INSERT INTO productos (nombre_producto, id_categoria, id_proveedor, talla, color, material, precio_venta_mayor, precio_unitario, estado) VALUES
('Zapato Casual Cuero Marron', 1, 6, '39-44', 'Marron', 'Cuero genuino', 37.18, 46.66, 'Activo'),
('Zapato Casual Cuero Negro', 1, 2, '38-43', 'Negro', 'Cuero genuino', 26.25, 33.98, 'Activo'),
('Zapatilla Running Air Flex', 2, 6, '36-44', 'Azul/Blanco', 'Malla sintetica', 40.09, 55.54, 'Activo'),
('Zapatilla Urban Sport', 2, 7, '36-43', 'Gris', 'Malla y goma', 44.77, 56.74, 'Activo'),
('Zapatilla Training Pro', 2, 8, '37-44', 'Negro/Rojo', 'Sintetico transpirable', 30.66, 38.51, 'Activo'),
('Bota Industrial Alta', 3, 9, '39-45', 'Negro', 'Cuero reforzado', 24.56, 33.18, 'Activo'),
('Bota Campo Impermeable', 3, 1, '38-44', 'Cafe', 'Cuero engrasado', 18.8, 24.25, 'Activo'),
('Bota Militar Tactica', 3, 6, '39-45', 'Negro', 'Cuero y lona', 37.5, 50.96, 'Activo'),
('Sandalia Playera Unisex', 4, 10, '35-42', 'Varios', 'Caucho EVA', 24.61, 33.66, 'Activo'),
('Sandalia Confort Dama', 4, 7, '34-40', 'Beige', 'Sintetico suave', 42.28, 52.9, 'Activo'),
('Sandalia Trekking', 4, 8, '38-45', 'Verde', 'Poliuretano', 42.17, 58.6, 'Activo'),
('Zapato Formal Oxford', 5, 2, '39-44', 'Negro', 'Cuero pulido', 28.21, 36.14, 'Activo'),
('Zapato Formal Derby', 5, 3, '38-43', 'Cafe', 'Cuero legitimo', 46.72, 61.55, 'Activo'),
('Zapato Formal Mocasin', 5, 1, '38-44', 'Negro', 'Cuero suave', 20.78, 26.38, 'Activo'),
('Zapatilla Kids Colorful', 2, 9, '28-34', 'Multicolor', 'Sintetico ligero', 43.42, 59.52, 'Activo'),
('Zapato Casual Lona', 1, 4, '37-43', 'Azul', 'Lona reforzada', 42.21, 58.92, 'Activo'),
('Bota Dama Taco Cuadrado', 3, 3, '35-40', 'Negro', 'Cuero sintetico', 34.09, 49.25, 'Activo'),
('Sandalia Sport Velcro', 4, 5, '36-43', 'Gris/Verde', 'EVA y velcro', 29.36, 39.94, 'Activo'),
('Zapato Formal Charol', 5, 10, '38-43', 'Negro', 'Charol', 42.88, 58.9, 'Activo'),
('Zapatilla Skate Classic', 2, 5, '37-44', 'Blanco', 'Lona y goma', 43.85, 59.88, 'Activo');
GO

-- ----- clientes (30) -----
INSERT INTO clientes (nombres, apellidos, tipo_cliente, cedula_ruc, telefono, email, direccion, id_ciudad) VALUES
('Juan', 'Perez', 'Mayorista', '1719335534', '0916150444', 'juan.perez0@correo.com', 'Calle Secundaria 99-47', 2),
('Maria', 'Gomez', 'Minorista', '1741244663', '0923556182', 'maria.gomez1@correo.com', 'Calle El Bosque 36-68', 6),
('Pedro', 'Torres', 'Minorista', '1731831063', '0959684848', 'pedro.torres2@correo.com', 'Calle Los Rosales 27-95', 5),
('Ana', 'Vasquez', 'Mayorista', '1796977837', '0919583482', 'ana.vasquez3@correo.com', 'Calle Las Palmas 82-31', 9),
('Luis', 'Ramirez', 'Minorista', '1742857966', '0931931511', 'luis.ramirez4@correo.com', 'Calle El Bosque 49-44', 9),
('Carla', 'Castillo', 'Minorista', '1739476249', '0953524491', 'carla.castillo5@correo.com', 'Calle Principal 30-14', 6),
('Diego', 'Chavez', 'Mayorista', '1763843426', '0945935572', 'diego.chavez6@correo.com', 'Calle Principal 28-82', 6),
('Sofia', 'Ortiz', 'Minorista', '1738538251', '0997971488', 'sofia.ortiz7@correo.com', 'Calle El Bosque 51-92', 8),
('Manuel', 'Moreno', 'Minorista', '1729175900', '0945551614', 'manuel.moreno8@correo.com', 'Calle Secundaria 32-81', 9),
('Paola', 'Rios', 'Mayorista', '1745264581', '0988461803', 'paola.rios9@correo.com', 'Calle El Bosque 75-61', 6),
('Jorge', 'Aguilar', 'Minorista', '1739436733', '0928566572', 'jorge.aguilar10@correo.com', 'Calle Las Palmas 64-21', 1),
('Elena', 'Suarez', 'Minorista', '1724716857', '0930514014', 'elena.suarez11@correo.com', 'Calle Secundaria 88-64', 10),
('Ricardo', 'Paredes', 'Mayorista', '1718526544', '0961642594', 'ricardo.paredes12@correo.com', 'Calle El Bosque 77-69', 9),
('Gabriela', 'Herrera', 'Minorista', '1743744231', '0984252722', 'gabriela.herrera13@correo.com', 'Calle Principal 88-24', 9),
('Fernando', 'Cordova', 'Minorista', '1745812670', '0996028436', 'fernando.cordova14@correo.com', 'Calle Los Rosales 15-47', 7),
('Monica', 'Villacis', 'Mayorista', '1731227574', '0970897765', 'monica.villacis15@correo.com', 'Calle Principal 93-43', 9),
('Andres', 'Naranjo', 'Minorista', '1733978249', '0978139880', 'andres.naranjo16@correo.com', 'Calle Principal 81-48', 9),
('Veronica', 'Chiriboga', 'Minorista', '1791734598', '0936697396', 'veronica.chiriboga17@correo.com', 'Calle Secundaria 48-30', 9),
('Carlos', 'Espinoza', 'Mayorista', '1781182864', '0910076758', 'carlos.espinoza18@correo.com', 'Calle Las Palmas 42-72', 1),
('Daniela', 'Salinas', 'Minorista', '1725014631', '0958718453', 'daniela.salinas19@correo.com', 'Calle Los Rosales 31-17', 4),
('Miguel', 'Bravo', 'Minorista', '1786149359', '0920570592', 'miguel.bravo20@correo.com', 'Calle Principal 94-72', 2),
('Patricia', 'Mora', 'Mayorista', '1781498611', '0926879290', 'patricia.mora21@correo.com', 'Calle Secundaria 85-70', 9),
('Roberto', 'Cevallos', 'Minorista', '1732162965', '0945575298', 'roberto.cevallos22@correo.com', 'Calle Las Palmas 78-64', 4),
('Silvia', 'Andrade', 'Minorista', '1782383095', '0936998038', 'silvia.andrade23@correo.com', 'Calle Los Rosales 52-95', 6),
('Oscar', 'Zambrano', 'Mayorista', '1768800797', '0979467853', 'oscar.zambrano24@correo.com', 'Calle El Bosque 16-41', 4),
('Adriana', 'Freire', 'Minorista', '1718593410', '0955377076', 'adriana.freire25@correo.com', 'Calle Principal 76-80', 4),
('Xavier', 'Guerrero', 'Minorista', '1788979095', '0939557077', 'xavier.guerrero26@correo.com', 'Calle Principal 10-90', 1),
('Cristina', 'Tapia', 'Mayorista', '1740728046', '0919046318', 'cristina.tapia27@correo.com', 'Calle Principal 43-19', 9),
('Marcelo', 'Quinde', 'Minorista', '1741944441', '0947376585', 'marcelo.quinde28@correo.com', 'Calle El Bosque 28-79', 3),
('Johanna', 'Loor', 'Minorista', '1786644106', '0987337818', 'johanna.loor29@correo.com', 'Calle El Bosque 32-70', 7);
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
(7, 2, 1, NULL, '2026-04-14', 'Mayorista', 'Cheque', 993.61),
(8, 4, 2, NULL, '2026-04-06', 'Mayorista', 'Transferencia', 609.86),
(2, 9, 1, NULL, '2026-02-06', 'Minorista', 'Cheque', 179.39),
(6, 7, 3, 8, '2026-03-14', 'Mayorista', 'Cheque', 263.2),
(7, 1, 1, NULL, '2026-06-11', 'Minorista', 'Efectivo', 235.6),
(17, 9, 1, NULL, '2026-01-28', 'Mayorista', 'Tarjeta de Credito', 306.95),
(22, 4, 2, NULL, '2026-05-08', 'Minorista', 'Efectivo', 466.18),
(22, 6, 2, 5, '2026-04-11', 'Mayorista', 'Efectivo', 347.36),
(3, 9, 1, 6, '2026-01-08', 'Mayorista', 'Transferencia', 877.68),
(20, 9, 1, NULL, '2026-03-22', 'Mayorista', 'Efectivo', 196.88),
(29, 2, 1, 5, '2026-05-07', 'Minorista', 'Transferencia', 134.64),
(9, 1, 1, NULL, '2026-03-02', 'Mayorista', 'Efectivo', 865.22),
(18, 7, 3, 3, '2026-05-02', 'Minorista', 'Transferencia', 234.58),
(12, 1, 1, 4, '2026-06-04', 'Minorista', 'Transferencia', 287.4),
(1, 3, 1, 7, '2026-06-28', 'Minorista', 'Tarjeta de Credito', 94.73),
(28, 8, 3, NULL, '2026-04-12', 'Mayorista', 'Transferencia', 187.5),
(22, 4, 2, 2, '2026-03-12', 'Minorista', 'Cheque', 233.8),
(19, 5, 2, NULL, '2026-03-24', 'Mayorista', 'Transferencia', 864.72),
(9, 1, 1, 9, '2026-06-24', 'Minorista', 'Tarjeta de Credito', 202.18),
(22, 2, 1, 5, '2026-06-14', 'Minorista', 'Transferencia', 202.8),
(22, 7, 3, NULL, '2026-05-19', 'Minorista', 'Transferencia', 198.64),
(7, 7, 3, NULL, '2026-03-15', 'Minorista', 'Cheque', 130.18),
(10, 9, 1, NULL, '2026-01-27', 'Minorista', 'Tarjeta de Credito', 200.96),
(8, 8, 3, NULL, '2026-04-14', 'Minorista', 'Tarjeta de Credito', 407.81),
(29, 2, 1, 9, '2026-04-02', 'Minorista', 'Tarjeta de Credito', 119.04),
(26, 8, 3, NULL, '2026-05-11', 'Minorista', 'Cheque', 489.48),
(15, 5, 2, NULL, '2026-03-25', 'Minorista', 'Cheque', 318.2),
(9, 6, 2, NULL, '2026-02-05', 'Minorista', 'Tarjeta de Credito', 299.18),
(14, 6, 2, NULL, '2026-02-27', 'Minorista', 'Cheque', 294.5),
(16, 1, 1, 7, '2026-04-18', 'Minorista', 'Tarjeta de Credito', 258.4),
(1, 7, 3, NULL, '2026-04-24', 'Minorista', 'Tarjeta de Credito', 100.06),
(3, 7, 3, NULL, '2026-01-09', 'Mayorista', 'Cheque', 989.75),
(25, 7, 3, NULL, '2026-04-09', 'Mayorista', 'Efectivo', 561.6),
(21, 2, 1, NULL, '2026-01-08', 'Minorista', 'Tarjeta de Credito', 119.76),
(8, 3, 1, 4, '2026-04-23', 'Minorista', 'Transferencia', 132.72),
(4, 10, 4, 7, '2026-04-23', 'Mayorista', 'Tarjeta de Credito', 514.56),
(4, 5, 2, NULL, '2026-01-26', 'Minorista', 'Efectivo', 195.9),
(17, 6, 2, NULL, '2026-04-04', 'Mayorista', 'Cheque', 598.58),
(24, 9, 1, 9, '2026-04-15', 'Minorista', 'Cheque', 460.52),
(29, 8, 3, NULL, '2026-05-22', 'Mayorista', 'Cheque', 1165.3),
(16, 4, 2, 5, '2026-05-23', 'Minorista', 'Transferencia', 309.92),
(18, 4, 2, NULL, '2026-04-15', 'Minorista', 'Efectivo', 105.8),
(13, 4, 2, NULL, '2026-04-18', 'Minorista', 'Transferencia', 264.38),
(9, 5, 2, 4, '2026-03-04', 'Mayorista', 'Tarjeta de Credito', 376.0),
(9, 10, 4, NULL, '2026-03-04', 'Minorista', 'Tarjeta de Credito', 252.42),
(1, 9, 1, 1, '2026-05-10', 'Mayorista', 'Tarjeta de Credito', 1702.4),
(15, 6, 2, 8, '2026-01-27', 'Mayorista', 'Efectivo', 552.75),
(5, 3, 1, NULL, '2026-01-08', 'Minorista', 'Efectivo', 487.84),
(10, 10, 4, 10, '2026-01-20', 'Minorista', 'Efectivo', 72.75),
(22, 2, 1, 2, '2026-02-01', 'Mayorista', 'Cheque', 1130.68);
GO

-- ----- detalle_venta (100) -----
INSERT INTO detalle_venta (id_venta, id_producto, cantidad, precio_unitario) VALUES
(1, 2, 8, 26.25),
(1, 2, 17, 26.25),
(1, 11, 8, 42.17),
(2, 8, 7, 37.5),
(2, 15, 8, 43.42),
(3, 16, 2, 58.92),
(3, 13, 1, 61.55),
(4, 7, 14, 18.8),
(5, 19, 4, 58.9),
(6, 20, 7, 43.85),
(7, 3, 4, 55.54),
(7, 19, 3, 58.9),
(7, 9, 2, 33.66),
(8, 15, 8, 43.42),
(9, 6, 19, 24.56),
(9, 18, 14, 29.36),
(10, 9, 8, 24.61),
(11, 9, 4, 33.66),
(12, 5, 13, 30.66),
(12, 6, 19, 24.56),
(13, 18, 2, 39.94),
(13, 14, 2, 26.38),
(13, 2, 3, 33.98),
(14, 14, 2, 26.38),
(14, 8, 2, 50.96),
(14, 6, 4, 33.18),
(15, 6, 1, 33.18),
(15, 13, 1, 61.55),
(16, 8, 5, 37.5),
(17, 18, 3, 39.94),
(17, 1, 1, 46.66),
(17, 9, 2, 33.66),
(18, 20, 8, 43.85),
(18, 13, 11, 46.72),
(19, 14, 1, 26.38),
(19, 11, 3, 58.6),
(20, 10, 2, 52.9),
(20, 7, 4, 24.25),
(21, 18, 1, 39.94),
(21, 10, 3, 52.9),
(22, 7, 4, 24.25),
(22, 6, 1, 33.18),
(23, 10, 2, 52.9),
(23, 7, 2, 24.25),
(23, 1, 1, 46.66),
(24, 13, 4, 61.55),
(24, 13, 2, 61.55),
(24, 5, 1, 38.51),
(25, 15, 2, 59.52),
(26, 17, 4, 49.25),
(26, 18, 4, 39.94),
(26, 6, 4, 33.18),
(27, 8, 3, 50.96),
(27, 15, 1, 59.52),
(27, 10, 2, 52.9),
(28, 5, 2, 38.51),
(28, 3, 4, 55.54),
(29, 19, 1, 58.9),
(29, 19, 4, 58.9),
(30, 8, 3, 50.96),
(30, 14, 4, 26.38),
(31, 5, 1, 38.51),
(31, 13, 1, 61.55),
(32, 7, 19, 18.8),
(32, 11, 15, 42.17),
(33, 1, 6, 37.18),
(33, 12, 12, 28.21),
(34, 20, 2, 59.88),
(35, 6, 1, 33.18),
(35, 6, 3, 33.18),
(36, 19, 12, 42.88),
(37, 18, 4, 39.94),
(37, 12, 1, 36.14),
(38, 15, 9, 43.42),
(38, 14, 10, 20.78),
(39, 19, 3, 58.9),
(39, 11, 2, 58.6),
(39, 3, 3, 55.54),
(40, 1, 20, 37.18),
(40, 11, 10, 42.17),
(41, 1, 2, 46.66),
(41, 3, 2, 55.54),
(41, 14, 4, 26.38),
(42, 10, 2, 52.9),
(43, 18, 3, 39.94),
(43, 12, 4, 36.14),
(44, 7, 20, 18.8),
(45, 8, 3, 50.96),
(45, 6, 3, 33.18),
(46, 16, 8, 42.21),
(46, 1, 14, 37.18),
(46, 16, 20, 42.21),
(47, 16, 7, 42.21),
(47, 19, 6, 42.88),
(48, 14, 2, 26.38),
(48, 17, 4, 49.25),
(48, 15, 4, 59.52),
(49, 7, 3, 24.25),
(50, 20, 20, 43.85),
(50, 10, 6, 42.28);
GO

-- ----- inventario (100) -----
INSERT INTO inventario (id_producto, id_sucursal, stock, estado_inventario, observaciones) VALUES
(1, 1, 39, 'Disponible', 'Pendiente de revision fisica'),
(1, 2, 100, 'Disponible', 'Pendiente de revision fisica'),
(1, 3, 99, 'Disponible', NULL),
(1, 4, 68, 'Disponible', 'Producto de alta rotacion'),
(1, 5, 97, 'Disponible', 'Reposicion reciente'),
(2, 1, 43, 'Disponible', NULL),
(2, 2, 111, 'Disponible', NULL),
(2, 3, 85, 'Disponible', NULL),
(2, 4, 112, 'Disponible', 'Reposicion reciente'),
(2, 5, 64, 'Disponible', 'Producto de alta rotacion'),
(3, 1, 79, 'Disponible', 'Reposicion reciente'),
(3, 2, 92, 'Disponible', 'Reposicion reciente'),
(3, 3, 44, 'Disponible', NULL),
(3, 4, 28, 'Disponible', 'Producto de alta rotacion'),
(3, 5, 17, 'Stock Bajo', 'Reposicion reciente'),
(4, 1, 111, 'Disponible', 'Pendiente de revision fisica'),
(4, 2, 86, 'Disponible', NULL),
(4, 3, 115, 'Disponible', NULL),
(4, 4, 46, 'Disponible', 'Producto de temporada'),
(4, 5, 25, 'Disponible', 'Producto de temporada'),
(5, 1, 98, 'Disponible', 'Pendiente de revision fisica'),
(5, 2, 99, 'Disponible', 'Producto de temporada'),
(5, 3, 44, 'Disponible', NULL),
(5, 4, 79, 'Disponible', 'Producto de temporada'),
(5, 5, 66, 'Disponible', 'Producto de alta rotacion'),
(6, 1, 86, 'Disponible', 'Producto de alta rotacion'),
(6, 2, 65, 'Disponible', NULL),
(6, 3, 51, 'Disponible', NULL),
(6, 4, 42, 'Disponible', 'Producto de alta rotacion'),
(6, 5, 21, 'Disponible', 'Reposicion reciente'),
(7, 1, 96, 'Disponible', NULL),
(7, 2, 120, 'Disponible', NULL),
(7, 3, 85, 'Disponible', 'Producto de alta rotacion'),
(7, 4, 107, 'Disponible', NULL),
(7, 5, 115, 'Disponible', 'Pendiente de revision fisica'),
(8, 1, 83, 'Disponible', 'Producto de alta rotacion'),
(8, 2, 107, 'Disponible', NULL),
(8, 3, 32, 'Disponible', 'Producto de temporada'),
(8, 4, 76, 'Disponible', NULL),
(8, 5, 66, 'Disponible', 'Pendiente de revision fisica'),
(9, 1, 33, 'Disponible', NULL),
(9, 2, 65, 'Disponible', NULL),
(9, 3, 114, 'Disponible', 'Producto de temporada'),
(9, 4, 21, 'Disponible', 'Producto de temporada'),
(9, 5, 54, 'Disponible', 'Producto de temporada'),
(10, 1, 52, 'Disponible', 'Pendiente de revision fisica'),
(10, 2, 95, 'Disponible', 'Producto de alta rotacion'),
(10, 3, 119, 'Disponible', 'Reposicion reciente'),
(10, 4, 52, 'Disponible', 'Producto de temporada'),
(10, 5, 98, 'Disponible', 'Producto de temporada'),
(11, 1, 46, 'Disponible', NULL),
(11, 2, 61, 'Disponible', NULL),
(11, 3, 107, 'Disponible', NULL),
(11, 4, 14, 'Stock Bajo', 'Producto de temporada'),
(11, 5, 21, 'Disponible', 'Pendiente de revision fisica'),
(12, 1, 42, 'Disponible', 'Pendiente de revision fisica'),
(12, 2, 24, 'Disponible', NULL),
(12, 3, 61, 'Disponible', NULL),
(12, 4, 75, 'Disponible', NULL),
(12, 5, 10, 'Stock Bajo', NULL),
(13, 1, 79, 'Disponible', 'Producto de temporada'),
(13, 2, 62, 'Disponible', 'Producto de alta rotacion'),
(13, 3, 34, 'Disponible', NULL),
(13, 4, 56, 'Disponible', NULL),
(13, 5, 106, 'Disponible', 'Producto de temporada'),
(14, 1, 90, 'Disponible', 'Producto de temporada'),
(14, 2, 107, 'Disponible', 'Producto de alta rotacion'),
(14, 3, 36, 'Disponible', 'Pendiente de revision fisica'),
(14, 4, 80, 'Disponible', 'Reposicion reciente'),
(14, 5, 46, 'Disponible', 'Producto de temporada'),
(15, 1, 99, 'Disponible', 'Producto de temporada'),
(15, 2, 25, 'Disponible', 'Producto de alta rotacion'),
(15, 3, 90, 'Disponible', NULL),
(15, 4, 112, 'Disponible', 'Reposicion reciente'),
(15, 5, 100, 'Disponible', 'Reposicion reciente'),
(16, 1, 49, 'Disponible', NULL),
(16, 2, 11, 'Stock Bajo', NULL),
(16, 3, 62, 'Disponible', 'Producto de alta rotacion'),
(16, 4, 38, 'Disponible', NULL),
(16, 5, 24, 'Disponible', 'Producto de temporada'),
(17, 1, 25, 'Disponible', NULL),
(17, 2, 116, 'Disponible', 'Reposicion reciente'),
(17, 3, 73, 'Disponible', NULL),
(17, 4, 47, 'Disponible', NULL),
(17, 5, 100, 'Disponible', 'Pendiente de revision fisica'),
(18, 1, 63, 'Disponible', NULL),
(18, 2, 71, 'Disponible', 'Producto de temporada'),
(18, 3, 41, 'Disponible', 'Producto de temporada'),
(18, 4, 80, 'Disponible', 'Reposicion reciente'),
(18, 5, 59, 'Disponible', 'Reposicion reciente'),
(19, 1, 86, 'Disponible', NULL),
(19, 2, 105, 'Disponible', 'Reposicion reciente'),
(19, 3, 120, 'Disponible', 'Producto de alta rotacion'),
(19, 4, 45, 'Disponible', NULL),
(19, 5, 111, 'Disponible', NULL),
(20, 1, 63, 'Disponible', 'Pendiente de revision fisica'),
(20, 2, 110, 'Disponible', NULL),
(20, 3, 44, 'Disponible', NULL),
(20, 4, 10, 'Stock Bajo', 'Pendiente de revision fisica'),
(20, 5, 102, 'Disponible', 'Pendiente de revision fisica');
GO

-- ----- movimientos_inventario (20) -----
INSERT INTO movimientos_inventario (id_producto, id_sucursal, id_empleado, tipo_movimiento, cantidad, motivo, fecha_movimiento) VALUES
(19, 5, 8, 'Entrada', 31, 'Transferencia entre sucursales', '2026-04-12'),
(11, 5, 9, 'Salida', 32, 'Merma por dano en bodega', '2026-02-23'),
(8, 5, 7, 'Entrada', 29, 'Compra a proveedor', '2026-03-24'),
(16, 4, 7, 'Entrada', 34, 'Compra a proveedor', '2026-02-17'),
(19, 3, 2, 'Salida', 9, 'Transferencia a otra sucursal', '2026-01-24'),
(5, 4, 3, 'Entrada', 33, 'Devolucion de cliente reintegrada a stock', '2026-03-20'),
(13, 1, 6, 'Salida', 23, 'Transferencia a otra sucursal', '2026-05-02'),
(20, 1, 4, 'Salida', 17, 'Venta al por menor', '2026-04-04'),
(4, 4, 3, 'Salida', 4, 'Venta al por menor', '2026-03-26'),
(2, 3, 6, 'Salida', 30, 'Venta al por mayor', '2026-02-17'),
(14, 5, 3, 'Entrada', 14, 'Compra a proveedor', '2026-05-28'),
(13, 5, 4, 'Salida', 40, 'Venta al por mayor', '2026-02-15'),
(9, 4, 5, 'Entrada', 32, 'Devolucion de cliente reintegrada a stock', '2026-06-18'),
(6, 1, 8, 'Salida', 40, 'Merma por dano en bodega', '2026-06-14'),
(9, 4, 5, 'Entrada', 27, 'Devolucion de cliente reintegrada a stock', '2026-01-08'),
(13, 5, 6, 'Salida', 21, 'Venta al por menor', '2026-06-13'),
(9, 1, 10, 'Entrada', 34, 'Devolucion de cliente reintegrada a stock', '2026-02-20'),
(12, 2, 4, 'Salida', 11, 'Venta al por menor', '2026-06-21'),
(2, 3, 8, 'Entrada', 40, 'Devolucion de cliente reintegrada a stock', '2026-06-05'),
(3, 3, 6, 'Salida', 14, 'Venta al por mayor', '2026-02-26');
GO

-- ----- devoluciones (20) -----
INSERT INTO devoluciones (id_venta, id_producto, id_empleado, cantidad, motivo, fecha_devolucion) VALUES
(35, 6, 9, 3, 'Color no era el solicitado', '2026-02-09'),
(31, 13, 6, 1, 'Cliente insatisfecho', '2026-01-05'),
(49, 7, 7, 3, 'Color no era el solicitado', '2026-01-26'),
(26, 17, 5, 3, 'Talla incorrecta', '2026-04-12'),
(44, 7, 10, 2, 'Cambio por otro modelo', '2026-03-04'),
(44, 7, 8, 1, 'Dano en el transporte', '2026-05-11'),
(40, 1, 2, 3, 'Cliente insatisfecho', '2026-06-10'),
(42, 10, 2, 1, 'Talla incorrecta', '2026-01-10'),
(32, 7, 2, 1, 'Dano en el transporte', '2026-02-13'),
(30, 14, 9, 2, 'Dano en el transporte', '2026-06-24'),
(10, 9, 2, 2, 'Dano en el transporte', '2026-04-09'),
(3, 13, 4, 2, 'Cliente insatisfecho', '2026-02-28'),
(24, 13, 6, 3, 'Cambio por otro modelo', '2026-03-02'),
(26, 18, 4, 1, 'Cliente insatisfecho', '2026-01-22'),
(14, 6, 10, 1, 'Talla incorrecta', '2026-03-08'),
(9, 6, 2, 3, 'Producto defectuoso', '2026-05-07'),
(15, 13, 3, 3, 'Talla incorrecta', '2026-03-28'),
(10, 9, 9, 2, 'Producto defectuoso', '2026-01-22'),
(2, 8, 1, 2, 'Producto defectuoso', '2026-05-11'),
(2, 8, 5, 1, 'Producto defectuoso', '2026-06-14');
GO

-- ----- historial_actividades (15) -----
INSERT INTO historial_actividades (fecha, id_empleado, descripcion) VALUES
('2026-06-03', 9, 'Se actualizo el stock de un producto'),
('2026-03-17', 8, 'Se modifico el precio de un producto'),
('2026-04-17', 10, 'Se actualizo el stock de un producto'),
('2026-06-26', 4, 'Se registro una nueva venta en el sistema'),
('2026-04-21', 9, 'Se actualizo la informacion de un cliente'),
('2026-04-28', 1, 'Se registro una nueva venta en el sistema'),
('2026-06-04', 7, 'Se creo una nueva promocion'),
('2026-01-03', 8, 'Se modifico el precio de un producto'),
('2026-01-05', 6, 'Se registro una devolucion de cliente'),
('2026-04-20', 5, 'Se registro el ingreso de mercaderia de un proveedor'),
('2026-04-17', 9, 'Se actualizo la informacion de un cliente'),
('2026-01-26', 10, 'Se creo una nueva promocion'),
('2026-04-15', 2, 'Se agrego un nuevo producto al catalogo'),
('2026-03-27', 4, 'Se creo una nueva promocion'),
('2026-04-24', 8, 'Se creo una nueva promocion');
GO
