/*============================================================================================
  Datos iniciales · Reporte.Calendario
  Un renglón por día. Las fechas de SesionClase, CargoClase, Pago, Gasto y MovimientoCaja son
  llave foránea a esta tabla, así que el rango debe cubrir toda la operación.

  - Solo inserta los días que faltan: los cambios hechos a mano (días cerrados, temporadas,
    festivos locales) no se sobrescriben en un nuevo despliegue.
  - No depende de SET LANGUAGE ni de @@DATEFIRST: DiaSemana es ISO (1 = lunes … 7 = domingo).
  - Festivos oficiales (Ley Federal del Trabajo, art. 74). El 1 de octubre de cada 6 años
    (transmisión del Poder Ejecutivo) se incluye (2024, 2030).
  - EsDiaOperativo = 0 en festivos y, mientras el cliente no confirme qué días abre, en domingo
    (cambiar @DomingoOperativo a 1 si abren en domingo).
============================================================================================*/
PRINT N'Calendario...';

DECLARE @Desde            DATE = '20240101';
DECLARE @Hasta            DATE = '20351231';
DECLARE @DomingoOperativo BIT  = 0;

WITH Numeros AS
(
    SELECT TOP (DATEDIFF(DAY, @Desde, @Hasta) + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
),
Dias AS
(
    SELECT d.Fecha,
           CAST(DATEDIFF(DAY, '19000101', d.Fecha) % 7 + 1 AS TINYINT) AS DiaSemana   -- 1900-01-01 fue lunes
    FROM Numeros
    CROSS APPLY (SELECT DATEADD(DAY, n, @Desde) AS Fecha) AS d
),
Base AS
(
    SELECT Fecha, DiaSemana,
           MONTH(Fecha) AS Mes,
           DAY(Fecha)   AS Dia,
           CASE
               WHEN MONTH(Fecha) = 1  AND DAY(Fecha) = 1                                   THEN N'Año Nuevo'
               WHEN MONTH(Fecha) = 2  AND DiaSemana = 1 AND DAY(Fecha) <= 7                 THEN N'Día de la Constitución'
               WHEN MONTH(Fecha) = 3  AND DiaSemana = 1 AND DAY(Fecha) BETWEEN 15 AND 21    THEN N'Natalicio de Benito Juárez'
               WHEN MONTH(Fecha) = 5  AND DAY(Fecha) = 1                                   THEN N'Día del Trabajo'
               WHEN MONTH(Fecha) = 9  AND DAY(Fecha) = 16                                  THEN N'Día de la Independencia'
               WHEN MONTH(Fecha) = 10 AND DAY(Fecha) = 1 AND (YEAR(Fecha) - 2024) % 6 = 0  THEN N'Transmisión del Poder Ejecutivo'
               WHEN MONTH(Fecha) = 11 AND DiaSemana = 1 AND DAY(Fecha) BETWEEN 15 AND 21    THEN N'Día de la Revolución'
               WHEN MONTH(Fecha) = 12 AND DAY(Fecha) = 25                                  THEN N'Navidad'
           END AS Feriado
    FROM Dias
)
INSERT INTO [Reporte].[Calendario]
    ([Fecha], [Anio], [Mes], [NombreMes], [Trimestre], [SemanaAnio], [SemanaMes], [DiaSemana], [NombreDia],
     [EsFinDeSemana], [EsFeriado], [DescripcionFeriado], [EsDiaOperativo], [TemporadaId])
SELECT b.Fecha,
       YEAR(b.Fecha),
       b.Mes,
       CHOOSE(b.Mes, N'Enero', N'Febrero', N'Marzo', N'Abril', N'Mayo', N'Junio', N'Julio',
                     N'Agosto', N'Septiembre', N'Octubre', N'Noviembre', N'Diciembre'),
       DATEPART(QUARTER, b.Fecha),
       DATEPART(ISO_WEEK, b.Fecha),
       (b.Dia - 1) / 7 + 1,
       b.DiaSemana,
       CHOOSE(b.DiaSemana, N'Lunes', N'Martes', N'Miércoles', N'Jueves', N'Viernes', N'Sábado', N'Domingo'),
       CASE WHEN b.DiaSemana IN (6, 7) THEN 1 ELSE 0 END,
       CASE WHEN b.Feriado IS NULL THEN 0 ELSE 1 END,
       b.Feriado,
       CASE WHEN b.Feriado IS NOT NULL THEN 0
            WHEN b.DiaSemana = 7 AND @DomingoOperativo = 0 THEN 0
            ELSE 1 END,
       NULL
FROM Base AS b
WHERE NOT EXISTS (SELECT 1 FROM [Reporte].[Calendario] AS c WHERE c.[Fecha] = b.Fecha);
