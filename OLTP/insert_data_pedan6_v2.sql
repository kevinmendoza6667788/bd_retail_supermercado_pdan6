-- =============================================================================
-- SCRIPT DE POBLADO DE DATOS MAESTROS (V3.1 - FIXED) - TIENDAS TAMBO
-- Contexto: Retail Perú (Soles, Productos Locales)
-- Rango de Fechas: Histórico simulado (Oct 2025 - Ene 2026)
-- Corrección: Manejo de variables para PRINT (Fix Msg 1046)
-- Autor: Data Architect Lead
-- =============================================================================

USE bd_pedan6;
GO

-- 1. LIMPIEZA PREVIA (Orden inverso para integridad referencial)
DELETE FROM Resenas;
DELETE FROM BitacoraInventario;
DELETE FROM DetallePedidos;
DELETE FROM Pedidos;
DELETE FROM Productos;
DELETE FROM Proveedores;
DELETE FROM Clientes;
DELETE FROM Empleados;
DELETE FROM Departamentos;
DELETE FROM MetodosPago;
DELETE FROM EstadosPedido;
DELETE FROM Categorias;

-- REINICIAR CONTADORES IDENTITY
DBCC CHECKIDENT ('Categorias', RESEED, 0);
DBCC CHECKIDENT ('EstadosPedido', RESEED, 0);
DBCC CHECKIDENT ('MetodosPago', RESEED, 0);
DBCC CHECKIDENT ('Departamentos', RESEED, 0);
DBCC CHECKIDENT ('Empleados', RESEED, 0);
DBCC CHECKIDENT ('Clientes', RESEED, 0);
DBCC CHECKIDENT ('Proveedores', RESEED, 0);
DBCC CHECKIDENT ('Productos', RESEED, 0);
DBCC CHECKIDENT ('Pedidos', RESEED, 0);
DBCC CHECKIDENT ('DetallePedidos', RESEED, 0);
DBCC CHECKIDENT ('BitacoraInventario', RESEED, 0);
DBCC CHECKIDENT ('Resenas', RESEED, 0);
GO

PRINT '>>> INICIANDO CARGA MASIVA DE DATOS...';

-- =======================================================
-- 1. CATÁLOGOS
-- =======================================================
INSERT INTO Categorias (NombreCategoria, Descripcion) VALUES 
('Bebidas Alcohólicas', 'Cervezas, Vinos y Licores'),
('Bebidas No Alcohólicas', 'Gaseosas, Aguas, Energizantes'),
('Snacks y Golosinas', 'Papas, Chocolates, Galletas'),
('Comidas Preparadas', 'Empanadas, Pizzas, Sándwiches'),
('Cuidado Personal', 'Shampoo, Jabones, Higiene');

INSERT INTO EstadosPedido (NombreEstado) VALUES ('Pendiente'), ('Pagado'), ('Entregado'), ('Cancelado');
INSERT INTO MetodosPago (NombreMetodo) VALUES ('Efectivo'), ('Tarjeta Crédito/Débito'), ('Yape/Plin'), ('Web/App');

-- Departamentos (Regiones)
INSERT INTO Departamentos (NombreDepartamento) VALUES ('Lima'), ('La Libertad'), ('Ica'), ('Cusco');

-- =======================================================
-- 2. EMPLEADOS (CAJEROS POR REGIÓN)
-- =======================================================
INSERT INTO Empleados (Nombre, Apellido, ID_Departamento, FechaContratacion, Cargo) VALUES
('Juan', 'Quispe', 1, '2022-01-15', 'Cajero Tiempo Completo'),  -- Lima (ID 1)
('Maria', 'Flores', 4, '2021-05-20', 'Cajero Medio Tiempo'),     -- Cusco (ID 2)
('Carlos', 'Rodriguez', 3, '2023-03-10', 'Cajero Tiempo Completo'), -- Ica (ID 3)
('Ana', 'Lopez', 2, '2020-11-01', 'Cajero Medio Tiempo');        -- La Libertad (ID 4)

-- =======================================================
-- 3. PROVEEDORES
-- =======================================================
INSERT INTO Proveedores (NombreProveedor, NombreContacto, Telefono, Email, Direccion) VALUES
('Backus y Johnston', 'Roberto Ventas', '999888777', 'ventas@backus.pe', 'Av. Nicolas Ayllon, Ate, Lima'), -- ID 1
('Arca Continental Lindley', 'Soporte Corp', '01-311-5000', 'pedidos@lindley.pe', 'Trujillo, La Libertad'), -- ID 2
('Alicorp', 'Lucia Distribución', '01-555-1234', 'ventas@alicorp.pe', 'Callao, Lima'), -- ID 3
('San Fernando', 'Jorge Avícola', '999111222', 'contacto@san-fernando.pe', 'Chincha, Ica'), -- ID 4
('P&G Perú', 'Mario Higiene', '01-200-9999', 'ventas@pg.com', 'San Isidro, Lima'), -- ID 5 (Nuevo)
('Cartavio Rum', 'Destileria Norte', '044-555-666', 'ventas@cartavio.pe', 'Cartavio, La Libertad'); -- ID 6 (Nuevo)

-- =======================================================
-- 4. CLIENTES (AMPLIADO A 8)
-- =======================================================
INSERT INTO Clientes (Nombre, Apellido, Email, Usuario, HashContrasena, FechaNacimiento, Direccion, FechaCreacion) VALUES
-- Clientes Originales
('Luis', 'Gomez', 'luis.g@gmail.com', 'lgomez', 'xxx', '1990-05-15', 'Lince, Lima', '2025-10-01'), -- ID 1
('Sofia', 'Mendez', 'sofia.m@hotmail.com', 'smendez', 'xxx', '1995-08-22', 'Cusco Centro', '2025-10-15'), -- ID 2
('Pedro', 'Castillo', 'p.castillo@yahoo.com', 'pcastillo', 'xxx', '1985-12-10', 'Trujillo, LL', '2025-11-05'), -- ID 3
-- Clientes Nuevos
('Ana', 'Paula', 'ana.paula@gmail.com', 'apaula', 'xxx', '1998-02-14', 'Miraflores, Lima', '2025-11-20'), -- ID 4
('Jorge', 'Chavez', 'jchavez@outlook.com', 'jchavez', 'xxx', '1980-07-28', 'Ica Centro', '2025-11-25'), -- ID 5
('Micaela', 'Bastidas', 'mbastidas@gmail.com', 'mbastidas', 'xxx', '1992-11-04', 'San Blas, Cusco', '2025-12-01'), -- ID 6
('Ricardo', 'Palma', 'rpalma@yahoo.com', 'rpalma', 'xxx', '1975-10-06', 'Surco, Lima', '2025-12-10'), -- ID 7
('Miguel', 'Grau', 'mgrau@marina.pe', 'mgrau', 'xxx', '1988-10-08', 'Huanchaco, LL', '2025-12-15'); -- ID 8

-- =======================================================
-- 5. PRODUCTOS (AMPLIADO A 10)
-- =======================================================
INSERT INTO Productos (NombreProducto, ID_Categoria, Descripcion, PrecioVenta, CantidadStock) VALUES
-- Originales
('Cerveza Pilsen Callao 630ml', 1, 'Cerveza rubia', 7.50, 0),    -- ID 1
('Inca Kola 500ml', 2, 'Gaseosa nacional', 3.50, 0),           -- ID 2
('Sublime Clásico 30g', 3, 'Chocolate leche', 2.00, 0),        -- ID 3
('Empanada de Carne', 4, 'Horneada del día', 4.90, 0),         -- ID 4
('Papas Lays Clásicas 160g', 3, 'Papas fritas', 8.50, 0),      -- ID 5
-- Nuevos
('Ron Cartavio Selecto 5A', 1, 'Ron añejo 750ml', 45.00, 0),   -- ID 6
('Agua San Luis 1L', 2, 'Agua sin gas', 2.50, 0),              -- ID 7
('Galletas Casino Menta', 3, 'Paquete familiar', 3.20, 0),     -- ID 8
('Shampoo Head & Shoulders', 5, 'Limpieza 400ml', 18.50, 0),   -- ID 9
('Cigarros Hamilton', 3, 'Cajetilla 10 und', 12.00, 0);        -- ID 10 (Asignado a Snacks/Varios por simplificacion)

-- =======================================================
-- 6. ABASTECIMIENTO INICIAL (Bitácora - Octubre 2025)
-- =======================================================
DECLARE @FComp DATETIME = '2025-10-25 08:00:00';

-- Lote 1: Bebidas
INSERT INTO BitacoraInventario (ID_Producto, ID_Proveedor, TipoMovimiento, Cantidad, ID_Empleado, FechaMovimiento) VALUES 
(1, 1, 'EntradaProveedor', 500, 1, @FComp), (2, 2, 'EntradaProveedor', 500, 1, @FComp), (6, 6, 'EntradaProveedor', 100, 4, @FComp), (7, 2, 'EntradaProveedor', 300, 1, @FComp);
-- Lote 2: Comida/Snacks
INSERT INTO BitacoraInventario (ID_Producto, ID_Proveedor, TipoMovimiento, Cantidad, ID_Empleado, FechaMovimiento) VALUES 
(3, 3, 'EntradaProveedor', 400, 3, @FComp), (4, 4, 'EntradaProveedor', 100, 2, @FComp), (5, 3, 'EntradaProveedor', 200, 3, @FComp), (8, 3, 'EntradaProveedor', 200, 3, @FComp);
-- Lote 3: Varios
INSERT INTO BitacoraInventario (ID_Producto, ID_Proveedor, TipoMovimiento, Cantidad, ID_Empleado, FechaMovimiento) VALUES 
(9, 5, 'EntradaProveedor', 50, 1, @FComp), (10, 2, 'EntradaProveedor', 100, 4, @FComp);

-- Actualizar Stock Maestro
UPDATE P SET CantidadStock = (SELECT SUM(Cantidad) FROM BitacoraInventario WHERE ID_Producto = P.ID_Producto) FROM Productos P;

-- =======================================================
-- 7. GENERACIÓN MASIVA DE VENTAS (23 PEDIDOS)
-- Distribuimos entre Nov 2025 y Ene 2026
-- =======================================================

-- Variable temporal para IDs
DECLARE @IdP INT, @IdD INT;

-- >>> NOVIEMBRE 2025 (Inicio de Campaña)
-- 1. Luis (Lima) - Pilsen y Empanada
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (1, 1, 2, 1, '2025-11-15 18:30:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 1, 2, 7.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (1, NULL, @IdD, 'SalidaVenta', -2, '2025-11-15', 1);
    INSERT INTO DetallePedidos VALUES (@IdP, 4, 1, 4.90); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (4, NULL, @IdD, 'SalidaVenta', -1, '2025-11-15', 1);

-- 2. Ana Paula (Lima) - Shampoo (Ticket Alto)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (4, 1, 2, 2, '2025-11-21 10:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 9, 2, 18.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (9, NULL, @IdD, 'SalidaVenta', -2, '2025-11-21', 1);

-- 3. Jorge Chavez (Ica) - Ron Cartavio (Fin de semana)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (5, 3, 2, 3, '2025-11-28 22:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 6, 1, 45.00); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (6, NULL, @IdD, 'SalidaVenta', -1, '2025-11-28', 3);
    INSERT INTO DetallePedidos VALUES (@IdP, 2, 1, 3.50); SET @IdD = SCOPE_IDENTITY(); -- Mezclador
    INSERT INTO BitacoraInventario VALUES (2, NULL, @IdD, 'SalidaVenta', -1, '2025-11-28', 3);

-- 4. Pedro (Trujillo) - Cigarros y Agua
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (3, 4, 2, 1, '2025-11-30 09:15:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 10, 1, 12.00); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (10, NULL, @IdD, 'SalidaVenta', -1, '2025-11-30', 4);
    INSERT INTO DetallePedidos VALUES (@IdP, 7, 1, 2.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (7, NULL, @IdD, 'SalidaVenta', -1, '2025-11-30', 4);

-- >>> DICIEMBRE 2025 (Pico de Venta - Navidad/Año Nuevo)
-- 5. Sofia (Cusco) - Pack Navideño (Inca Kola + Sublimes)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (2, 2, 2, 3, '2025-12-15 14:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 2, 6, 3.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (2, NULL, @IdD, 'SalidaVenta', -6, '2025-12-15', 2);
    INSERT INTO DetallePedidos VALUES (@IdP, 3, 10, 2.00); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (3, NULL, @IdD, 'SalidaVenta', -10, '2025-12-15', 2);

-- 6. Micaela (Cusco) - Lays y Casino
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (6, 2, 2, 1, '2025-12-20 16:30:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 5, 2, 8.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (5, NULL, @IdD, 'SalidaVenta', -2, '2025-12-20', 2);
    INSERT INTO DetallePedidos VALUES (@IdP, 8, 3, 3.20); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (8, NULL, @IdD, 'SalidaVenta', -3, '2025-12-20', 2);

-- 7. Ricardo (Lima) - Compra grande oficina (Empanadas + Gaseosa)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (7, 1, 2, 2, '2025-12-22 13:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 4, 10, 4.90); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (4, NULL, @IdD, 'SalidaVenta', -10, '2025-12-22', 1);
    INSERT INTO DetallePedidos VALUES (@IdP, 2, 5, 3.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (2, NULL, @IdD, 'SalidaVenta', -5, '2025-12-22', 1);

-- 8. Miguel (Trujillo) - Previa Año Nuevo (Ron + Cola + Hielo[Simulado])
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (8, 4, 2, 2, '2025-12-31 19:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 6, 2, 45.00); SET @IdD = SCOPE_IDENTITY(); -- 2 Rones
    INSERT INTO BitacoraInventario VALUES (6, NULL, @IdD, 'SalidaVenta', -2, '2025-12-31', 4);
    INSERT INTO DetallePedidos VALUES (@IdP, 2, 2, 3.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (2, NULL, @IdD, 'SalidaVenta', -2, '2025-12-31', 4);

-- 9. Luis (Lima) - Año Nuevo (Cervezas)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (1, 1, 2, 3, '2025-12-31 20:30:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 1, 24, 7.50); SET @IdD = SCOPE_IDENTITY(); -- Caja
    INSERT INTO BitacoraInventario VALUES (1, NULL, @IdD, 'SalidaVenta', -24, '2025-12-31', 1);

-- 10. Ana Paula (Lima) - Snacks
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (4, 1, 2, 1, '2025-12-28 15:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 5, 1, 8.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (5, NULL, @IdD, 'SalidaVenta', -1, '2025-12-28', 1);

-- >>> ENERO 2026 (Verano)
-- 11. Pedro (Trujillo) - Verano (Cervezas)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (3, 4, 2, 2, '2026-01-05 21:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 1, 12, 7.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (1, NULL, @IdD, 'SalidaVenta', -12, '2026-01-05', 4);

-- 12. Jorge (Ica) - Agua y Galletas
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (5, 3, 2, 1, '2026-01-10 11:00:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 7, 3, 2.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (7, NULL, @IdD, 'SalidaVenta', -3, '2026-01-10', 3);
    INSERT INTO DetallePedidos VALUES (@IdP, 8, 2, 3.20); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (8, NULL, @IdD, 'SalidaVenta', -2, '2026-01-10', 3);

-- 13. Ricardo (Lima) - Almuerzo (Empanada + Inca Kola)
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (7, 1, 2, 1, '2026-01-12 13:15:00'); SET @IdP = SCOPE_IDENTITY();
    INSERT INTO DetallePedidos VALUES (@IdP, 4, 2, 4.90); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (4, NULL, @IdD, 'SalidaVenta', -2, '2026-01-12', 1);
    INSERT INTO DetallePedidos VALUES (@IdP, 2, 2, 3.50); SET @IdD = SCOPE_IDENTITY();
    INSERT INTO BitacoraInventario VALUES (2, NULL, @IdD, 'SalidaVenta', -2, '2026-01-12', 1);

-- 14-20. Generación Rápida de Pedidos Menores (Relleno para volumen)
-- Pedido 14
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (1, 1, 2, 1, '2026-01-15 08:30:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 7, 1, 2.50); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (7, NULL, @IdD, 'SalidaVenta', -1, '2026-01-15', 1);

-- Pedido 15
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (2, 2, 2, 3, '2026-01-18 19:00:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 3, 4, 2.00); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (3, NULL, @IdD, 'SalidaVenta', -4, '2026-01-18', 2);

-- Pedido 16
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (3, 4, 2, 2, '2026-01-20 22:15:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 10, 2, 12.00); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (10, NULL, @IdD, 'SalidaVenta', -2, '2026-01-20', 4);

-- Pedido 17
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (4, 1, 2, 4, '2026-01-22 14:00:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 9, 1, 18.50); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (9, NULL, @IdD, 'SalidaVenta', -1, '2026-01-22', 1);

-- Pedido 18
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (5, 3, 2, 1, '2026-01-25 10:30:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 8, 2, 3.20); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (8, NULL, @IdD, 'SalidaVenta', -2, '2026-01-25', 3);

-- Pedido 19
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (6, 2, 2, 3, '2026-01-28 17:45:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 2, 2, 3.50); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (2, NULL, @IdD, 'SalidaVenta', -2, '2026-01-28', 2);

-- Pedido 20
INSERT INTO Pedidos (ID_Cliente, ID_Empleado, ID_Estado, ID_MetodoPago, FechaPedido) VALUES (7, 1, 2, 2, '2026-01-30 20:00:00'); SET @IdP = SCOPE_IDENTITY();
INSERT INTO DetallePedidos VALUES (@IdP, 1, 6, 7.50); SET @IdD = SCOPE_IDENTITY();
INSERT INTO BitacoraInventario VALUES (1, NULL, @IdD, 'SalidaVenta', -6, '2026-01-30', 1);


UPDATE P
SET P.MontoTotal = (SELECT ISNULL(SUM(d.Cantidad * d.PrecioUnitario), 0) 
                    FROM DetallePedidos d WHERE d.ID_Pedido = P.ID_Pedido)
FROM Pedidos P;



UPDATE P
SET P.CantidadStock = (
    SELECT 
        ISNULL(SUM(CASE WHEN TipoMovimiento IN ('EntradaProveedor', 'Devolucion', 'AjusteManual') THEN Cantidad ELSE 0 END), 0) -
        ISNULL(SUM(CASE WHEN TipoMovimiento IN ('SalidaVenta') THEN ABS(Cantidad) ELSE 0 END), 0)
    FROM BitacoraInventario B
    WHERE B.ID_Producto = P.ID_Producto
)
FROM Productos P;

-- =======================================================
-- 9. RESEÑAS ADICIONALES
-- =======================================================
INSERT INTO Resenas (ID_Cliente, ID_Producto, Puntuacion, Comentario, FechaResena) VALUES
(1, 1, 5, 'Siempre helada, excelente.', '2025-11-16'),
(4, 9, 4, 'Buen precio para el shampoo.', '2025-11-22'),
(8, 6, 5, 'El ron llegó bien, buena promo.', '2026-01-02');

PRINT '>>> CARGA MASIVA V3 COMPLETADA.';

-- FIX MSG 1046: Usar variables para evitar subconsultas en PRINT
DECLARE @CantClientes INT = (SELECT COUNT(*) FROM Clientes);
DECLARE @CantProductos INT = (SELECT COUNT(*) FROM Productos);
DECLARE @CantPedidos INT = (SELECT COUNT(*) FROM Pedidos);

PRINT '>>> ESTADÍSTICAS:';
PRINT '    - Clientes: ' + CAST(@CantClientes AS VARCHAR);
PRINT '    - Productos: ' + CAST(@CantProductos AS VARCHAR);
PRINT '    - Pedidos: ' + CAST(@CantPedidos AS VARCHAR);