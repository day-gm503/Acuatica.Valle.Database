/*============================================================================================
  Tabla      : Seguridad.UsuarioRol
  Descripción: Roles asignados a cada usuario (N:M).
  Atiende    : RSN01 · Tipo de usuario
============================================================================================*/
CREATE TABLE [Seguridad].[UsuarioRol]
(
    [UsuarioId] INT NOT NULL,
    [RolId] SMALLINT NOT NULL,
    [FechaAsignacionUtc] DATETIME2(0) CONSTRAINT [DF_UsuarioRol_FechaAsignacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [AsignadoPor] INT NULL,
    CONSTRAINT [PK_UsuarioRol] PRIMARY KEY CLUSTERED ([UsuarioId], [RolId]),
    CONSTRAINT [FK_UsuarioRol_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_UsuarioRol_RolId] FOREIGN KEY ([RolId]) REFERENCES [Seguridad].[Rol] ([RolId]),
    CONSTRAINT [FK_UsuarioRol_AsignadoPor] FOREIGN KEY ([AsignadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Roles asignados a cada usuario (N:M).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'UsuarioRol';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'UsuarioRol', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'UsuarioRol', @level2type = N'COLUMN', @level2name = N'RolId';
GO
