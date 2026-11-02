/*============================================================================================
  Tabla      : Operacion.Mantenimiento
  Descripción: Mantenimientos preventivos/correctivos de la alberca. El costo real se registra en Finanzas.Gasto.
  Atiende    : Mantenimiento de alberca
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[Mantenimiento]
(
    [MantenimientoId] INT IDENTITY (1, 1) NOT NULL,
    [AlbercaId] TINYINT NOT NULL,
    [TipoMantenimientoId] SMALLINT NOT NULL,
    [ProveedorId] INT NULL,
    [ResponsableId] INT NULL,
    [FechaProgramada] DATE NOT NULL,
    [FechaRealizada] DATE NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Mantenimiento_Estatus] DEFAULT ('PROGRAMADO') NOT NULL,
    [Descripcion] NVARCHAR(500) NOT NULL,
    [CostoEstimado] DECIMAL(10,2) NULL,
    [CierraAlberca] BIT CONSTRAINT [DF_Mantenimiento_CierraAlberca] DEFAULT (0) NOT NULL,
    [CierreInicioUtc] DATETIME2(0) NULL,
    [CierreFinUtc] DATETIME2(0) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Mantenimiento_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Mantenimiento] PRIMARY KEY CLUSTERED ([MantenimientoId]),
    CONSTRAINT [FK_Mantenimiento_AlbercaId] FOREIGN KEY ([AlbercaId]) REFERENCES [Operacion].[Alberca] ([AlbercaId]),
    CONSTRAINT [FK_Mantenimiento_TipoMantenimientoId] FOREIGN KEY ([TipoMantenimientoId]) REFERENCES [Catalogo].[TipoMantenimiento] ([TipoMantenimientoId]),
    CONSTRAINT [FK_Mantenimiento_ProveedorId] FOREIGN KEY ([ProveedorId]) REFERENCES [Operacion].[Proveedor] ([ProveedorId]),
    CONSTRAINT [FK_Mantenimiento_ResponsableId] FOREIGN KEY ([ResponsableId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Mantenimiento_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Mantenimiento_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Mantenimiento_Estatus] CHECK ([Estatus] IN ('PROGRAMADO','REALIZADO','CANCELADO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_Mantenimiento_Alberca]
    ON [Operacion].[Mantenimiento] ([AlbercaId], [FechaProgramada])
    INCLUDE ([Estatus]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mantenimientos preventivos/correctivos de la alberca. El costo real se registra en Finanzas.Gasto.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'MantenimientoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario responsable interno.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'ResponsableId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = no hay clases (explica caídas de asistencia).',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'CierraAlberca';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
