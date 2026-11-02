/*============================================================================================
  Tabla      : Seguridad.Permiso
  Descripción: Acciones permitidas dentro de un módulo (ver, crear, editar, eliminar, exportar…).
  Atiende    : RSN01 · Permiso a funciones
============================================================================================*/
CREATE TABLE [Seguridad].[Permiso]
(
    [PermisoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [ModuloId] SMALLINT NOT NULL,
    [Clave] VARCHAR(60) NOT NULL,
    [Nombre] NVARCHAR(100) NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [Activo] BIT CONSTRAINT [DF_Permiso_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Permiso] PRIMARY KEY CLUSTERED ([PermisoId]),
    CONSTRAINT [UQ_Permiso_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Permiso_ModuloId] FOREIGN KEY ([ModuloId]) REFERENCES [Seguridad].[Modulo] ([ModuloId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Acciones permitidas dentro de un módulo (ver, crear, editar, eliminar, exportar…).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Permiso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Permiso', @level2type = N'COLUMN', @level2name = N'PermisoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. alumnos.ver, alumnos.crear, pagos.registrar, reportes.exportar',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Permiso', @level2type = N'COLUMN', @level2name = N'Clave';
GO
