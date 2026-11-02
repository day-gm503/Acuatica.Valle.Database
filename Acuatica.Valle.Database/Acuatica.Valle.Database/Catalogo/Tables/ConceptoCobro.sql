/*============================================================================================
  Tabla      : Catalogo.ConceptoCobro
  Descripción: Qué se le cobra al alumno: mensualidad, inscripción, clase suelta, uniforme…
  Atiende    : RFN03 (expansión)
============================================================================================*/
CREATE TABLE [Catalogo].[ConceptoCobro]
(
    [ConceptoCobroId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Clave] VARCHAR(30) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [EsColegiatura] BIT CONSTRAINT [DF_ConceptoCobro_EsColegiatura] DEFAULT (1) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_ConceptoCobro_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_ConceptoCobro] PRIMARY KEY CLUSTERED ([ConceptoCobroId]),
    CONSTRAINT [UQ_ConceptoCobro_Clave] UNIQUE ([Clave])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Qué se le cobra al alumno: mensualidad, inscripción, clase suelta, uniforme…',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'ConceptoCobro';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'ConceptoCobro', @level2type = N'COLUMN', @level2name = N'ConceptoCobroId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = cubre clases (mensualidad / semana / clase).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'ConceptoCobro', @level2type = N'COLUMN', @level2name = N'EsColegiatura';
GO
