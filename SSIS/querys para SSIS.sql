-- =============================================================================
-- CONSULTAS DE EXTRACCIÓN (SOURCE QUERIES) PARA SSIS
-- Instrucciones: Copia el bloque correspondiente dentro del "OLE DB Source"
-- en tu Data Flow Task de SSIS.
-- Conexión Origen: bd_pedan6 (Transaccional)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. QUERY PARA DIMENSIÓN PRODUCTO (DimProducto)
-- Nota: Hacemos el JOIN con Categoría aquí para enviar la data lista.
-- -----------------------------------------------------------------------------
SELECT 
    P.ID_Producto AS ID_Producto_BK,
    ISNULL(P.NombreProducto, 'Sin Nombre') AS NombreProducto,
    ISNULL(C.NombreCategoria, 'Sin Categoría') AS Categoria,
    ISNULL(P.PrecioVenta, 0) AS PrecioVentaActual,
    ISNULL(P.Descripcion, 'Sin Descripción') AS Descripcion
FROM dbo.Productos P
INNER JOIN dbo.Categorias C ON P.ID_Categoria = C.ID_Categoria;

-- -----------------------------------------------------------------------------
-- 2. QUERY PARA DIMENSIÓN CLIENTE (DimCliente)
-- Nota: Calculamos el 'SegmentoEdad' aquí usando CASE WHEN.
-- Esto evita tener que usar componentes complejos en SSIS.
-- -----------------------------------------------------------------------------
SELECT 
    ID_Cliente AS ID_Cliente_BK,
    (Nombre + ' ' + Apellido) AS NombreCompleto,
    ISNULL(Email, 'No Registrado') AS Email,
    ISNULL(Direccion, 'No Registrada') AS UbicacionGeografica,
    CASE 
        WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) < 18 THEN 'Menor'
        WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) BETWEEN 18 AND 30 THEN 'Joven'
        WHEN DATEDIFF(YEAR, FechaNacimiento, GETDATE()) BETWEEN 31 AND 50 THEN 'Adulto'
        ELSE 'Senior'
    END AS SegmentoEdad,
    ISNULL(FechaCreacion, CAST(GETDATE() AS DATE)) AS FechaRegistro
FROM dbo.Clientes;

-- -----------------------------------------------------------------------------
-- 3. QUERY PARA DIMENSIÓN VENDEDOR (DimVendedor)
-- Nota: Unimos Empleado con Departamento (Región)
-- -----------------------------------------------------------------------------
SELECT 
    E.ID_Empleado AS ID_Empleado_BK,
    (E.Nombre + ' ' + E.Apellido) AS NombreCompleto,
    E.Cargo,
    D.NombreDepartamento AS Region
FROM dbo.Empleados E
INNER JOIN dbo.Departamentos D ON E.ID_Departamento = D.ID_Departamento;

-- -----------------------------------------------------------------------------
-- 4. QUERY PARA DIMENSIÓN MÉTODO PAGO (DimMetodoPago)
-- -----------------------------------------------------------------------------
SELECT 
    ID_MetodoPago AS ID_MetodoPago_BK,
    NombreMetodo
FROM dbo.MetodosPago;

-- -----------------------------------------------------------------------------
-- 5. QUERY PARA FACT VENTAS (FactVentas) - ¡CRÍTICO!
-- Traemos los IDs originales (BK) y convertimos la Fecha a Entero (DateKey)
-- para que el cruce en SSIS sea perfecto.
-- -----------------------------------------------------------------------------
SELECT 
    -- Claves para hacer LOOKUP en SSIS
    P.FechaPedido, -- Se usará para derivar el DateKey
    CONVERT(INT, CONVERT(VARCHAR(8), P.FechaPedido, 112)) AS DateKey_In, -- Calculado directo
    DP.ID_Producto AS ID_Producto_BK,
    P.ID_Cliente AS ID_Cliente_BK,
    P.ID_Empleado AS ID_Empleado_BK,    
    P.ID_MetodoPago AS ID_MetodoPago_BK,
    
    -- Clave Degenerada
    P.ID_Pedido AS ID_Pedido_BK,
    
    -- Métricas
    DP.Cantidad,
    DP.PrecioUnitario AS PrecioUnitarioVenta,
    CAST((DP.Cantidad * DP.PrecioUnitario) AS DECIMAL(18,2)) AS MontoTotalLinea
FROM dbo.Pedidos P
INNER JOIN dbo.DetallePedidos DP ON P.ID_Pedido = DP.ID_Pedido
-- WHERE P.ID_Estado = 2; -- OPCIONAL: Solo cargar ventas 'Pagadas' si esa es la regla.



-- =============================================================================
-- QUERY PARA FACT INVENTARIO (Bitacora)
-- Instrucciones: Copia esto en el OLE DB Source de SSIS
-- =============================================================================
SELECT 
    -- 1. Calculamos el DateKey para enlazar con DimTiempo
    CONVERT(INT, CONVERT(VARCHAR(8), FechaMovimiento, 112)) AS DateKey_In,
    
    -- 2. ID Original para buscar el ProductKey
    ID_Producto AS ID_Producto_BK,
    
    -- 3. Métricas directas
    Cantidad AS CantidadMovimiento,
    TipoMovimiento
FROM dbo.BitacoraInventario;

