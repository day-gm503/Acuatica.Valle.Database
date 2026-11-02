/*============================================================================================
  Tabla      : Seguridad.Modulo
  Descripción: Módulos / secciones del menú (Dashboard, Control de alumnos, Calendario, Reportes, Configuración).
  Atiende    : RSN01 · Permiso a módulos
============================================================================================*/
CREATE TABLE [Seguridad].[Modulo]
(
    [ModuloId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [ModuloPadreId] SMALLINT NULL,
    [Clave] VARCHAR(40) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [Ruta] VARCHAR(120) NULL,
    [Icono] VARCHAR(50) NULL,
    [Orden] TINYINT CONSTRAINT [DF_Modulo_Orden] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Modulo_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Modulo] PRIMARY KEY CLUSTERED ([ModuloId]),
    CONSTRAINT [UQ_Modulo_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Modulo_ModuloPadreId] FOREIGN KEY ([ModuloPadreId]) REFERENCES [Seguridad].[Modulo] ([ModuloId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Módulos / secciones del menú (Dashboard, Control de alumnos, Calendario, Reportes, Configuración).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'ModuloId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para submenús.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'ModuloPadreId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DASHBOARD, ALUMNOS, CALENDARIO, REPORTES, CONFIGURACION',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ruta del front (/alumnos).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'Ruta';
GO
