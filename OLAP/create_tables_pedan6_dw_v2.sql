-- =============================================================================
-- SCRIPT DE MODELADO DIMENSIONAL (DATA WAREHOUSE) - TIENDAS TAMBO - V2
-- Arquitectura: Esquema de Estrella (Star Schema)
-- Autor: Data Architect Lead
-- Destino: SSIS / Power BI
-- =============================================================================

USE master;
GO

-- 1. CREACIÓN DE LA BASE DE DATOS DIMENSIONAL
IF EXISTS (SELECT name FROM sys.databases WHERE name = N'bd_pedan6_dw')
BEGIN
    ALTER DATABASE bd_pedan6_dw SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE bd_pedan6_dw;
END
GO

CREATE DATABASE bd_pedan6_dw;
GO

USE bd_pedan6_dw;
GO

PRINT '>>> CREANDO MODELO DIMENSIONAL OPTIMIZADO...';

-- =======================================================
-- 2. DIMENSIONES
-- =======================================================

-- 2.1 DIMENSIÓN TIEMPO
-- Estrategia de carga: Se llenará mediante un SP ejecutado desde SSIS (Execute SQL Task)
-- para garantizar continuidad de fechas (sin huecos).
CREATE TABLE DimTiempo (
    DateKey INT PRIMARY KEY,              -- PK formato YYYYMMDD (Ej: 20251115)
    Fecha DATE NOT NULL,
    Anio INT NOT NULL,
    Trimestre INT NOT NULL,               -- 1, 2, 3, 4
    Mes INT NOT NULL,                     -- 1 a 12
    NombreMes NVARCHAR(20) NOT NULL,      -- 'Noviembre'
    DiaDeSemana INT NOT NULL,             -- 1 a 7
    NombreDia NVARCHAR(20) NOT NULL,      -- 'Sábado'
    EsFinDeSemana BIT NOT NULL            -- 1=Si, 0=No
);

-- 2.2 DIMENSIÓN PRODUCTO
-- Origen: Join de Productos + Categorias
CREATE TABLE DimProducto (
    ProductKey INT PRIMARY KEY IDENTITY(1,1), -- Surrogate Key
    ID_Producto_BK INT NOT NULL,              -- Business Key (Original)
    NombreProducto NVARCHAR(100) NOT NULL,
    Categoria NVARCHAR(50) NOT NULL,          -- Desnormalizado
    PrecioVentaActual DECIMAL(10,2),          -- Informativo
    Descripcion NVARCHAR(MAX) NULL
);

-- 2.3 DIMENSIÓN CLIENTE
-- Origen: Tabla Clientes
-- Nota para SSIS: 'SegmentoEdad' se debe calcular con un Derived Column usando FechaNacimiento.
CREATE TABLE DimCliente (
    CustomerKey INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente_BK INT NOT NULL,
    NombreCompleto NVARCHAR(150) NOT NULL,    
    Email NVARCHAR(100),
    UbicacionGeografica NVARCHAR(255),        -- Dirección para mapas
    SegmentoEdad NVARCHAR(20) NULL,           -- Calculado en ETL: 'Joven', 'Adulto', 'Senior'
    FechaRegistro DATE                        
);

-- 2.4 DIMENSIÓN VENDEDOR (TIENDA/REGIÓN)
-- Origen: Empleados + Departamentos
-- Corrección: Se eliminó 'TipoContrato' por redundancia.
CREATE TABLE DimVendedor (
    EmployeeKey INT PRIMARY KEY IDENTITY(1,1),
    ID_Empleado_BK INT NOT NULL,
    NombreCompleto NVARCHAR(150) NOT NULL,
    Cargo NVARCHAR(50),                       -- Define si es Tiempo Completo/Medio Tiempo
    Region NVARCHAR(50) NOT NULL              -- Lima, Cusco, etc.
);

-- 2.5 DIMENSIÓN MÉTODO PAGO
CREATE TABLE DimMetodoPago (
    PaymentKey INT PRIMARY KEY IDENTITY(1,1),
    ID_MetodoPago_BK INT NOT NULL,
    NombreMetodo NVARCHAR(50) NOT NULL
);

-- =======================================================
-- 3. HECHOS (FACT TABLES)
-- =======================================================

-- 3.1 FACT VENTAS
-- Grano: Una fila por cada producto dentro de un ticket.
CREATE TABLE FactVentas (
    VentaKey BIGINT PRIMARY KEY IDENTITY(1,1),
    
    -- Foreign Keys (Relaciones con Dimensiones)
    DateKey INT NOT NULL FOREIGN KEY REFERENCES DimTiempo(DateKey),
    ProductKey INT NOT NULL FOREIGN KEY REFERENCES DimProducto(ProductKey),
    CustomerKey INT NOT NULL FOREIGN KEY REFERENCES DimCliente(CustomerKey),
    EmployeeKey INT NOT NULL FOREIGN KEY REFERENCES DimVendedor(EmployeeKey),
    PaymentKey INT NOT NULL FOREIGN KEY REFERENCES DimMetodoPago(PaymentKey),
    
    -- Dimensiones Degeneradas (Imprescindibles para métricas de frecuencia)
    ID_Pedido_BK INT NOT NULL,           -- NECESARIO para calcular "Ticket Promedio" (Count Distinct)
    
    -- Métricas (Hechos Numéricos)
    Cantidad INT NOT NULL,
    PrecioUnitarioVenta DECIMAL(10,2) NOT NULL, 
    MontoTotalLinea DECIMAL(18,2) NOT NULL,     
    
    -- Auditoría
    FechaCarga DATETIME DEFAULT GETDATE()
);

-- 3.2 FACT INVENTARIO (Movimientos de Almacén)
CREATE TABLE FactInventario (
    MovimientoKey BIGINT PRIMARY KEY IDENTITY(1,1),
    DateKey INT NOT NULL FOREIGN KEY REFERENCES DimTiempo(DateKey),
    ProductKey INT NOT NULL FOREIGN KEY REFERENCES DimProducto(ProductKey),
    
    CantidadMovimiento INT NOT NULL, 
    TipoMovimiento NVARCHAR(20) NOT NULL
);

-- =======================================================
-- 4. ÍNDICES
-- =======================================================
CREATE INDEX IX_FactVentas_DateKey ON FactVentas(DateKey);
CREATE INDEX IX_FactVentas_ProductKey ON FactVentas(ProductKey);
CREATE INDEX IX_FactVentas_CustomerKey ON FactVentas(CustomerKey);
CREATE INDEX IX_FactVentas_EmployeeKey ON FactVentas(EmployeeKey);

PRINT '>>> MODELO DIMENSIONAL V2 CREADO EXITOSAMENTE.';