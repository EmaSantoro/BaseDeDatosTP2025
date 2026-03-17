USE GD1C2025;
GO

-- //////////////////////////////////////////////////////////////
-- ELIMINACION DE TABLAS Y PROCEDIMIENTOS ANTERIORES
-- //////////////////////////////////////////////////////////////

DROP PROCEDURE IF EXISTS BDGRUPOBI.Migrar_Datos;

-- Primero eliminar tablas de hechos (por FK)
IF OBJECT_ID('BDGRUPOBI.HechoVentas', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoVentas;
IF OBJECT_ID('BDGRUPOBI.HechoCompras', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoCompras;
IF OBJECT_ID('BDGRUPOBI.HechoEnvios', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoEnvios;
IF OBJECT_ID('BDGRUPOBI.HechoPedidos', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.HechoPedidos;


-- Luego eliminar dimensiones
IF OBJECT_ID('BDGRUPOBI.DimTiempo', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTiempo;
IF OBJECT_ID('BDGRUPOBI.DimSucursal', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSucursal;
IF OBJECT_ID('BDGRUPOBI.DimUbicacion', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimUbicacion;
IF OBJECT_ID('BDGRUPOBI.DimMaterial', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimMaterial;
IF OBJECT_ID('BDGRUPOBI.DimSillon', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimSillon;
IF OBJECT_ID('BDGRUPOBI.DimRangoEtario', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimRangoEtario;
IF OBJECT_ID('BDGRUPOBI.DimTurno', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimTurno;
IF OBJECT_ID('BDGRUPOBI.DimEstadoPedido', 'U') IS NOT NULL DROP TABLE BDGRUPOBI.DimEstadoPedido;

IF OBJECT_ID('BDGRUPOBI.vista_ganancias', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_ganancias;
IF OBJECT_ID('BDGRUPOBI.vista_conversion_pedidos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_conversion_pedidos;
IF OBJECT_ID('BDGRUPOBI.vista_volumen_pedidos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_volumen_pedidos;
IF OBJECT_ID('BDGRUPOBI.vista_tiempo_promedio_fabricacion', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_tiempo_promedio_fabricacion;
IF OBJECT_ID('BDGRUPOBI.vista_promedio_compras', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_promedio_compras;
IF OBJECT_ID('BDGRUPOBI.vista_compras_material', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_compras_material;
IF OBJECT_ID('BDGRUPOBI.vista_cumplimiento_envios', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_cumplimiento_envios;
IF OBJECT_ID('BDGRUPOBI.vista_localidades_mayor_costo', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_localidades_mayor_costo;
IF OBJECT_ID('BDGRUPOBI.vista_rendimiento_modelos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_rendimiento_modelos;
IF OBJECT_ID('BDGRUPOBI.vista_factura_promedio_mensual', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_factura_promedio_mensual;
IF OBJECT_ID('BDGRUPOBI.vista_localidades_mayor_costo', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_localidades_mayor_Costo;
IF OBJECT_ID('BDGRUPOBI.vista_conversion_pedidos', 'V') IS NOT NULL DROP VIEW BDGRUPOBI.vista_conversion_pedidos;


GO

-- Primero eliminamos el esquema (si está vacío)
IF EXISTS (SELECT * FROM sys.schemas WHERE name = 'BDGRUPOBI')
    DROP SCHEMA BDGRUPOBI;
GO

-- //////////////////////////////////////////////////////////////
-- CREACION DE TABLAS
-- //////////////////////////////////////////////////////////////
CREATE SCHEMA BDGRUPOBI;
GO

-- DIM_TIEMPO
CREATE TABLE BDGRUPOBI.DimTiempo (
    Tiempo_ID INT PRIMARY KEY IDENTITY(1,1),
    Anio INT,
    Cuatrimestre INT,
    Mes INT,
	Fecha DATE
);
GO

-- DIM_UBICACION
CREATE TABLE BDGRUPOBI.DimUbicacion (
    Localidad_ID BIGINT PRIMARY KEY,
    Provincia NVARCHAR(100),
    Localidad NVARCHAR(100)
);
GO

-- DIM_SUCURSAL
CREATE TABLE BDGRUPOBI.DimSucursal (
    Sucursal_ID BIGINT PRIMARY KEY,
    Localidad_ID BIGINT
);
GO

-- DIM_MATERIAL
CREATE TABLE BDGRUPOBI.DimMaterial (
    Material_ID BIGINT PRIMARY KEY,
    Tipo NVARCHAR(100)
);
GO

-- DIM_SILLON
CREATE TABLE BDGRUPOBI.DimSillon (
    Modelo NVARCHAR(255) PRIMARY KEY
);
GO

-- DIM_RANGOETARIO
CREATE TABLE BDGRUPOBI.DimRangoEtario (
    RangoEtario NVARCHAR(20) PRIMARY KEY,
    Edad_desde INT,
    Edad_hasta INT
);
GO

-- DIM_TURNO
CREATE TABLE BDGRUPOBI.DimTurno (
    Turno_ID INT PRIMARY KEY,
    Hora_Desde TIME,
    Hora_Hasta TIME,
    Turno NVARCHAR(50)
);
GO

-- DIM_ESTADO_PEDIDO
CREATE TABLE BDGRUPOBI.DimEstadoPedido (
    Estado_ID INT PRIMARY KEY,
    Estado NVARCHAR(50)
);
GO

-- HECHO_VENTAS
CREATE TABLE BDGRUPOBI.HechoVentas (
    Tiempo_ID INT,
    Sucursal_ID BIGINT,
    RangoEtario NVARCHAR(20),
    Sillon_Modelo NVARCHAR(255),
    Total DECIMAL(18,2),
    TiempoFabricacion INT,
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (RangoEtario) REFERENCES BDGRUPOBI.DimRangoEtario(RangoEtario),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    FOREIGN KEY (Sillon_Modelo) REFERENCES BDGRUPOBI.DimSillon(Modelo),
    CONSTRAINT PK_HechoVentas PRIMARY KEY (Tiempo_ID, Sucursal_ID, RangoEtario, Sillon_Modelo)
);
GO

-- HECHO_COMPRAS
CREATE TABLE BDGRUPOBI.HechoCompras (
    Tiempo_ID INT,
    Sucursal_ID BIGINT NOT NULL,
    Material_ID BIGINT NOT NULL,
    Total DECIMAL(18,2),
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    FOREIGN KEY (Material_ID) REFERENCES BDGRUPOBI.DimMaterial(Material_ID),
    CONSTRAINT PK_HechoCompras PRIMARY KEY (Tiempo_ID, Material_ID, Sucursal_ID)
);
GO


-- HECHO_PEDIDOS
CREATE TABLE BDGRUPOBI.HechoPedidos (
    Tiempo_ID INT,
    Turno_ID INT,
    Sucursal_ID BIGINT,
    Cantidad INT,
    Estado NVARCHAR(50),
	Porcentaje_conversion INT,
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Turno_ID) REFERENCES BDGRUPOBI.DimTurno(Turno_ID),
    FOREIGN KEY (Sucursal_ID) REFERENCES BDGRUPOBI.DimSucursal(Sucursal_ID),
    CONSTRAINT PK_HechoPedidos PRIMARY KEY (Tiempo_ID, Turno_ID, Sucursal_ID, Estado)
);
GO

-- HECHO_ENVIOS
CREATE TABLE BDGRUPOBI.HechoEnvios (
    Tiempo_ID INT,
    Localidad_Cliente BIGINT,
	Porcentaje_cumplidos DECIMAL(18,0),
	Costo_promedio DECIMAL(18,2),
    
    FOREIGN KEY (Tiempo_ID) REFERENCES BDGRUPOBI.DimTiempo(Tiempo_ID),
    FOREIGN KEY (Localidad_Cliente) REFERENCES BDGRUPOBI.DimUbicacion(Localidad_ID),
    CONSTRAINT PK_HechoEnvios PRIMARY KEY (Tiempo_ID, Localidad_Cliente)
)
GO

-- //////////////////////////////////////////////////////////////
-- CARGA DE DATOS DIMENSIONES
-- //////////////////////////////////////////////////////////////

-- DimRangoEtario
INSERT INTO BDGRUPOBI.DimRangoEtario(RangoEtario, Edad_desde, Edad_hasta) VALUES
('<25', 0, 24),
('25-35', 25, 34),
('35-50', 35, 49),
('>50', 50, 100);

-- DimTiempo
INSERT INTO BDGRUPOBI.DimTiempo (Anio, Mes, Cuatrimestre, Fecha)
SELECT 
    anios.Anio,
    meses.Mes,
    CASE 
        WHEN meses.Mes BETWEEN 1 AND 4 THEN 1
        WHEN meses.Mes BETWEEN 5 AND 8 THEN 2
        WHEN meses.Mes BETWEEN 9 AND 12 THEN 3
    END AS Cuatrimestre,
    DATEFROMPARTS(anios.Anio, meses.Mes, 1) AS Fecha
FROM 
    (VALUES (2010), (2011), (2012), (2013), (2014), (2015), (2016), (2017), (2018), (2019),
            (2020), (2021), (2022), (2023), (2024), (2025), (2026), (2027), (2028), (2029), (2030)) AS anios(Anio)
CROSS JOIN 
    (VALUES (1), (2), (3), (4), (5), (6), (7), (8), (9), (10), (11), (12)) AS meses(Mes)
ORDER BY anios.Anio, meses.Mes;

-- DimUbicacion
INSERT INTO BDGRUPOBI.DimUbicacion (Localidad_ID, Provincia, Localidad)
SELECT l.Localidad_ID, l.localidad_Provincia, l.Localidad_Nombre
FROM BDGRUPO.Localidad l;

-- DimSucursal
INSERT INTO BDGRUPOBI.DimSucursal (Sucursal_ID, Localidad_ID)
SELECT 
    s.Sucursal_NroSucursal, 
    l.Localidad_ID
FROM BDGRUPO.Sucursal s
JOIN BDGRUPO.Localidad l ON s.Sucursal_Localidad = l.Localidad_ID

-- DimTurno
INSERT INTO BDGRUPOBI.DimTurno(Turno_ID, Hora_Desde, Hora_Hasta, Turno) VALUES
(1, '8:00:00', '13:59:59', '8:00 - 14:00'),
(2, '14:00:00', '19:59:59', '14:00 - 20:00');

--DimEstadoPedido
INSERT INTO BDGRUPOBI.DimEstadoPedido(Estado_ID, Estado) VALUES
(1, 'pendiente'),
(2, 'entregado'),
(3, 'cancelado');

--DimSillon
INSERT INTO BDGRUPOBI.DimSillon(Modelo)
SELECT DISTINCT s.Sillon_Modelo_Codigo
FROM BDGRUPO.Sillon s;

--DimMateriales
INSERT INTO BDGRUPOBI.DimMaterial(Material_ID, Tipo)
SELECT Material_ID, Material_Tipo
FROM BDGRUPO.Material;

-- //////////////////////////////////////////////////////////////
-- CARGA DE DATOS HECHOS
-- //////////////////////////////////////////////////////////////

-- HechosVentas
INSERT INTO BDGRUPOBI.HechoVentas (Tiempo_ID, Sucursal_ID, RangoEtario, Sillon_Modelo, Total, TiempoFabricacion)
SELECT
    t.Tiempo_ID,
    f.Factura_Sucursal,
    re.RangoEtario,
    s.Modelo,
    SUM(fd.Detalle_Factura_SubTotal),
    AVG(DATEDIFF(DAY, p.Pedido_Fecha, f.Factura_Fecha)) AS TiempoFabricacion
FROM BDGRUPO.Factura f
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_Factura_Pedido_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON p.Pedido_Numero = dp.Pedido_Numero
JOIN BDGRUPO.Cliente c ON c.Cliente_Dni = p.Pedido_Cliente
JOIN BDGRUPO.Sillon si ON si.Sillon_Codigo = dp.Sillon_Codigo
JOIN BDGRUPOBI.DimSillon s ON s.Modelo = si.Sillon_Modelo_Codigo
JOIN BDGRUPOBI.DimTiempo t ON YEAR(f.Factura_Fecha) = t.Anio AND MONTH(f.Factura_Fecha) = t.Mes
JOIN BDGRUPOBI.DimRangoEtario re ON DATEDIFF(YEAR, c.Cliente_FechaNacimiento, GETDATE()) BETWEEN re.Edad_desde AND re.Edad_hasta
GROUP BY t.Tiempo_ID, f.Factura_Sucursal, re.RangoEtario, s.Modelo
GO

-- HechosCompras
INSERT INTO BDGRUPOBI.HechoCompras (Tiempo_ID, Sucursal_ID, Material_ID, Total)
SELECT 
	t.Tiempo_ID, 
	s.Sucursal_ID, 
	m.Material_ID, 
	SUM(dc.Detalle_Compra_Precio * dc.Detalle_Compra_Cantidad)  AS Total
FROM BDGRUPO.Compra c
JOIN BDGRUPOBI.DimTiempo t ON YEAR(c.Compra_Fecha) = t.Anio AND MONTH(c.Compra_Fecha) = t.Mes
JOIN BDGRUPOBI.DimSucursal s ON s.Sucursal_ID = c.Sucursal_NroSucursal 
JOIN BDGRUPO.DetalleCompra dc ON c.Compra_Numero = dc.Compra_Numero
JOIN BDGRUPOBI.DimMaterial m ON m.Material_ID = dc.Material_ID
GROUP BY t.Tiempo_ID, s.Sucursal_ID, m.Material_ID
GO

-- HechosPedidos
INSERT INTO BDGRUPOBI.HechoPedidos (Tiempo_ID, Turno_ID, Sucursal_ID, Cantidad, Estado, Porcentaje_conversion)
SELECT
    t.Tiempo_ID,
    dt.Turno_ID,
    p.Pedido_Sucursal,
    COUNT(p.Pedido_Numero),
    de.Estado,
    COUNT(p.Pedido_Numero) * 100 / NULLIF(SUM(COUNT(p.Pedido_Numero)) OVER (PARTITION BY t.Tiempo_ID, dt.Turno_ID, p.Pedido_Sucursal), 0)
FROM BDGRUPO.Pedido p
JOIN BDGRUPOBI.DimTiempo t ON MONTH(p.Pedido_Fecha) = t.Mes AND YEAR(p.Pedido_Fecha) = t.Anio
JOIN BDGRUPOBI.DimTurno dt ON CONVERT(TIME, p.Pedido_Fecha) BETWEEN dt.Hora_Desde AND dt.Hora_Hasta
JOIN BDGRUPOBI.DimEstadoPedido de ON p.Pedido_Estado = de.Estado
GROUP BY t.Tiempo_ID, dt.Turno_ID, p.Pedido_Sucursal, de.Estado
GO

-- HechoEnvios
INSERT INTO BDGRUPOBI.HechoEnvios (Tiempo_ID, Localidad_Cliente, Porcentaje_cumplidos, Costo_promedio)
SELECT 
    t.Tiempo_ID,
	c.Cliente_Localidad, 
    CAST(
        100.0 * SUM(CASE WHEN e.Envio_Fecha <= e.Envio_Fecha_Programada THEN 1 ELSE 0 END) 
        / COUNT(e.Envio_Numero) AS DECIMAL(18,0)
    ) AS Porcentaje_cumplidos,
    AVG(e.Envio_Total) AS Costo_promedio_Envio
FROM BDGRUPO.Envio e
JOIN BDGRUPO.Factura f ON e.Factura_Numero = f.Factura_Numero
JOIN BDGRUPO.FacturaDetalle fd ON f.Factura_Numero = fd.Factura_Numero
JOIN BDGRUPO.DetallePedido dp ON fd.Detalle_Factura_Pedido_ID = dp.Detalle_Pedido_ID
JOIN BDGRUPO.Pedido p ON dp.Pedido_Numero = p.Pedido_Numero
JOIN BDGRUPO.Cliente c ON p.Pedido_Cliente = c.Cliente_Dni
JOIN BDGRUPOBI.DimTiempo t ON YEAR(e.Envio_Fecha) = t.Anio AND MONTH(e.Envio_Fecha) = t.Mes
GROUP BY t.Tiempo_ID, c.Cliente_Localidad
GO

-- //////////////////////////////////////////////////////////////
-- VISTAS
-- //////////////////////////////////////////////////////////////

--1 Ganancias
CREATE VIEW BDGRUPOBI.vista_ganancias AS
SELECT
    s.Sucursal_ID,
    t.Mes,
    t.Anio,
    ISNULL((
        SELECT SUM(v.Total) 
        FROM BDGRUPOBI.HechoVentas v 
        WHERE v.Tiempo_ID = t.Tiempo_ID AND v.Sucursal_ID = s.Sucursal_ID
    ), 0)
    -
    ISNULL((
        SELECT SUM(c.Total) 
        FROM BDGRUPOBI.HechoCompras c 
        WHERE c.Tiempo_ID = t.Tiempo_ID AND c.Sucursal_ID = s.Sucursal_ID
    ), 0) AS Ganancia
FROM BDGRUPOBI.DimSucursal s
CROSS JOIN BDGRUPOBI.DimTiempo t
WHERE 
    (SELECT SUM(v.Total) 
        FROM BDGRUPOBI.HechoVentas v 
        WHERE v.Tiempo_ID = t.Tiempo_ID AND v.Sucursal_ID = s.Sucursal_ID) IS NOT NULL
    OR
    (SELECT SUM(c.Total) 
        FROM BDGRUPOBI.HechoCompras c 
        WHERE c.Tiempo_ID = t.Tiempo_ID AND c.Sucursal_ID = s.Sucursal_ID) IS NOT NULL;
GO

--2 Factura Promedio Mensual
CREATE VIEW BDGRUPOBI.vista_factura_promedio_mensual AS
SELECT
    u.Provincia,
    t.Cuatrimestre,
    t.Anio,
    AVG(v.Total) AS Promedio_Factura
FROM BDGRUPOBI.HechoVentas v
JOIN BDGRUPOBI.DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
JOIN BDGRUPOBI.DimUbicacion u ON s.Localidad_ID = u.Localidad_ID
JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
GROUP BY u.Provincia, t.Cuatrimestre, t.Anio
GO

--3 Rendimiento de Modelos
CREATE VIEW BDGRUPOBI.vista_rendimiento_modelos AS
SELECT
    t.Anio,
    t.Cuatrimestre,
    u.Localidad,
    re.RangoEtario,
    (SELECT TOP 1 v2.Sillon_Modelo FROM BDGRUPOBI.HechoVentas v2
        WHERE v2.Tiempo_ID = MIN(t.Tiempo_ID) AND v2.Sucursal_ID = MIN(s.Sucursal_ID) AND v2.RangoEtario = MIN(re.RangoEtario)
        GROUP BY v2.Sillon_Modelo
        ORDER BY SUM(v2.Total) DESC
    ) AS PrimerModelo,
    (SELECT v2.Sillon_Modelo FROM BDGRUPOBI.HechoVentas v2
        WHERE v2.Tiempo_ID = MIN(t.Tiempo_ID) AND v2.Sucursal_ID = MIN(s.Sucursal_ID) AND v2.RangoEtario = MIN(re.RangoEtario)
        GROUP BY v2.Sillon_Modelo
        ORDER BY SUM(v2.Total) DESC
        OFFSET 1 ROWS FETCH NEXT 1 ROW ONLY
    ) AS SegundoModelo,
    (SELECT v2.Sillon_Modelo FROM BDGRUPOBI.HechoVentas v2
        WHERE v2.Tiempo_ID = MIN(t.Tiempo_ID) AND v2.Sucursal_ID = MIN(s.Sucursal_ID) AND v2.RangoEtario = MIN(re.RangoEtario)
        GROUP BY v2.Sillon_Modelo
        ORDER BY SUM(v2.Total) DESC
        OFFSET 2 ROWS FETCH NEXT 1 ROW ONLY
    ) AS TercerModelo
FROM BDGRUPOBI.HechoVentas v
JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
JOIN BDGRUPOBI.DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
JOIN BDGRUPOBI.DimUbicacion u ON s.Localidad_ID = u.Localidad_ID
JOIN BDGRUPOBI.DimRangoEtario re ON v.RangoEtario = re.RangoEtario
GROUP BY t.Anio, t.Cuatrimestre, u.Localidad, re.RangoEtario;
GO

--4 Volumen de Pedidos
CREATE VIEW BDGRUPOBI.vista_volumen_pedidos AS
SELECT
    SUM(p.Cantidad) as volumen,
    t.Turno,
    d.Mes,
    d.Anio,
    s.Sucursal_ID
FROM BDGRUPOBI.HechoPedidos p
INNER JOIN BDGRUPOBI.DimTurno t ON p.Turno_ID = t.Turno_ID
INNER JOIN BDGRUPOBI.DimTiempo d ON p.Tiempo_ID = d.Tiempo_ID
INNER JOIN BDGRUPOBI.DimSucursal s ON p.Sucursal_ID = s.Sucursal_ID
GROUP BY t.Turno, d.Mes, d.Anio, s.Sucursal_ID
GO

--5 Conversion de pedidos 
CREATE VIEW BDGRUPOBI.vista_conversion_pedidos AS
SELECT
    AVG(p.Porcentaje_conversion) AS Porcentaje_conversion,
    e.Estado,
    t.Cuatrimestre,
    s.Sucursal_ID
FROM BDGRUPOBI.HechoPedidos p
INNER JOIN BDGRUPOBI.DimEstadoPedido e ON p.Estado = e.Estado
INNER JOIN BDGRUPOBI.DimTiempo t ON p.Tiempo_ID = t.Tiempo_ID
INNER JOIN BDGRUPOBI.DimSucursal s ON p.Sucursal_ID = s.Sucursal_ID
GROUP BY e.Estado, t.Cuatrimestre, s.Sucursal_ID
GO

--6 Tiempo promedio de fabricacion
CREATE VIEW BDGRUPOBI.vista_tiempo_promedio_fabricacion AS
SELECT
    AVG(v.TiempoFabricacion) AS tiempo_promedio_fabricacion_horas,
    s.Sucursal_ID,
    t.Cuatrimestre
FROM
BDGRUPOBI.HechoVentas v 
INNER JOIN BDGRUPOBI.DimSucursal s ON v.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.DimTiempo t ON v.Tiempo_ID = t.Tiempo_ID
GROUP BY s.Sucursal_ID, t.Cuatrimestre
GO

--7 Promedio de Compras
CREATE VIEW BDGRUPOBI.vista_promedio_compras AS
SELECT
    AVG(ca.subtotal_total_compra) AS importe_promedio_compra, ca.Mes, ca.Anio
FROM (
    SELECT c.Compra_Numero, t.Mes, t.Anio, SUM(dc.Detalle_Compra_Precio * dc.Detalle_Compra_Cantidad) AS subtotal_total_compra
    FROM BDGRUPO.Compra c
    JOIN BDGRUPO.DetalleCompra dc ON c.Compra_Numero = dc.Compra_Numero
    JOIN BDGRUPOBI.DimTiempo t ON YEAR(c.Compra_Fecha) = t.Anio AND MONTH(c.Compra_Fecha) = t.Mes
    GROUP BY c.Compra_Numero, t.Mes, t.Anio
) AS ca
GROUP BY ca.Mes, ca.Anio;
GO

--8 Compras por tipo de material
CREATE VIEW BDGRUPOBI.vista_compras_material AS
SELECT
    m.Tipo,
    SUM(c.Total) AS importe_total,
    s.Sucursal_ID,
    t.Cuatrimestre
FROM
BDGRUPOBI.HechoCompras c
INNER JOIN BDGRUPOBI.DimMaterial m ON c.Material_ID = m.Material_ID
INNER JOIN BDGRUPOBI.DimSucursal s ON c.Sucursal_ID = s.Sucursal_ID
INNER JOIN BDGRUPOBI.DimTiempo t ON c.Tiempo_ID = t.Tiempo_ID
GROUP BY m.Tipo, s.Sucursal_ID, t.Cuatrimestre
GO

--9 Porcentaje de cumplimiento de envios
CREATE VIEW BDGRUPOBI.vista_cumplimiento_envios AS
SELECT 
    AVG(e.Porcentaje_cumplidos) AS Cumplimiento,
    t.Mes
FROM
BDGRUPOBI.HechoEnvios e
INNER JOIN BDGRUPOBI.DimTiempo t ON e.Tiempo_ID = t.Tiempo_ID
GROUP BY t.Mes
GO

--10 Localidades que pagan mayor costo de envio
CREATE VIEW BDGRUPOBI.vista_localidades_mayor_costo AS
SELECT TOP 3
    u.Localidad,
    AVG(e.Costo_promedio) AS Costo_Promedio
FROM BDGRUPOBI.HechoEnvios e
JOIN BDGRUPOBI.DimUbicacion u ON u.Localidad_ID = e.Localidad_Cliente
GROUP BY u.Localidad
ORDER BY AVG(e.Costo_promedio) DESC
GO


