/*============================================================================================
  Tabla      : Seguridad.Rol
  Descripción: Roles del sistema (Administrador, Recepción, Profesor…).
  Atiende    : RSN01 · Roles
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Seguridad].[Rol]
(
    [RolId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Clave] VARCHAR(30) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [EsSistema] BIT CONSTRAINT [DF_Rol_EsSistema] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Rol_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Rol_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Rol] PRIMARY KEY CLUSTERED ([RolId]),
    CONSTRAINT [UQ_Rol_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Rol_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Rol_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Roles del sistema (Administrador, Recepción, Profesor…).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'RolId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ADMIN, RECEPCION, PROFESOR…',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = no se puede borrar ni renombrar desde la UI.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'EsSistema';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
