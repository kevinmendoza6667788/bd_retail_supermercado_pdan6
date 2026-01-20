-- ================================================================
-- MODELO DIMENSIONAL (DATA WAREHOUSE)
-- Origen: bd_pedan6  --> Destino: bd_pedan6_OLAP
-- ================================================================

-- 1. CAMBIAMOS EL CONTEXTO A LA BASE DE DATOS DE DESTINO (OLAP)
USE bd_pedan6_OLAP;
GO

SET NOCOUNT ON;

-- ================================================================
-- 2. DIMENSIÓN TIEMPO (Generada localmente, no depende del origen)
-- ================================================================
PRINT 'Generando Dim_Tiempo...';

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Dim_Tiempo') AND type in (N'U')) DROP TABLE Dim_Tiempo;
CREATE TABLE Dim_Tiempo (
    FechaKey INT PRIMARY KEY, -- YYYYMMDD
    Fecha DATE,
    Anio INT,
    Mes INT,
    NombreMes NVARCHAR(20),
    Trimestre INT,
    DiaSemana INT,
    NombreDia NVARCHAR(20),
    EsFinDeSemana BIT
);

DECLARE @FechaInicio DATE = DATEADD(YEAR, -5, GETDATE());
DECLARE @FechaFin DATE = DATEADD(YEAR, 1, GETDATE());

WHILE @FechaInicio <= @FechaFin
BEGIN
    INSERT INTO Dim_Tiempo
    SELECT 
        CAST(CONVERT(VARCHAR(8), @FechaInicio, 112) AS INT),
        @FechaInicio,
        YEAR(@FechaInicio),
        MONTH(@FechaInicio),
        DATENAME(MONTH, @FechaInicio),
        DATEPART(QUARTER, @FechaInicio),
        DATEPART(WEEKDAY, @FechaInicio),
        DATENAME(WEEKDAY, @FechaInicio),
        CASE WHEN DATEPART(WEEKDAY, @FechaInicio) IN (1, 7) THEN 1 ELSE 0 END
    
    SET @FechaInicio = DATEADD(DAY, 1, @FechaInicio);
END
PRINT 'Dim_Tiempo completada.';

-- ================================================================
-- 3. DIMENSIONES (Extracción desde bd_pedan6)
-- ================================================================

-- Dim_Producto
PRINT 'Generando Dim_Producto...';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Dim_Producto') AND type in (N'U')) DROP TABLE Dim_Producto;

SELECT 
    p.ID_Producto AS SK_Producto,
    p.NombreProducto,
    c.NombreCategoria,
    p.Descripcion,
    p.PrecioVenta AS PrecioActual,
    CASE WHEN p.PrecioVenta > 100 THEN 'Premium' ELSE 'Estándar' END AS SegmentoPrecio
INTO Dim_Producto
FROM bd_pedan6.dbo.Productos p  -- <--- NOTA EL PREFIJO DE LA BD ORIGEN
INNER JOIN bd_pedan6.dbo.Categorias c ON p.ID_Categoria = c.ID_Categoria;

ALTER TABLE Dim_Producto ADD CONSTRAINT PK_DimProducto PRIMARY KEY (SK_Producto);


-- Dim_Cliente
PRINT 'Generando Dim_Cliente...';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Dim_Cliente') AND type in (N'U')) DROP TABLE Dim_Cliente;

SELECT 
    ID_Cliente AS SK_Cliente,
    Nombre + ' ' + Apellido AS NombreCompleto,
    Direccion,
    DATEDIFF(YEAR, FechaNacimiento, GETDATE()) AS EdadActual,
    CASE 
        WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) < 30 THEN 'Joven'
        WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) BETWEEN 30 AND 50 THEN 'Adulto'
        ELSE 'Senior' 
    END AS GrupoEtario,
    Email,
    Direccion AS Ubicacion
INTO Dim_Cliente
FROM bd_pedan6.dbo.Clientes; -- <--- ORIGEN EXTERNO

ALTER TABLE Dim_Cliente ADD CONSTRAINT PK_DimCliente PRIMARY KEY (SK_Cliente);


-- Dim_Empleado
PRINT 'Generando Dim_Empleado...';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Dim_Empleado') AND type in (N'U')) DROP TABLE Dim_Empleado;

SELECT 
    e.ID_Empleado AS SK_Empleado,
    e.Nombre + ' ' + e.Apellido AS NombreCompleto,
    e.Cargo,
    d.NombreDepartamento,
    CASE WHEN e.EsActivo = 1 THEN 'Activo' ELSE 'Inactivo' END AS EstadoLaboral
INTO Dim_Empleado
FROM bd_pedan6.dbo.Empleados e -- <--- ORIGEN EXTERNO
INNER JOIN bd_pedan6.dbo.Departamentos d ON e.ID_Departamento = d.ID_Departamento;

ALTER TABLE Dim_Empleado ADD CONSTRAINT PK_DimEmpleado PRIMARY KEY (SK_Empleado);


-- Dim_Proveedor
PRINT 'Generando Dim_Proveedor...';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Dim_Proveedor') AND type in (N'U')) DROP TABLE Dim_Proveedor;

SELECT 
    ID_Proveedor AS SK_Proveedor,
    NombreProveedor,
    NombreContacto,
    CalificacionConfiabilidad
INTO Dim_Proveedor
FROM bd_pedan6.dbo.Proveedores; -- <--- ORIGEN EXTERNO

ALTER TABLE Dim_Proveedor ADD CONSTRAINT PK_DimProveedor PRIMARY KEY (SK_Proveedor);


-- ================================================================
-- 4. TABLAS DE HECHOS (Extracción y Transformación)
-- ================================================================

-- Fact_Ventas
PRINT 'Generando Fact_Ventas...';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Fact_Ventas') AND type in (N'U')) DROP TABLE Fact_Ventas;

SELECT 
    -- Keys
    CAST(CONVERT(VARCHAR(8), p.FechaPedido, 112) AS INT) AS FechaKey,
    dp.ID_Producto AS SK_Producto,
    p.ID_Cliente AS SK_Cliente,
    ISNULL(p.ID_Empleado, -1) AS SK_Empleado,
    
    -- Metrics
    dp.Cantidad,
    dp.PrecioUnitario,
    dp.TotalLinea AS MontoVenta,
    
    -- Degenerate Dimensions
    p.ID_Pedido,
    p.NumeroRastreo
INTO Fact_Ventas
FROM bd_pedan6.dbo.Pedidos p -- <--- ORIGEN EXTERNO
INNER JOIN bd_pedan6.dbo.DetallePedidos dp ON p.ID_Pedido = dp.ID_Pedido
WHERE p.ID_Estado IN (SELECT ID_Estado FROM bd_pedan6.dbo.EstadosPedido WHERE NombreEstado <> 'Cancelado');


-- Fact_MovimientosInventario
PRINT 'Generando Fact_MovimientosInventario...';
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'Fact_MovimientosInventario') AND type in (N'U')) DROP TABLE Fact_MovimientosInventario;

SELECT 
    -- Keys
    CAST(CONVERT(VARCHAR(8), b.FechaMovimiento, 112) AS INT) AS FechaKey,
    b.ID_Producto AS SK_Producto,
    ISNULL(b.ID_Proveedor, -1) AS SK_Proveedor,
    ISNULL(b.ID_Empleado, -1) AS SK_Empleado,
    
    -- Attributes
    b.TipoMovimiento,
    b.Motivo,
    
    -- Metrics
    b.Cantidad AS CantidadMovimiento,
    ABS(b.Cantidad) AS CantidadAbsoluta
INTO Fact_MovimientosInventario
FROM bd_pedan6.dbo.BitacoraInventario b; -- <--- ORIGEN EXTERNO

PRINT '================================================';
PRINT ' PROCESO ETL COMPLETADO EXITOSAMENTE ';
PRINT ' El Modelo Dimensional está listo en bd_pedan6_OLAP';
PRINT '================================================';
GO