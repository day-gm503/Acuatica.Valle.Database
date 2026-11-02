/*============================================================================================
  Tabla      : Catalogo.MetodoPago
  Descripción: Forma de pago: efectivo, transferencia, tarjeta…
  Atiende    : RFN03
============================================================================================*/
CREATE TABLE [Catalogo].[MetodoPago]
(
    [MetodoPagoId] TINYINT NOT NULL,
    [Clave] VARCHAR(20) NOT NULL,
    [Nombre] NVARCHAR(40) NOT NULL,
    [RequiereReferencia] BIT CONSTRAINT [DF_MetodoPago_RequiereReferencia] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_MetodoPago_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_MetodoPago] PRIMARY KEY CLUSTERED ([MetodoPagoId]),
    CONSTRAINT [UQ_MetodoPago_Clave] UNIQUE ([Clave])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Forma de pago: efectivo, transferencia, tarjeta…',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'MetodoPago';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'MetodoPago', @level2type = N'COLUMN', @level2name = N'MetodoPagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Transferencia/tarjeta exigen número de referencia.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'MetodoPago', @level2type = N'COLUMN', @level2name = N'RequiereReferencia';
GO
