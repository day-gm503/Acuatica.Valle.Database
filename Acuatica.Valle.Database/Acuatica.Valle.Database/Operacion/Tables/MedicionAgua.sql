/*============================================================================================
  Tabla      : Operacion.MedicionAgua
  Descripción: Bitácora de calidad del agua (cloro, pH, temperatura).
  Atiende    : Mantenimiento de alberca
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[MedicionAgua]
(
    [MedicionAguaId] INT IDENTITY (1, 1) NOT NULL,
    [AlbercaId] TINYINT NOT NULL,
    [FechaHoraUtc] DATETIME2(0) CONSTRAINT [DF_MedicionAgua_FechaHoraUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CloroLibrePpm] DECIMAL(4,2) NULL,
    [PH] DECIMAL(4,2) NULL,
    [TemperaturaC] DECIMAL(4,1) NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_MedicionAgua_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_MedicionAgua] PRIMARY KEY CLUSTERED ([MedicionAguaId]),
    CONSTRAINT [FK_MedicionAgua_AlbercaId] FOREIGN KEY ([AlbercaId]) REFERENCES [Operacion].[Alberca] ([AlbercaId]),
    CONSTRAINT [FK_MedicionAgua_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_MedicionAgua_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE NONCLUSTERED INDEX [IX_MedicionAgua_Alberca]
    ON [Operacion].[MedicionAgua] ([AlbercaId], [FechaHoraUtc] DESC);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de calidad del agua (cloro, pH, temperatura).',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'MedicionAguaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
