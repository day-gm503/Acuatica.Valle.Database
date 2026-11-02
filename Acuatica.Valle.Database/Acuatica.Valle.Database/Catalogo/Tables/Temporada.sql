/*============================================================================================
  Tabla      : Catalogo.Temporada
  Descripción: Temporadas del negocio (alta, baja, vacaciones de verano, decembrina…).
  Atiende    : Reporte de temporadas bajas
============================================================================================*/
CREATE TABLE [Catalogo].[Temporada]
(
    [TemporadaId] TINYINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(50) NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [Color] CHAR(7) NULL,
    CONSTRAINT [PK_Temporada] PRIMARY KEY CLUSTERED ([TemporadaId]),
    CONSTRAINT [UQ_Temporada_Nombre] UNIQUE ([Nombre])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Temporadas del negocio (alta, baja, vacaciones de verano, decembrina…).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Temporada';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Temporada', @level2type = N'COLUMN', @level2name = N'TemporadaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'#RRGGBB para gráficas.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Temporada', @level2type = N'COLUMN', @level2name = N'Color';
GO
