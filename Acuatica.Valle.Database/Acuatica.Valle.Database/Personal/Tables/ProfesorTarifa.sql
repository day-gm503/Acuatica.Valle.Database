/*============================================================================================
  Tabla      : Personal.ProfesorTarifa
  Descripción: Pago por hora del profesor con vigencia (historial de aumentos).
  Atiende    : RFN04 · Pago por horas
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Personal].[ProfesorTarifa]
(
    [ProfesorTarifaId] INT IDENTITY (1, 1) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [MontoPorHora] DECIMAL(10,2) NOT NULL,
    [VigenteDesde] DATE NOT NULL,
    [VigenteHasta] DATE NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_ProfesorTarifa_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_ProfesorTarifa] PRIMARY KEY CLUSTERED ([ProfesorTarifaId]),
    CONSTRAINT [FK_ProfesorTarifa_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_ProfesorTarifa_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_ProfesorTarifa_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_ProfesorTarifa_MontoPorHora] CHECK ([MontoPorHora] >= 0),
    CONSTRAINT [CK_ProfesorTarifa_Vigencia] CHECK ([VigenteHasta] IS NULL OR [VigenteHasta] >= [VigenteDesde])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ProfesorTarifa_Vigencia]
    ON [Personal].[ProfesorTarifa] ([ProfesorId], [VigenteDesde]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago por hora del profesor con vigencia (historial de aumentos).',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'ProfesorTarifaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = vigente.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'VigenteHasta';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
