/*============================================================================================
  Tabla      : Finanzas.Tarifa
  Descripción: Precio por clase (1 hora) con vigencia. Puede variar por tipo de periodo (clase suelta vs. mensualidad) y nivel.
  Atiende    : RFN03 · Tarifa por horario de clase
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[Tarifa]
(
    [TarifaId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [ConceptoCobroId] SMALLINT NOT NULL,
    [TipoPeriodoPagoId] TINYINT NULL,
    [NivelId] TINYINT NULL,
    [PrecioPorClase] DECIMAL(10,2) NOT NULL,
    [VigenteDesde] DATE NOT NULL,
    [VigenteHasta] DATE NULL,
    [Activo] BIT CONSTRAINT [DF_Tarifa_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Tarifa_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Tarifa] PRIMARY KEY CLUSTERED ([TarifaId]),
    CONSTRAINT [FK_Tarifa_ConceptoCobroId] FOREIGN KEY ([ConceptoCobroId]) REFERENCES [Catalogo].[ConceptoCobro] ([ConceptoCobroId]),
    CONSTRAINT [FK_Tarifa_TipoPeriodoPagoId] FOREIGN KEY ([TipoPeriodoPagoId]) REFERENCES [Catalogo].[TipoPeriodoPago] ([TipoPeriodoPagoId]),
    CONSTRAINT [FK_Tarifa_NivelId] FOREIGN KEY ([NivelId]) REFERENCES [Catalogo].[Nivel] ([NivelId]),
    CONSTRAINT [FK_Tarifa_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Tarifa_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Tarifa_PrecioPorClase] CHECK ([PrecioPorClase] >= 0)
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio por clase (1 hora) con vigencia. Puede variar por tipo de periodo (clase suelta vs. mensualidad) y nivel.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'TarifaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. Clase suelta, Mensualidad.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'Nombre';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = aplica a cualquier periodo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'TipoPeriodoPagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio distinto por nivel (opcional).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'NivelId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de una clase de 1 hora. Ej. 70.00',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'PrecioPorClase';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
