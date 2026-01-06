
-- Tablas Principales (Core)
CREATE TABLE Departamentos (
    ID_Departamento INT PRIMARY KEY IDENTITY(1,1),
    NombreDepartamento NVARCHAR(50) NOT NULL UNIQUE,
    FechaCreacion DATETIME DEFAULT GETDATE()
);

CREATE TABLE Empleados (
    ID_Empleado INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL,
    Apellido NVARCHAR(50) NOT NULL,
    ID_Departamento INT NOT NULL FOREIGN KEY REFERENCES Departamentos(ID_Departamento),
    FechaContratacion DATE NOT NULL,
    Cargo NVARCHAR(50) NOT NULL, -- Position traducido como Cargo
    EsActivo BIT DEFAULT 1,
    CONSTRAINT CHK_FechaContratacion CHECK (FechaContratacion <= GETDATE())
);

CREATE TABLE Clientes (
    ID_Cliente INT PRIMARY KEY IDENTITY(1,1),
    Nombre NVARCHAR(50) NOT NULL,
    Apellido NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    FechaNacimiento DATE NOT NULL,
    Direccion NVARCHAR(255),
    Usuario NVARCHAR(50) UNIQUE NOT NULL,
    HashContrasena NVARCHAR(255) NOT NULL,
    EsActivo BIT DEFAULT 1,
    FechaCreacion DATETIME DEFAULT GETDATE(),
    CONSTRAINT CHK_Edad CHECK (DATEDIFF(YEAR, FechaNacimiento, GETDATE()) >= 18)
);

CREATE TABLE Proveedores (
    ID_Proveedor INT PRIMARY KEY IDENTITY(1,1),
    NombreProveedor NVARCHAR(100) UNIQUE NOT NULL,
    NombreContacto NVARCHAR(100) NOT NULL,
    Direccion NVARCHAR(255),
    Telefono NVARCHAR(20),
    Email NVARCHAR(100),
    CalificacionConfiabilidad DECIMAL(3,2) DEFAULT 5.0,
    FechaUltimaEntrega DATE
);

CREATE TABLE Productos (
    ID_Producto INT PRIMARY KEY IDENTITY(1,1),
    NombreProducto NVARCHAR(100) NOT NULL,
    Categoria NVARCHAR(50) NOT NULL,
    Descripcion NVARCHAR(MAX),
    Precio DECIMAL(10,2) NOT NULL CHECK (Precio > 0),
    PrecioCosto DECIMAL(10,2) NOT NULL,
    ID_Proveedor INT NOT NULL FOREIGN KEY REFERENCES Proveedores(ID_Proveedor),
    CantidadStock INT NOT NULL CHECK (CantidadStock >= 0),
    NivelReorden INT DEFAULT 10,
    FechaUltimaReposicion DATE
);

CREATE TABLE Pedidos (
    ID_Pedido INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    ID_Empleado INT NOT NULL FOREIGN KEY REFERENCES Empleados(ID_Empleado),
    FechaPedido DATETIME DEFAULT GETDATE() NOT NULL,
    MontoTotal DECIMAL(12,2) CHECK (MontoTotal >= 0),
    EstadoPago NVARCHAR(20) 
        DEFAULT 'Pendiente' 
        CHECK (EstadoPago IN ('Pendiente', 'Completado', 'Reembolsado')), -- Traduje los valores del CHECK
    MetodoPago NVARCHAR(50),
    NumeroRastreo UNIQUEIDENTIFIER DEFAULT NEWID(),
    CONSTRAINT CHK_FechaPedido CHECK (FechaPedido <= GETDATE())
);

-- Tablas de Unión (Junction Tables / Detalles)
CREATE TABLE DetallePedidos (
    ID_DetallePedido INT PRIMARY KEY IDENTITY(1,1),
    ID_Pedido INT NOT NULL FOREIGN KEY REFERENCES Pedidos(ID_Pedido),
    ID_Producto INT NOT NULL FOREIGN KEY REFERENCES Productos(ID_Producto),
    Cantidad INT NOT NULL CHECK (Cantidad > 0),
    PrecioUnitario DECIMAL(10,2) NOT NULL,
    TotalLinea AS (Cantidad * PrecioUnitario) PERSISTED, -- Columna calculada
    INDEX IX_DetallePedidos_Producto (ID_Producto)
);

CREATE TABLE Resenas (
    ID_Resena INT PRIMARY KEY IDENTITY(1,1),
    ID_Cliente INT NOT NULL FOREIGN KEY REFERENCES Clientes(ID_Cliente),
    ID_Producto INT NOT NULL FOREIGN KEY REFERENCES Productos(ID_Producto),
    Puntuacion INT CHECK (Puntuacion BETWEEN 1 AND 5),
    Comentario NVARCHAR(MAX),
    FechaResena DATETIME DEFAULT GETDATE(),
    CONSTRAINT UC_ResenaProducto UNIQUE (ID_Cliente, ID_Producto)
);

-- Gestión de Inventario
CREATE TABLE BitacoraInventario (
    ID_Log INT PRIMARY KEY IDENTITY(1,1),
    ID_Producto INT NOT NULL FOREIGN KEY REFERENCES Productos(ID_Producto),
    Ajuste INT NOT NULL, -- Cantidad positiva o negativa
    Motivo NVARCHAR(100),
    FechaLog DATETIME DEFAULT GETDATE(),
    ID_Empleado INT FOREIGN KEY REFERENCES Empleados(ID_Empleado)
);