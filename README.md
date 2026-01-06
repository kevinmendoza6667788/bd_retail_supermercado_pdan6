# bd_retail_supermercado_pdan6

📌 Caso de Estudio Retail – Gestión de Ventas e Inventario
Una cadena de supermercados desea desarrollar un sistema de información que permita registrar, controlar y analizar las operaciones comerciales realizadas en sus sucursales, abarcando desde la venta al cliente final hasta la gestión de abastecimiento con proveedores.

El sistema debe permitir:

Gestionar información de clientes y empleados por departamentos.

Administrar el catálogo de productos y proveedores.

Registrar órdenes de venta (pedidos) y sus detalles específicos.

Controlar el historial de movimientos de inventario y auditoría.

Recopilar reseñas y calificaciones de productos.

Posteriormente, facilitar el análisis de rentabilidad y logística para la toma de decisiones gerenciales.

# 🧩 PARTE I – Modelo Transaccional (OLTP)
🎯 Objetivo
Diseñar un modelo de datos relacional normalizado que permita registrar correctamente las operaciones diarias de venta, reposición y gestión de personal del supermercado.

🔹 Requerimientos del negocio
La empresa se organiza en Departamentos, a los cuales pertenecen los Empleados.

Los Proveedores suministran Productos, los cuales tienen precio de venta, costo, stock actual y categoría.

Los Clientes se registran con datos personales y credenciales de acceso para realizar compras.

Las Órdenes (Pedidos):

Son realizadas por un Cliente y gestionadas/atendidas por un Empleado.

Registran fecha, monto total, estado del pago (Pendiente, Completado, Reembolsado) y método de pago.

Generan un número de rastreo único.

Cada Orden se desglosa en Detalles de Orden, donde se especifica qué productos y en qué cantidad se compraron, calculando el subtotal por línea.

Se debe mantener una Bitácora de Inventario que registre ajustes (mermas, ingresos, correcciones), indicando el motivo y el empleado responsable.

Los Clientes pueden dejar Reseñas (puntuación y comentario) sobre los productos adquiridos.

🔹 Actividades solicitadas
Identificar las entidades del sistema (Clientes, Productos, Órdenes, etc.).

Determinar atributos clave para cada entidad.

Definir:

Claves primarias (PK)

Claves foráneas (FK)

Cardinalidades y reglas de negocio

Elaborar el modelo entidad–relación (ER).

Transformar el modelo ER a un modelo relacional normalizado (3FN).

🔒 Nota: No se deben incluir sentencias SQL complejas ni procedimientos almacenados en esta etapa de diseño conceptual.

# 🧩 PARTE II – Modelo Dimensional (BI)
🎯 Objetivo
Diseñar un modelo dimensional que permita analizar el desempeño comercial y logístico del supermercado para fines estratégicos.

🔹 Requerimientos analíticos
La gerencia desea responder preguntas como:

¿Cuál es el monto total de ventas por categoría de producto y por mes?

¿Qué proveedores tienen los productos con mayor rotación o mejores calificaciones?

¿Cuál es el ticket promedio de venta por cliente?

¿Qué empleados generan mayor volumen de ventas procesadas?

¿Cuál es la tendencia de ajustes de inventario (pérdidas/mermas) por departamento?

🔹 Actividades solicitadas
Identificar el proceso de negocio a analizar (ej. "Ventas Minoristas" o "Movimientos de Inventario").

Definir la Tabla de Hechos principal (ej. Fact_Ventas).

Identificar las Dimensiones necesarias (Tiempo, Producto, Cliente, Empleado, Proveedor).

Establecer la granularidad del modelo (ej. una fila por línea de producto en el ticket).

Diseñar un Modelo Estrella (Star Schema) que soporte los requerimientos.

