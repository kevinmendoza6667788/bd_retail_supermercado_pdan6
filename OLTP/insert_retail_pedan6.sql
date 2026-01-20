use bd_pedan6;

-- ============================================================
-- SCRIPT DE GENERACIÓN DE DATOS MASIVOS (DUMMY DATA)
-- Versión Corregida y Final
-- Propósito: Insertar min 20 registros respetando integridad referencial
-- ============================================================



SET NOCOUNT ON; -- Evita mensajes innecesarios en la consola

-- ============================================================
-- 1. TABLAS CATÁLOGO (Nivel 0 - Independientes)
-- ============================================================

-- Categorias
PRINT 'Insertando Categorias...';
DECLARE @i INT = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Categorias (NombreCategoria, Descripcion)
    VALUES ('Categoria ' + CAST(@i AS NVARCHAR), 'Descripcion para categoria ' + CAST(@i AS NVARCHAR));
    SET @i = @i + 1;
END

-- EstadosPedido
PRINT 'Insertando EstadosPedido...';
-- Insertamos estados lógicos primero
INSERT INTO EstadosPedido (NombreEstado) VALUES ('Pendiente'), ('Confirmado'), ('Enviado'), ('Entregado'), ('Cancelado'), ('Devuelto');
SET @i = 7;
WHILE @i <= 20
BEGIN
    INSERT INTO EstadosPedido (NombreEstado) VALUES ('Estado Personalizado ' + CAST(@i AS NVARCHAR));
    SET @i = @i + 1;
END

-- MetodosPago
PRINT 'Insertando MetodosPago...';
INSERT INTO MetodosPago (NombreMetodo) VALUES ('Efectivo'), ('Tarjeta Credito'), ('Tarjeta Debito'), ('PayPal'), ('Transferencia'), ('Yape/Plin');
SET @i = 7;
WHILE @i <= 20
BEGIN
    INSERT INTO MetodosPago (NombreMetodo) VALUES ('Metodo Alternativo ' + CAST(@i AS NVARCHAR));
    SET @i = @i + 1;
END

-- Departamentos
PRINT 'Insertando Departamentos...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Departamentos (NombreDepartamento) 
    VALUES ('Departamento ' + CAST(@i AS NVARCHAR));
    SET @i = @i + 1;
END

-- ============================================================
-- 2. TABLAS DE ENTIDADES (Nivel 1 - Dependen de Nivel 0)
-- ============================================================

-- Proveedores
PRINT 'Insertando Proveedores...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Proveedores (NombreProveedor, NombreContacto, Telefono, Email, Direccion)
    VALUES (
        'Proveedor ' + CAST(@i AS NVARCHAR) + ' S.A.',
        'Contacto ' + CAST(@i AS NVARCHAR),
        '555-00' + CAST(@i AS NVARCHAR),
        'prov' + CAST(@i AS NVARCHAR) + '@empresa.com',
        'Av. Industrial #' + CAST(@i AS NVARCHAR)
    );
    SET @i = @i + 1;
END

-- Empleados
PRINT 'Insertando Empleados...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Empleados (Nombre, Apellido, ID_Departamento, FechaContratacion, Cargo)
    VALUES (
        'Empleado' + CAST(@i AS NVARCHAR),
        'Apellido' + CAST(@i AS NVARCHAR),
        (SELECT TOP 1 ID_Departamento FROM Departamentos ORDER BY NEWID()), -- Dept Aleatorio
        DATEADD(DAY, -CAST(RAND()*1000 AS INT), GETDATE()), -- Fecha random ultimos 3 años
        'Asistente de Ventas'
    );
    SET @i = @i + 1;
END

-- Clientes
PRINT 'Insertando Clientes...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Clientes (Nombre, Apellido, Email, Usuario, HashContrasena, FechaNacimiento, Direccion)
    VALUES (
        'Cliente' + CAST(@i AS NVARCHAR),
        'Perez' + CAST(@i AS NVARCHAR),
        'cliente' + CAST(@i AS NVARCHAR) + '@mail.com',
        'user_client_' + CAST(@i AS NVARCHAR),
        'HASH_DUMMY_123456',
        DATEADD(YEAR, - (20 + CAST(RAND()*30 AS INT)), GETDATE()), -- Edad entre 20 y 50
        'Calle Falsa ' + CAST(@i AS NVARCHAR)
    );
    SET @i = @i + 1;
END

-- Productos
PRINT 'Insertando Productos...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Productos (NombreProducto, ID_Categoria, Descripcion, PrecioVenta, CantidadStock)
    VALUES (
        'Producto ' + CAST(@i AS NVARCHAR) + ' Pro',
        (SELECT TOP 1 ID_Categoria FROM Categorias ORDER BY NEWID()), -- Categoria Aleatoria
        'Descripcion del producto increíble número ' + CAST(@i AS NVARCHAR),
        CAST((RAND() * 100) + 10 AS DECIMAL(10,2)), -- Precio entre 10 y 110
        0 -- Stock inicial en 0, se llenará con la Bitácora
    );
    SET @i = @i + 1;
END

-- ============================================================
-- 3. TRANSACCIONES (Nivel 2 - Dependen de Nivel 1)
-- ============================================================

-- Pedidos
PRINT 'Insertando Pedidos...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, MontoTotal)
    VALUES (
        (SELECT TOP 1 ID_Cliente FROM Clientes ORDER BY NEWID()),
        (SELECT TOP 1 ID_Empleado FROM Empleados ORDER BY NEWID()),
        (SELECT TOP 1 ID_Estado FROM EstadosPedido ORDER BY NEWID()),
        (SELECT TOP 1 ID_MetodoPago FROM MetodosPago ORDER BY NEWID()),
        0 -- Se actualizará luego
    );
    SET @i = @i + 1;
END

-- DetallePedidos
PRINT 'Insertando DetallePedidos...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    DECLARE @IdProd INT = (SELECT TOP 1 ID_Producto FROM Productos ORDER BY NEWID());
    DECLARE @Precio DECIMAL(10,2) = (SELECT PrecioVenta FROM Productos WHERE ID_Producto = @IdProd);
    
    INSERT INTO DetallePedidos (ID_Pedido, ID_Producto, Cantidad, PrecioUnitario)
    VALUES (
        (SELECT TOP 1 ID_Pedido FROM Pedidos ORDER BY NEWID()),
        @IdProd,
        (CAST(RAND() * 5 AS INT) + 1), -- Cantidad 1 a 6
        @Precio
    );
    SET @i = @i + 1;
END

-- ============================================================
-- 4. EXTRAS Y BITÁCORA (Nivel 3 - Dependencias Complejas)
-- ============================================================

-- Resenas
PRINT 'Insertando Resenas...';
SET @i = 1;
WHILE @i <= 20
BEGIN
    BEGIN TRY
        INSERT INTO Resenas (ID_Cliente, ID_Producto, Puntuacion, Comentario)
        VALUES (
            (SELECT TOP 1 ID_Cliente FROM Clientes ORDER BY NEWID()),
            (SELECT TOP 1 ID_Producto FROM Productos ORDER BY NEWID()),
            (CAST(RAND() * 5 AS INT) + 1), -- 1 a 5
            'Comentario genérico número ' + CAST(@i AS NVARCHAR)
        );
        SET @i = @i + 1;
    END TRY
    BEGIN CATCH
        -- Ignoramos error si sale duplicado por el UNIQUE constraint y seguimos
        SET @i = @i + 1; 
    END CATCH
END

-- BitacoraInventario (CON COLUMNA MOTIVO INCLUIDA)
PRINT 'Insertando BitacoraInventario...';

-- A) Generar 20 Entradas de Mercancía (Compras a Proveedores)
-- Esto representa el stock que entra al almacén
SET @i = 1;
WHILE @i <= 20
BEGIN
    INSERT INTO BitacoraInventario (
        ID_Producto, 
        ID_Proveedor, 
        ID_DetallePedido, 
        TipoMovimiento, 
        Cantidad, 
        Motivo -- ¡Columna agregada!
    )
    VALUES (
        (SELECT TOP 1 ID_Producto FROM Productos ORDER BY NEWID()),
        (SELECT TOP 1 ID_Proveedor FROM Proveedores ORDER BY NEWID()),
        NULL, -- Es compra, no venta (ID_DetallePedido debe ser NULL)
        'EntradaProveedor',
        (CAST(RAND() * 50 AS INT) + 10), -- Entran entre 10 y 60 unidades
        'Compra de reposición inicial'
    );
    SET @i = @i + 1;
END

-- B) Generar registros de SALIDA basados en los DetallePedidos existentes
-- Esto sincroniza las ventas que creamos arriba con el inventario
INSERT INTO BitacoraInventario (
    ID_Producto, 
    ID_Proveedor, 
    ID_DetallePedido, 
    TipoMovimiento, 
    Cantidad, 
    Motivo
)
SELECT 
    ID_Producto,
    NULL, -- Es venta, no compra (ID_Proveedor debe ser NULL)
    ID_DetallePedido,
    'SalidaVenta',
    (Cantidad * -1), -- Convertimos a negativo para reflejar salida
    'Salida automática por Venta'
FROM DetallePedidos;

PRINT '¡Carga de datos completada exitosamente!';
GO