/*============================================================================================
  Tabla      : Acceso.Dispositivo
  Descripción: Lectores de huella / control de acceso instalados.
  Atiende    : Lector de huella
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Acceso].[Dispositivo]
(
    [DispositivoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [Modelo] NVARCHAR(80) NULL,
    [NumeroSerie] VARCHAR(50) NOT NULL,
    [Ubicacion] NVARCHAR(100) NULL,
    [DireccionIp] VARCHAR(45) NULL,
    [UltimaSincronizacionUtc] DATETIME2(0) NULL,
    [Activo] BIT CONSTRAINT [DF_Dispositivo_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Dispositivo_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Dispositivo] PRIMARY KEY CLUSTERED ([DispositivoId]),
    CONSTRAINT [UQ_Dispositivo_NumeroSerie] UNIQUE ([NumeroSerie]),
    CONSTRAINT [FK_Dispositivo_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Dispositivo_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lectores de huella / control de acceso instalados.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'DispositivoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. Entrada principal.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'Ubicacion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
