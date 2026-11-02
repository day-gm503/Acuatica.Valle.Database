/*============================================================================================
  Tabla      : Catalogo.TipoPeriodoPago
  Descripción: Por clase, semanal, quincenal o mensual.
  Atiende    : RFN03 · Tipo de pago
============================================================================================*/
CREATE TABLE [Catalogo].[TipoPeriodoPago]
(
    [TipoPeriodoPagoId] TINYINT NOT NULL,
    [Clave] VARCHAR(20) NOT NULL,
    [Nombre] NVARCHAR(40) NOT NULL,
    [DiasDuracion] SMALLINT NULL,
    [Orden] TINYINT CONSTRAINT [DF_TipoPeriodoPago_Orden] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_TipoPeriodoPago_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_TipoPeriodoPago] PRIMARY KEY CLUSTERED ([TipoPeriodoPagoId]),
    CONSTRAINT [UQ_TipoPeriodoPago_Clave] UNIQUE ([Clave])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Por clase, semanal, quincenal o mensual.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago', @level2type = N'COLUMN', @level2name = N'TipoPeriodoPagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CLASE, SEMANAL, QUINCENAL, MENSUAL',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1, 7, 15 o NULL = mes calendario. Solo propone la fecha de fin; el cobro sale de las clases reales del periodo.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago', @level2type = N'COLUMN', @level2name = N'DiasDuracion';
GO
