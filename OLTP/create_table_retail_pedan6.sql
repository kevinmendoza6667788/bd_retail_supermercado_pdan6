use bd_pedan6;

-- =======================================================
-- 1. TABLAS DE CATÁLOGO (LOOKUP) - Crear primero
-- =======================================================

CREATE TABLE Categorias (
    ID_Categoria INT PRIMARY KEY IDENTITY(1,1),
    NombreCategoria NVARCHAR(50) NOT NULL UNIQUE,
    Descripcion NVARCHAR(200)
);

CREATE TABLE EstadosPedido (
    ID_Estado INT PRIMARY KEY IDENTITY(1,1),
    NombreEstado NVARCHAR(50) NOT NULL UNIQUE -- 'Pendiente', 'Pagado', 'Enviado'
);

CREATE TABLE MetodosPago (
    ID_MetodoPago INT PRIMARY KEY IDENTITY(1,1),
    NombreMetodo NVARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Departamentos (
    ID_Departamento INT PRIMARY KEY IDENTITY(1,1),
    NombreDepartamento NVARCHAR(50) NOT NULL UNIQUE,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

-- =======================================================
-- 2. TABLAS DE ENTIDADES (PERSONAS Y EMPRESAS)
-- =======================================================

CREATE TABLE Empleados (
    ID_Empleado INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL,
    Apellido NVARCHAR(50) NOT NULL,
    ID_Departamento INT NOT NULL FOREIGN KEY REFERENCES Departamentos(ID_Departamento),
    FechaContratacion DATE NOT NULL,
    Cargo NVARCHAR(50) NOT NULL,
    EsActivo BIT DEFAULT 1
);

CREATE TABLE Clientes (
    ID_Cliente INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL,
    Apellido NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    Usuario NVARCHAR(50) UNIQUE NOT NULL,
    HashContrasena NVARCHAR(255) NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Direccion NVARCHAR(255),
    EsActivo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Proveedores (
    ID_Proveedor INT PRIMARY KEY IDENTITY(1,1),
    NombreProveedor NVARCHAR(100) UNIQUE NOT NULL,
    NombreContacto NVARCHAR(100) NOT NULL,
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    Direccion NVARCHAR(255),
    CalificacionConfiabilidad DECIMAL(3,2) DEFAULT 5.0
);

-- =======================================================
-- 3. PRODUCTOS (SOLO DEFINICIÓN)
-- Nota: Aquí NO hay ID_Proveedor, cumpliendo el desacople.
-- =======================================================

CREATE TABLE Productos (
    ID_Producto INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(100) NOT NULL,
    ID_Categoria INT NOT NULL FOREIGN KEY REFERENCES Categorias(ID_Categoria),
    Descripcion NVARCHAR(MAX),
    PrecioVenta DECIMAL(10,2) NOT NULL CHECK (PrecioVenta > 0),
    CantidadStock INT DEFAULT 0, -- Se actualizará automáticamente según la Bitácora
    NivelReorden INT DEFAULT 10
);

-- =======================================================
-- 4. PEDIDOS Y DETALLES (LA VENTA)
-- =======================================================

CREATE TABLE Pedidos (
    ID_Pedido INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    ID_Empleado INT NULL FOREIGN KEY REFERENCES Empleados(ID_Empleado), -- NULL si es venta automática
    ID_Estado INT NOT NULL FOREIGN KEY REFERENCES EstadosPedido(ID_Estado),
    ID_MetodoPago INT NULL FOREIGN KEY REFERENCES MetodosPago(ID_MetodoPago),
    FechaPedido DATETIME DEFAULT GETDATE(),
    NumeroRastreo UNIQUEIDENTIFIER DEFAULT NEWID(),
    MontoTotal DECIMAL(12,2) DEFAULT 0
);

CREATE TABLE DetallePedidos (
    ID_DetallePedido INT PRIMARY KEY IDENTITY(1,1),
    ID_Pedido INT NOT NULL FOREIGN KEY REFERENCES Pedidos(ID_Pedido),
    ID_Producto INT NOT NULL FOREIGN KEY REFERENCES Productos(ID_Producto),
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    TotalLinea AS (Cantidad * PrecioUnitario) PERSISTED
    -- Aquí termina la venta. La relación con inventario sucede en la tabla siguiente.
);

-- =======================================================
-- 5. BITÁCORA DE INVENTARIO (EL CENTRO DE TODO)
-- Esta tabla materializa las relaciones que pediste:
-- Proveedores (1) <--> (M) Bitacora
-- DetallePedidos (1) <--> (M) Bitacora
-- =======================================================

CREATE TABLE BitacoraInventario (
    ID_Log INT PRIMARY KEY IDENTITY(1,1),
    
    -- Relación: Productos (1) <---> (M) Bitacora
    ID_Producto INT NOT NULL FOREIGN KEY REFERENCES Productos(ID_Producto),
    
    -- Relación: Proveedores (1) <---> (M) Bitacora
    -- Solo se llena cuando entra mercancía (COMPRA)
    ID_Proveedor INT NULL FOREIGN KEY REFERENCES Proveedores(ID_Proveedor),
    
    -- Relación: DetallePedidos (1) <---> (M) Bitacora
    -- Solo se llena cuando sale mercancía (VENTA)
    ID_DetallePedido INT NULL FOREIGN KEY REFERENCES DetallePedidos(ID_DetallePedido),
    
    -- Datos del movimiento
    TipoMovimiento NVARCHAR(20) NOT NULL CHECK (TipoMovimiento IN ('EntradaProveedor', 'SalidaVenta', 'AjusteManual', 'Devolucion')),
    Cantidad INT NOT NULL, -- Positivo (+) o Negativo (-)
    FechaMovimiento DATETIME DEFAULT GETDATE(),
    ID_Empleado INT NULL FOREIGN KEY REFERENCES Empleados(ID_Empleado), -- Quién registró el movimiento
    
    -- REGLA DE NEGOCIO (CONSTRAINT): 
    -- Un registro no puede tener Proveedor Y DetallePedido al mismo tiempo. O es entrada o es salida.
    CONSTRAINT CHK_OrigenMovimiento CHECK (
        (ID_Proveedor IS NOT NULL AND ID_DetallePedido IS NULL) OR 
        (ID_Proveedor IS NULL AND ID_DetallePedido IS NOT NULL) OR
        (ID_Proveedor IS NULL AND ID_DetallePedido IS NULL) -- Para ajustes manuales
    )
);

-- =======================================================
-- 6. EXTRAS (RESEÑAS)
-- =======================================================
CREATE TABLE Resenas (
    ID_Resena INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    ID_Producto INT NOT NULL FOREIGN KEY REFERENCES Productos(ID_Producto),
    Puntuacion INT CHECK (Puntuacion BETWEEN 1 AND 5),
    Comentario NVARCHAR(MAX),
    FechaResena DATETIME DEFAULT GETDATE(),
    CONSTRAINT UC_ResenaProducto UNIQUE (ID_Cliente, ID_Producto)
);