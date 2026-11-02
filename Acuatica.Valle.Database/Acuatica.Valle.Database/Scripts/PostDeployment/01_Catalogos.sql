/*============================================================================================
  Datos iniciales · Catálogos
  Idempotente: solo inserta lo que falta. Nunca sobrescribe cambios hechos desde el sistema.
============================================================================================*/
PRINT N'Catálogos...';

-- Tipos de periodo de pago (llave fija, sin IDENTITY: la aplicación puede referirlos por Id).
MERGE [Catalogo].[TipoPeriodoPago] AS t
USING (VALUES
    (CAST(1 AS TINYINT), 'CLASE',     N'Por clase',  CAST(1  AS SMALLINT), CAST(1 AS TINYINT)),
    (2,                  'SEMANAL',   N'Semanal',    7,                    2),
    (3,                  'QUINCENAL', N'Quincenal',  15,                   3),
    (4,                  'MENSUAL',   N'Mensual',    NULL,                 4)  -- NULL = mes calendario
) AS s (TipoPeriodoPagoId, Clave, Nombre, DiasDuracion, Orden)
ON t.[TipoPeriodoPagoId] = s.TipoPeriodoPagoId
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([TipoPeriodoPagoId], [Clave], [Nombre], [DiasDuracion], [Orden])
    VALUES (s.TipoPeriodoPagoId, s.Clave, s.Nombre, s.DiasDuracion, s.Orden);

-- Métodos de pago (llave fija).
MERGE [Catalogo].[MetodoPago] AS t
USING (VALUES
    (CAST(1 AS TINYINT), 'EFECTIVO',      N'Efectivo',      CAST(0 AS BIT)),
    (2,                  'TRANSFERENCIA', N'Transferencia', 1),
    (3,                  'TARJETA',       N'Tarjeta',       1)
) AS s (MetodoPagoId, Clave, Nombre, RequiereReferencia)
ON t.[MetodoPagoId] = s.MetodoPagoId
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([MetodoPagoId], [Clave], [Nombre], [RequiereReferencia])
    VALUES (s.MetodoPagoId, s.Clave, s.Nombre, s.RequiereReferencia);

-- Conceptos de cobro.
MERGE [Catalogo].[ConceptoCobro] AS t
USING (VALUES
    ('COLEGIATURA',  N'Colegiatura (semana, quincena o mes)', CAST(1 AS BIT)),
    ('CLASE_SUELTA', N'Clase suelta',                          1),
    ('INSCRIPCION',  N'Inscripción',                           0),
    ('UNIFORME',     N'Uniforme / material',                   0)
) AS s (Clave, Nombre, EsColegiatura)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre], [EsColegiatura]) VALUES (s.Clave, s.Nombre, s.EsColegiatura);

-- Niveles de natación.
MERGE [Catalogo].[Nivel] AS t
USING (VALUES
    (N'Bebés',        CAST(0 AS TINYINT), CAST(3 AS TINYINT), CAST(1 AS TINYINT)),
    (N'Principiante', NULL,               NULL,               2),
    (N'Intermedio',   NULL,               NULL,               3),
    (N'Avanzado',     NULL,               NULL,               4),
    (N'Competencia',  NULL,               NULL,               5)
) AS s (Nombre, EdadMinima, EdadMaxima, Orden)
ON t.[Nombre] = s.Nombre
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Nombre], [EdadMinima], [EdadMaxima], [Orden]) VALUES (s.Nombre, s.EdadMinima, s.EdadMaxima, s.Orden);

-- Categorías de gasto (la nómina de profesores NO es gasto: vive en Finanzas.PagoProfesor).
MERGE [Catalogo].[CategoriaGasto] AS t
USING (VALUES
    ('QUIMICOS',      N'Químicos'),
    ('MANTENIMIENTO', N'Mantenimiento'),
    ('SERVICIOS',     N'Servicios (luz, agua, gas, internet)'),
    ('RENTA',         N'Renta'),
    ('EQUIPO',        N'Equipo y material'),
    ('OTROS',         N'Otros')
) AS s (Clave, Nombre)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre]) VALUES (s.Clave, s.Nombre);

-- Tipos de mantenimiento de la alberca (FrecuenciaDias programa el siguiente preventivo).
MERGE [Catalogo].[TipoMantenimiento] AS t
USING (VALUES
    (N'Limpieza general',          CAST(1 AS BIT), CAST(7   AS SMALLINT)),
    (N'Balanceo químico',          1,              7),
    (N'Retrolavado de filtros',    1,              14),
    (N'Revisión de bomba',         1,              90),
    (N'Revisión de calentador',    1,              180),
    (N'Reparación correctiva',     0,              NULL)
) AS s (Nombre, EsPreventivo, FrecuenciaDias)
ON t.[Nombre] = s.Nombre
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Nombre], [EsPreventivo], [FrecuenciaDias]) VALUES (s.Nombre, s.EsPreventivo, s.FrecuenciaDias);

-- Temporadas (qué meses son alta o baja está pendiente de confirmar con el cliente;
-- se asignan en Reporte.Calendario.TemporadaId cuando se definan).
MERGE [Catalogo].[Temporada] AS t
USING (VALUES
    (N'Temporada alta',        N'Meses de mayor inscripción.',            '#2E7D32'),
    (N'Temporada baja',        N'Meses de menor inscripción.',            '#C62828'),
    (N'Vacaciones de verano',  N'Cursos de verano.',                      '#F9A825'),
    (N'Temporada decembrina',  N'Vacaciones de diciembre y año nuevo.',   '#1565C0')
) AS s (Nombre, Descripcion, Color)
ON t.[Nombre] = s.Nombre
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Nombre], [Descripcion], [Color]) VALUES (s.Nombre, s.Descripcion, s.Color);

-- Alberca principal (una sola sede; se pueden agregar más albercas).
IF NOT EXISTS (SELECT 1 FROM [Operacion].[Alberca])
    INSERT INTO [Operacion].[Alberca] ([Nombre]) VALUES (N'Alberca principal');
