/*============================================================================================
  Tabla      : Operacion.Alberca
  Descripción: Albercas / instalaciones de la escuela.
  Atiende    : Mantenimiento de alberca
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[Alberca]
(
    [AlbercaId] TINYINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [NumeroCarriles] TINYINT NULL,
    [CapacidadMaxima] SMALLINT NULL,
    [VolumenLitros] INT NULL,
    [ProfundidadMinM] DECIMAL(3,2) NULL,
    [ProfundidadMaxM] DECIMAL(3,2) NULL,
    [Activa] BIT CONSTRAINT [DF_Alberca_Activa] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Alberca_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Alberca] PRIMARY KEY CLUSTERED ([AlbercaId]),
    CONSTRAINT [UQ_Alberca_Nombre] UNIQUE ([Nombre]),
    CONSTRAINT [FK_Alberca_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Alberca_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Albercas / instalaciones de la escuela.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'AlbercaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Personas simultáneas.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'CapacidadMaxima';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para dosificar químicos.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'VolumenLitros';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
