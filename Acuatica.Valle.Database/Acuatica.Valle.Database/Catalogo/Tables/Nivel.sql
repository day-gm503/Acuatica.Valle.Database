/*============================================================================================
  Tabla      : Catalogo.Nivel
  Descripción: Nivel o grupo de natación (bebés, principiante, intermedio, avanzado, competencia).
  Atiende    : Expansión (grupos por nivel)
============================================================================================*/
CREATE TABLE [Catalogo].[Nivel]
(
    [NivelId] TINYINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(50) NOT NULL,
    [EdadMinima] TINYINT NULL,
    [EdadMaxima] TINYINT NULL,
    [Orden] TINYINT CONSTRAINT [DF_Nivel_Orden] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Nivel_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Nivel] PRIMARY KEY CLUSTERED ([NivelId]),
    CONSTRAINT [UQ_Nivel_Nombre] UNIQUE ([Nombre])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nivel o grupo de natación (bebés, principiante, intermedio, avanzado, competencia).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Nivel';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Nivel', @level2type = N'COLUMN', @level2name = N'NivelId';
GO
