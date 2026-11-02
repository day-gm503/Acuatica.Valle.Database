/*============================================================================================
  Tabla      : Catalogo.CategoriaGasto
  Descripción: Clasificación de gastos (químicos, mantenimiento, servicios, renta, equipo…). Admite subcategorías.
  Atiende    : Reporte de gastos
============================================================================================*/
CREATE TABLE [Catalogo].[CategoriaGasto]
(
    [CategoriaGastoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [CategoriaPadreId] SMALLINT NULL,
    [Clave] VARCHAR(30) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_CategoriaGasto_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_CategoriaGasto] PRIMARY KEY CLUSTERED ([CategoriaGastoId]),
    CONSTRAINT [UQ_CategoriaGasto_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_CategoriaGasto_CategoriaPadreId] FOREIGN KEY ([CategoriaPadreId]) REFERENCES [Catalogo].[CategoriaGasto] ([CategoriaGastoId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clasificación de gastos (químicos, mantenimiento, servicios, renta, equipo…). Admite subcategorías.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'CategoriaGasto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'CategoriaGasto', @level2type = N'COLUMN', @level2name = N'CategoriaGastoId';
GO
