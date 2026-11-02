/*============================================================================================
  Tabla      : Catalogo.TipoMantenimiento
  Descripción: Tipos de mantenimiento de la alberca (limpieza, filtros, bomba, calentador, químicos…).
  Atiende    : Mantenimiento de alberca
============================================================================================*/
CREATE TABLE [Catalogo].[TipoMantenimiento]
(
    [TipoMantenimientoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [EsPreventivo] BIT CONSTRAINT [DF_TipoMantenimiento_EsPreventivo] DEFAULT (1) NOT NULL,
    [FrecuenciaDias] SMALLINT NULL,
    [Activo] BIT CONSTRAINT [DF_TipoMantenimiento_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_TipoMantenimiento] PRIMARY KEY CLUSTERED ([TipoMantenimientoId]),
    CONSTRAINT [UQ_TipoMantenimiento_Nombre] UNIQUE ([Nombre])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipos de mantenimiento de la alberca (limpieza, filtros, bomba, calentador, químicos…).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento', @level2type = N'COLUMN', @level2name = N'TipoMantenimientoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 preventivo, 0 correctivo.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento', @level2type = N'COLUMN', @level2name = N'EsPreventivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para programar el siguiente mantenimiento preventivo.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento', @level2type = N'COLUMN', @level2name = N'FrecuenciaDias';
GO
