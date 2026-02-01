USE bd_pedan6_dw;
GO

-- =============================================================================
-- STORED PROCEDURE: Poblar Dimensión Tiempo
-- Autor: Data Architect Lead
-- Uso: Ejecutar desde SSIS 'Execute SQL Task' o manualmente.
-- =============================================================================

IF OBJECT_ID('sp_PoblarDimTiempo', 'P') IS NOT NULL
    DROP PROCEDURE sp_PoblarDimTiempo;
GO

CREATE PROCEDURE sp_PoblarDimTiempo
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Limpiamos la tabla antes de llenarla (Carga Total)
    TRUNCATE TABLE DimTiempo;

    DECLARE @FechaActual DATE = @FechaInicio;

    WHILE @FechaActual <= @FechaFin
    BEGIN
        INSERT INTO DimTiempo (
            DateKey,
            Fecha,
            Anio,
            Trimestre,
            Mes,
            NombreMes,
            DiaDeSemana,
            NombreDia,
            EsFinDeSemana
        )
        SELECT 
            -- DateKey: 20251115 (INT)
            CAST(CONVERT(VARCHAR(8), @FechaActual, 112) AS INT),
            
            -- Fecha
            @FechaActual,
            
            -- Año
            YEAR(@FechaActual),
            
            -- Trimestre
            DATEPART(QUARTER, @FechaActual),
            
            -- Mes
            MONTH(@FechaActual),
            
            -- NombreMes (Español)
            CASE MONTH(@FechaActual)
                WHEN 1 THEN 'Enero' WHEN 2 THEN 'Febrero' WHEN 3 THEN 'Marzo'
                WHEN 4 THEN 'Abril' WHEN 5 THEN 'Mayo' WHEN 6 THEN 'Junio'
                WHEN 7 THEN 'Julio' WHEN 8 THEN 'Agosto' WHEN 9 THEN 'Septiembre'
                WHEN 10 THEN 'Octubre' WHEN 11 THEN 'Noviembre' WHEN 12 THEN 'Diciembre'
            END,
            
            -- DiaDeSemana (SQL por defecto Domingo=1, Lunes=2... ajustamos si es necesario)
            DATEPART(WEEKDAY, @FechaActual),
            
            -- NombreDia (Español)
            DATENAME(WEEKDAY, @FechaActual),
            
            -- EsFinDeSemana (1 si es Sábado o Domingo)
            CASE WHEN DATEPART(WEEKDAY, @FechaActual) IN (1, 7) THEN 1 ELSE 0 END;

        SET @FechaActual = DATEADD(DAY, 1, @FechaActual);
    END
END;
GO

-- PRUEBA (Esto es lo que pondrás en SSIS):
-- EXEC sp_PoblarDimTiempo '2025-01-01', '2030-12-31';