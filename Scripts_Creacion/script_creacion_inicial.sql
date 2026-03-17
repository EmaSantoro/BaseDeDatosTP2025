USE GD1C2025;
GO

-- //////////////////////////////////////////////////////////////
-- ELIMINACION DE TABLAS Y PROCEDIMIENTOS ANTERIORES
-- //////////////////////////////////////////////////////////////
DROP PROCEDURE IF EXISTS BDGRUPO.Migrar_Datos;

IF OBJECT_ID('BDGRUPO.Envio', 'U') IS NOT NULL DROP TABLE BDGRUPO.Envio;
IF OBJECT_ID('BDGRUPO.FacturaDetalle', 'U') IS NOT NULL DROP TABLE BDGRUPO.FacturaDetalle;
IF OBJECT_ID('BDGRUPO.Factura', 'U') IS NOT NULL DROP TABLE BDGRUPO.Factura;
IF OBJECT_ID('BDGRUPO.DetallePedido', 'U') IS NOT NULL DROP TABLE BDGRUPO.DetallePedido;
IF OBJECT_ID('BDGRUPO.CancelacionPedido', 'U') IS NOT NULL DROP TABLE BDGRUPO.CancelacionPedido;
IF OBJECT_ID('BDGRUPO.Pedido', 'U') IS NOT NULL DROP TABLE BDGRUPO.Pedido;
IF OBJECT_ID('BDGRUPO.DetalleCompra', 'U') IS NOT NULL DROP TABLE BDGRUPO.DetalleCompra;
IF OBJECT_ID('BDGRUPO.Compra', 'U') IS NOT NULL DROP TABLE BDGRUPO.Compra;
IF OBJECT_ID('BDGRUPO.MaterialPorSillon', 'U') IS NOT NULL DROP TABLE BDGRUPO.MaterialPorSillon;
IF OBJECT_ID('BDGRUPO.Sillon', 'U') IS NOT NULL DROP TABLE BDGRUPO.Sillon;
IF OBJECT_ID('BDGRUPO.Medida', 'U') IS NOT NULL DROP TABLE BDGRUPO.Medida;
IF OBJECT_ID('BDGRUPO.Modelo', 'U') IS NOT NULL DROP TABLE BDGRUPO.Modelo;
IF OBJECT_ID('BDGRUPO.Relleno', 'U') IS NOT NULL DROP TABLE BDGRUPO.Relleno;
IF OBJECT_ID('BDGRUPO.Madera', 'U') IS NOT NULL DROP TABLE BDGRUPO.Madera;
IF OBJECT_ID('BDGRUPO.Tela', 'U') IS NOT NULL DROP TABLE BDGRUPO.Tela;
IF OBJECT_ID('BDGRUPO.Material', 'U') IS NOT NULL DROP TABLE BDGRUPO.Material;
IF OBJECT_ID('BDGRUPO.Proveedor', 'U') IS NOT NULL DROP TABLE BDGRUPO.Proveedor;
IF OBJECT_ID('BDGRUPO.Sucursal', 'U') IS NOT NULL DROP TABLE BDGRUPO.Sucursal;
IF OBJECT_ID('BDGRUPO.Cliente', 'U') IS NOT NULL DROP TABLE BDGRUPO.Cliente;
IF OBJECT_ID('BDGRUPO.Localidad', 'U') IS NOT NULL DROP TABLE BDGRUPO.Localidad;
IF OBJECT_ID('BDGRUPO.Provincia', 'U') IS NOT NULL DROP TABLE BDGRUPO.Provincia;
GO

-- Primero eliminamos el esquema (si está vacío)
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'BDGRUPO')
    DROP SCHEMA BDGRUPO;
GO

-- //////////////////////////////////////////////////////////////
-- CREACION DE TABLAS
-- //////////////////////////////////////////////////////////////
CREATE SCHEMA BDGRUPO;
GO

-- PROVINCIA
CREATE TABLE BDGRUPO.Provincia (
    Provincia_Nombre NVARCHAR(100) PRIMARY KEY 
);
GO

-- LOCALIDAD
CREATE TABLE BDGRUPO.Localidad (
    Localidad_ID BIGINT PRIMARY KEY IDENTITY(1, 1),
    Localidad_Nombre NVARCHAR(100),
    Localidad_Provincia NVARCHAR(100),
    FOREIGN KEY (Localidad_Provincia) REFERENCES BDGRUPO.Provincia(Provincia_Nombre)
);
GO

-- CLIENTE
CREATE TABLE BDGRUPO.Cliente (
    Cliente_Dni BIGINT PRIMARY KEY,
    Cliente_Apellido NVARCHAR(100),
    Cliente_Nombre NVARCHAR(100),
    Cliente_Localidad BIGINT,
    Cliente_Mail NVARCHAR(100),
    Cliente_FechaNacimiento DATE,
    Cliente_Telefono NVARCHAR(20),
    Cliente_Direccion NVARCHAR(255),
    FOREIGN KEY (Cliente_Localidad) REFERENCES BDGRUPO.Localidad(Localidad_ID)
);
GO

-- SUCURSAL
CREATE TABLE BDGRUPO.Sucursal (
    Sucursal_NroSucursal BIGINT PRIMARY KEY,
    Sucursal_Localidad BIGINT,
    Sucursal_Direccion NVARCHAR(255),
    Sucursal_Telefono NVARCHAR(20),
    Sucursal_Mail NVARCHAR(100),
    FOREIGN KEY (Sucursal_Localidad) REFERENCES BDGRUPO.Localidad(Localidad_ID)
);
GO
-- PROVEEDOR
CREATE TABLE BDGRUPO.Proveedor (
    Proveedor_Cuit NVARCHAR(255) PRIMARY KEY,
    Proveedor_Telefono NVARCHAR(20),
    Proveedor_Mail NVARCHAR(100),
    Proveedor_Direccion NVARCHAR(255),
    Proveedor_Localidad BIGINT,
    Proveedor_RazonSocial NVARCHAR(100),
    FOREIGN KEY (Proveedor_Localidad) REFERENCES BDGRUPO.Localidad(Localidad_ID)
);
GO
-- MATERIAL
CREATE TABLE BDGRUPO.Material (
    Material_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Material_Nombre NVARCHAR(255),
    Material_Descripcion NVARCHAR(255),
    Material_Precio DECIMAL(10,2),
    Material_Tipo NVARCHAR(100)
);
GO
-- TELA
CREATE TABLE BDGRUPO.Tela (
    Tela_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Material_ID BIGINT,
    Tela_Color NVARCHAR(100),
    Tela_Textura NVARCHAR(100),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPO.Material(Material_ID)
);
GO
-- MADERA
CREATE TABLE BDGRUPO.Madera (
    Madera_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Material_ID BIGINT,
    Madera_Color NVARCHAR(255),
    Madera_Dureza NVARCHAR(255),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPO.Material(Material_ID)
);
GO
-- RELLENO
CREATE TABLE BDGRUPO.Relleno (
    Relleno_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Material_ID BIGINT,
    Relleno_Densidad NVARCHAR(50),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPO.Material(Material_ID)
);
GO
-- MODELO
CREATE TABLE BDGRUPO.Modelo (
    Modelo_Codigo BIGINT PRIMARY KEY,
    Modelo_Descripcion NVARCHAR(255),
    Modelo_Precio DECIMAL(10,2)
);
GO
-- MEDIDA
CREATE TABLE BDGRUPO.Medida (
    Medida_Codigo BIGINT PRIMARY KEY,
    Medida_Alto DECIMAL(5,2),
    Medida_Ancho DECIMAL(5,2),
    Medida_Profundidad DECIMAL(5,2),
    Medida_Precio DECIMAL(10,2)
);
GO
-- SILLON
CREATE TABLE BDGRUPO.Sillon (
    Sillon_Codigo BIGINT PRIMARY KEY,
    Sillon_Modelo_Codigo BIGINT,
    Medida_Codigo BIGINT,
    FOREIGN KEY (Sillon_Modelo_Codigo) REFERENCES BDGRUPO.Modelo(Modelo_Codigo),
    FOREIGN KEY (Medida_Codigo) REFERENCES BDGRUPO.Medida(Medida_Codigo)
);
GO
-- MATERIAL POR SILLON
CREATE TABLE BDGRUPO.MaterialPorSillon (
    Material_Sillon_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Sillon_Codigo BIGINT,
    Material_ID BIGINT,
    FOREIGN KEY (Sillon_Codigo) REFERENCES BDGRUPO.Sillon(Sillon_Codigo),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPO.Material(Material_ID)
);
GO

-- COMPRA
CREATE TABLE BDGRUPO.Compra (
    Compra_Numero DECIMAL(18, 0) PRIMARY KEY,
    Sucursal_NroSucursal BIGINT,
    Proveedor_Cuit NVARCHAR(255),
    Compra_Fecha DATE,
    Compra_Total DECIMAL(10,2),
    FOREIGN KEY (Sucursal_NroSucursal) REFERENCES BDGRUPO.Sucursal(Sucursal_NroSucursal),
    FOREIGN KEY (Proveedor_Cuit) REFERENCES BDGRUPO.Proveedor(Proveedor_Cuit)
);
GO

-- DETALLE COMPRA
CREATE TABLE BDGRUPO.DetalleCompra (
    Detalle_Compra_ID BIGINT PRIMARY KEY IDENTITY (1,1),
    Compra_Numero DECIMAL(18, 0),
    Material_ID BIGINT,
    Detalle_Compra_Precio DECIMAL(10,2),
    Detalle_Compra_Cantidad BIGINT,
    Detalle_Compra_Subtotal DECIMAL(10,2),
    FOREIGN KEY (Compra_Numero) REFERENCES BDGRUPO.Compra(Compra_Numero),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPO.Material(Material_ID)
);
GO

-- PEDIDO
CREATE TABLE BDGRUPO.Pedido (
    Pedido_Numero DECIMAL(18, 0) PRIMARY KEY,
    Pedido_Cliente BIGINT,
    Pedido_Sucursal BIGINT,
    Pedido_Estado NVARCHAR(50),
    Pedido_Fecha DATETIME2(6),
    Pedido_Total DECIMAL(10, 2),
    FOREIGN KEY (Pedido_Cliente) REFERENCES BDGRUPO.Cliente(Cliente_Dni),
    FOREIGN KEY (Pedido_Sucursal) REFERENCES BDGRUPO.Sucursal(Sucursal_NroSucursal)
);
GO

-- CANCELACION PEDIDO
CREATE TABLE BDGRUPO.CancelacionPedido (
    Cancelacion_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Pedido_Numero DECIMAL(18, 0),
    Pedido_Cancelacion_Fecha DATE,
    Pedido_Cancelacion_Motivo NVARCHAR(255),
    FOREIGN KEY (Pedido_Numero) REFERENCES BDGRUPO.Pedido(Pedido_Numero)
);
GO


-- DETALLE PEDIDO
CREATE TABLE BDGRUPO.DetallePedido (
    Detalle_Pedido_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Pedido_Numero DECIMAL(18, 0),
    Sillon_Codigo BIGINT,
    Detalle_Pedido_Cantidad BIGINT,
    Detalle_Pedido_Precio DECIMAL(10, 2),
    Detalle_Pedido_SubTotal DECIMAL(10, 2),
    FOREIGN KEY (Pedido_Numero) REFERENCES BDGRUPO.Pedido(Pedido_Numero),
    FOREIGN KEY (Sillon_Codigo) REFERENCES BDGRUPO.Sillon(Sillon_Codigo)
);
GO
-- FACTURA
CREATE TABLE BDGRUPO.Factura (
    Factura_Numero BIGINT PRIMARY KEY,
    Factura_Fecha DATE,
    Factura_Sucursal BIGINT,
    Factura_Total DECIMAL(10,2),
    FOREIGN KEY (Factura_Sucursal) REFERENCES BDGRUPO.Sucursal(Sucursal_NroSucursal)
);
GO

-- FACTURA DETALLE
CREATE TABLE BDGRUPO.FacturaDetalle (
    Detalle_ID BIGINT PRIMARY KEY IDENTITY(1,1),
    Factura_Numero BIGINT,
    Detalle_Factura_Pedido_ID BIGINT,
    Detalle_Factura_Cantidad BIGINT,
    Detalle_Factura_Precio DECIMAL(10, 2),
    Detalle_Factura_SubTotal DECIMAL(10, 2),
    Sillon_Codigo BIGINT,
    FOREIGN KEY (Sillon_Codigo) REFERENCES BDGRUPO.Sillon(Sillon_Codigo),
    FOREIGN KEY (Factura_Numero) REFERENCES BDGRUPO.Factura(Factura_Numero),
    FOREIGN KEY (Detalle_Factura_Pedido_ID) REFERENCES BDGRUPO.DetallePedido(Detalle_Pedido_ID)
);
GO

-- ENVIO
CREATE TABLE BDGRUPO.Envio (
    Envio_Numero DECIMAL(18, 0) PRIMARY KEY,
    Factura_Numero BIGINT,
    Envio_Fecha_Programada DATE,
    Envio_Fecha DATE,
    Envio_ImporteTraslado DECIMAL(10,2),
    Envio_ImporteSubida DECIMAL(10,2),
    Envio_Total DECIMAL(10,2),
    FOREIGN KEY (Factura_Numero) REFERENCES BDGRUPO.Factura(Factura_Numero)
);
GO

-- //////////////////////////////////////////////////////////////
-- MIGRACION DE DATOS
-- //////////////////////////////////////////////////////////////

CREATE PROCEDURE BDGRUPO.Migrar_Datos
AS
BEGIN

--ASIGNACION DE LOS VALORES DE TABLA MAESTRA A LAS TABLAS CREADAS

--Provincia
INSERT INTO BDGRUPO.Provincia (Provincia_Nombre)
SELECT DISTINCT Localidad_Provincia
FROM (
	SELECT Sucursal_Provincia AS Localidad_Provincia
	FROM gd_esquema.Maestra
	UNION
	SELECT Cliente_Provincia
	FROM gd_esquema.Maestra
	UNION
	SELECT Proveedor_Provincia
	FROM gd_esquema.Maestra
) AS Provincias
WHERE Localidad_Provincia IS NOT NULL

--Localidad
INSERT INTO BDGRUPO.Localidad (Localidad_Nombre, Localidad_Provincia)
SELECT DISTINCT L.Localidad, L.Provincia
FROM (
    SELECT Sucursal_Localidad AS Localidad, Sucursal_Provincia AS Provincia
    FROM gd_esquema.Maestra
    WHERE Sucursal_Localidad IS NOT NULL AND Sucursal_Provincia IS NOT NULL
    UNION
    SELECT Cliente_Localidad, Cliente_Provincia
    FROM gd_esquema.Maestra
    WHERE Cliente_Localidad IS NOT NULL AND Cliente_Provincia IS NOT NULL
    UNION
    SELECT Proveedor_Localidad, Proveedor_Provincia
    FROM gd_esquema.Maestra
    WHERE Proveedor_Localidad IS NOT NULL AND Proveedor_Provincia IS NOT NULL
) L;

--Cliente
INSERT INTO BDGRUPO.Cliente (Cliente_Dni, Cliente_Apellido, Cliente_Nombre, Cliente_Localidad, Cliente_Mail, Cliente_FechaNacimiento, Cliente_Telefono, Cliente_Direccion)
SELECT DISTINCT M.Cliente_Dni, M.Cliente_Apellido, M.Cliente_Nombre, BDL.Localidad_ID, M.Cliente_Mail, M.Cliente_FechaNacimiento, M.Cliente_Telefono, M.Cliente_Direccion
FROM gd_esquema.Maestra M
INNER JOIN BDGRUPO.Localidad BDL ON M.Cliente_Localidad = BDL.Localidad_Nombre AND M.Cliente_Provincia = BDL.Localidad_Provincia
WHERE M.Cliente_Dni IS NOT NULL;

--Sucursal
INSERT INTO BDGRUPO.Sucursal (Sucursal_NroSucursal, Sucursal_Localidad, Sucursal_Direccion, Sucursal_Telefono, Sucursal_Mail) 
SELECT DISTINCT M.Sucursal_NroSucursal, BDL.Localidad_ID, M.Sucursal_Direccion, M.Sucursal_Telefono, M.Sucursal_Mail
FROM gd_esquema.Maestra M
INNER JOIN BDGRUPO.Localidad BDL ON M.Sucursal_Localidad = BDL.Localidad_Nombre AND M.Sucursal_Provincia = BDL.Localidad_Provincia
WHERE M.Sucursal_NroSucursal IS NOT NULL;

--Proveedor
INSERT INTO BDGRUPO.Proveedor (Proveedor_Cuit, Proveedor_Telefono, Proveedor_Mail, Proveedor_Direccion, Proveedor_Localidad, Proveedor_RazonSocial)
SELECT DISTINCT M.Proveedor_Cuit, M.Proveedor_Telefono, M.Proveedor_Mail, M.Proveedor_Direccion, BDL.Localidad_ID, M.Proveedor_RazonSocial 
FROM gd_esquema.Maestra M
INNER JOIN BDGRUPO.Localidad BDL ON M.Proveedor_Localidad = BDL.Localidad_Nombre AND M.Proveedor_Provincia = BDL.Localidad_Provincia
WHERE M.Proveedor_Cuit IS NOT NULL;

--Material
INSERT INTO BDGRUPO.Material (Material_Nombre, Material_Descripcion, Material_Precio, Material_Tipo)
SELECT DISTINCT Material_Nombre, Material_Descripcion, Material_Precio, Material_Tipo
FROM gd_esquema.Maestra
WHERE Material_Nombre IS NOT NULL;

--Tela 
INSERT INTO BDGRUPO.Tela (Tela_Color, Tela_Textura, Material_ID)
SELECT DISTINCT M.Tela_Color, M.Tela_Textura, BDM.Material_ID
FROM gd_esquema.Maestra M
JOIN BDGRUPO.Material BDM ON M.Material_Nombre = BDM.Material_Nombre
WHERE M.Tela_Color IS NOT NULL AND M.Tela_Textura IS NOT NULL;

--Relleno
INSERT INTO BDGRUPO.Relleno (Relleno_Densidad, Material_ID)
SELECT DISTINCT M.Relleno_Densidad, BDM.Material_ID
FROM gd_esquema.Maestra M
JOIN BDGRUPO.Material BDM ON M.Material_Nombre = BDM.Material_Nombre
WHERE M.Relleno_Densidad IS NOT NULL;

--Madera 
INSERT INTO BDGRUPO.Madera (Material_ID, Madera_Color, Madera_Dureza)
SELECT DISTINCT BDM.Material_ID, M.Madera_Color, M.Madera_Dureza
FROM gd_esquema.Maestra M
JOIN BDGRUPO.Material BDM ON M.Material_Nombre = BDM.Material_Nombre
WHERE M.Madera_Color IS NOT NULL AND M.Madera_Dureza IS NOT NULL;

--Modelo
INSERT INTO BDGRUPO.Modelo (Modelo_Codigo, Modelo_Descripcion, Modelo_Precio)
SELECT DISTINCT Sillon_Modelo_Codigo, Sillon_Modelo_Descripcion, Sillon_Modelo_Precio
FROM gd_esquema.Maestra
WHERE Sillon_Modelo_Codigo IS NOT NULL;

--Sillon
INSERT INTO BDGRUPO.Sillon (Sillon_Codigo, Sillon_Modelo_Codigo)
SELECT DISTINCT Sillon_Codigo, Sillon_Modelo_Codigo
FROM gd_esquema.Maestra
WHERE Sillon_Codigo IS NOT NULL;


--MaterialPorSillon
INSERT INTO BDGRUPO.MaterialPorSillon (Sillon_Codigo, Material_ID)
SELECT M.Sillon_Codigo, BDM.Material_ID
FROM gd_esquema.Maestra M
JOIN BDGRUPO.Material BDM ON M.Material_Nombre = BDM.Material_Nombre
WHERE M.Sillon_Codigo IS NOT NULL;


--Medida
INSERT INTO BDGRUPO.Medida (Medida_Codigo, Medida_Alto, Medida_Ancho, Medida_Profundidad, Medida_Precio)
SELECT DISTINCT Sillon_Codigo, Sillon_Medida_Alto, Sillon_Medida_Ancho, Sillon_Medida_Profundidad, Sillon_Medida_Precio
FROM gd_esquema.Maestra
WHERE Sillon_Codigo IS NOT NULL;

--Compra
INSERT INTO BDGRUPO.Compra (Compra_Numero, Sucursal_NroSucursal, Proveedor_Cuit, Compra_Fecha, Compra_Total)
SELECT DISTINCT M.Compra_Numero, M.Sucursal_NroSucursal, M.Proveedor_Cuit, M.Compra_Fecha, M.Compra_Total
FROM gd_esquema.Maestra M
WHERE M.Compra_Numero IS NOT NULL;

--DetalleCompra
INSERT INTO BDGRUPO.DetalleCompra (Compra_Numero, Detalle_Compra_Precio, Detalle_Compra_Cantidad, Detalle_Compra_Subtotal, Material_ID)
SELECT DISTINCT M.Compra_Numero, M.Detalle_Compra_Precio, M.Detalle_Compra_Cantidad, M.Detalle_Compra_Subtotal, BDM.Material_ID
FROM gd_esquema.Maestra M
JOIN BDGRUPO.Material BDM ON M.Material_Nombre = BDM.Material_Nombre
WHERE M.Compra_Numero IS NOT NULL;

--Pedido
INSERT INTO BDGRUPO.Pedido (Pedido_Numero, Pedido_Cliente, Pedido_Sucursal, Pedido_Estado, Pedido_Fecha, Pedido_Total)
SELECT DISTINCT Pedido_Numero, Cliente_Dni, Sucursal_NroSucursal, Pedido_Estado, Pedido_Fecha, Pedido_Total
FROM gd_esquema.Maestra
WHERE Pedido_Numero IS NOT NULL;

--Cancelacion Pedido
INSERT INTO BDGRUPO.CancelacionPedido (Pedido_Numero, Pedido_Cancelacion_Fecha, Pedido_Cancelacion_Motivo)
SELECT DISTINCT Pedido_Numero, Pedido_Cancelacion_Fecha, Pedido_Cancelacion_Motivo
FROM gd_esquema.Maestra
WHERE Pedido_Cancelacion_Fecha IS NOT NULL;

--Detalle Pedido
INSERT INTO BDGRUPO.DetallePedido (Pedido_Numero, Sillon_Codigo, Detalle_Pedido_Cantidad, Detalle_Pedido_Precio, Detalle_Pedido_SubTotal)
SELECT DISTINCT Pedido_Numero, Sillon_Codigo, Detalle_Pedido_Cantidad, Detalle_Pedido_Precio, Detalle_Pedido_SubTotal
FROM gd_esquema.Maestra
WHERE Pedido_Numero IS NOT NULL AND Sillon_Codigo IS NOT NULL;

--Factura
INSERT INTO BDGRUPO.Factura (Factura_Numero, Factura_Fecha, Factura_Sucursal, Factura_Total)
SELECT DISTINCT Factura_Numero, Factura_Fecha, Sucursal_NroSucursal, Factura_Total
FROM gd_esquema.Maestra
WHERE Factura_Numero IS NOT NULL;

--Detalle Factura
INSERT INTO BDGRUPO.FacturaDetalle 
	(Factura_Numero, Detalle_Factura_Cantidad, Detalle_Factura_Precio, Detalle_Factura_SubTotal, Detalle_Factura_Pedido_ID, Sillon_Codigo)
SELECT DISTINCT
	m.Factura_Numero, 
	m.Detalle_Factura_Cantidad, 
	m.Detalle_Factura_Precio, 
	m.Detalle_Factura_SubTotal, 
	d.Detalle_Pedido_ID,
    d.Sillon_Codigo
FROM gd_esquema.Maestra m
JOIN BDGRUPO.Factura f ON m.Factura_Numero = f.Factura_Numero AND m.Sucursal_NroSucursal = f.Factura_Sucursal
JOIN BDGRUPO.DetallePedido d ON m.Pedido_Numero = d.Pedido_Numero
	AND d.Detalle_Pedido_Cantidad = m.Detalle_Factura_Cantidad
	AND d.Detalle_Pedido_Precio = m.Detalle_Factura_Precio
	AND d.Detalle_Pedido_SubTotal = m.Detalle_Factura_SubTotal
WHERE m.Factura_Numero IS NOT NULL  
    AND d.Sillon_Codigo IS NOT NULL
    AND m.Detalle_Factura_Cantidad IS NOT NULL
    AND m.Detalle_Factura_Precio IS NOT NULL
    AND m.Detalle_Factura_SubTotal IS NOT NULL;

--Envio
INSERT INTO BDGRUPO.Envio (Envio_Numero, Factura_Numero, Envio_Fecha_Programada, Envio_Fecha, Envio_ImporteTraslado, Envio_ImporteSubida, Envio_Total)
SELECT DISTINCT Envio_Numero, Factura_Numero, Envio_Fecha_Programada, Envio_Fecha, Envio_ImporteTraslado, Envio_ImporteSubida, Envio_Total
FROM gd_esquema.Maestra
WHERE Envio_Numero IS NOT NULL;

END;
GO

EXEC BDGRUPO.Migrar_Datos;
GO


