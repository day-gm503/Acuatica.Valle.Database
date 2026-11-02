/*============================================================================================
  Tabla      : Seguridad.RolPermiso
  Descripción: Permisos otorgados a cada rol (N:M).
  Atiende    : RSN01
============================================================================================*/
CREATE TABLE [Seguridad].[RolPermiso]
(
    [RolId] SMALLINT NOT NULL,
    [PermisoId] SMALLINT NOT NULL,
    [FechaAsignacionUtc] DATETIME2(0) CONSTRAINT [DF_RolPermiso_FechaAsignacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [AsignadoPor] INT NULL,
    CONSTRAINT [PK_RolPermiso] PRIMARY KEY CLUSTERED ([RolId], [PermisoId]),
    CONSTRAINT [FK_RolPermiso_RolId] FOREIGN KEY ([RolId]) REFERENCES [Seguridad].[Rol] ([RolId]),
    CONSTRAINT [FK_RolPermiso_PermisoId] FOREIGN KEY ([PermisoId]) REFERENCES [Seguridad].[Permiso] ([PermisoId]),
    CONSTRAINT [FK_RolPermiso_AsignadoPor] FOREIGN KEY ([AsignadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Permisos otorgados a cada rol (N:M).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'RolPermiso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'RolPermiso', @level2type = N'COLUMN', @level2name = N'RolId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'RolPermiso', @level2type = N'COLUMN', @level2name = N'PermisoId';
GO
