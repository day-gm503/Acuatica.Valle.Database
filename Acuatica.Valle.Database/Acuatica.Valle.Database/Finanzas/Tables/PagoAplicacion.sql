/*============================================================================================
  Tabla      : Finanzas.PagoAplicacion
  Descripción: A qué cargo(s) se aplica cada pago. Permite abonos parciales y un pago que cubre varios cargos.
  Atiende    : RFN03
============================================================================================*/
CREATE TABLE [Finanzas].[PagoAplicacion]
(
    [PagoAplicacionId] INT IDENTITY (1, 1) NOT NULL,
    [PagoId] INT NOT NULL,
    [CargoId] INT NOT NULL,
    [MontoAplicado] DECIMAL(10,2) NOT NULL,
    CONSTRAINT [PK_PagoAplicacion] PRIMARY KEY CLUSTERED ([PagoAplicacionId]),
    CONSTRAINT [FK_PagoAplicacion_PagoId] FOREIGN KEY ([PagoId]) REFERENCES [Finanzas].[Pago] ([PagoId]),
    CONSTRAINT [FK_PagoAplicacion_CargoId] FOREIGN KEY ([CargoId]) REFERENCES [Finanzas].[Cargo] ([CargoId]),
    CONSTRAINT [CK_PagoAplicacion_MontoAplicado] CHECK ([MontoAplicado] > 0)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PagoAplicacion]
    ON [Finanzas].[PagoAplicacion] ([PagoId], [CargoId]);
GO
CREATE NONCLUSTERED INDEX [IX_PagoAplicacion_Cargo]
    ON [Finanzas].[PagoAplicacion] ([CargoId])
    INCLUDE ([MontoAplicado]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A qué cargo(s) se aplica cada pago. Permite abonos parciales y un pago que cubre varios cargos.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoAplicacion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoAplicacion', @level2type = N'COLUMN', @level2name = N'PagoAplicacionId';
GO
