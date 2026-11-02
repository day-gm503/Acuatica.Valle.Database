/*============================================================================================
  Tabla      : Finanzas.PagoProfesorDetalle
  Descripción: Clases incluidas en cada pago a profesor (una clase solo se paga una vez).
  Atiende    : RFN04 / RFN06
============================================================================================*/
CREATE TABLE [Finanzas].[PagoProfesorDetalle]
(
    [PagoProfesorDetalleId] INT IDENTITY (1, 1) NOT NULL,
    [PagoProfesorId] INT NOT NULL,
    [SesionClaseId] INT NOT NULL,
    [Horas] DECIMAL(4,2) NOT NULL,
    [TarifaHora] DECIMAL(10,2) NOT NULL,
    [Importe] DECIMAL(10,2) NOT NULL,
    CONSTRAINT [PK_PagoProfesorDetalle] PRIMARY KEY CLUSTERED ([PagoProfesorDetalleId]),
    CONSTRAINT [FK_PagoProfesorDetalle_PagoProfesorId] FOREIGN KEY ([PagoProfesorId]) REFERENCES [Finanzas].[PagoProfesor] ([PagoProfesorId]),
    CONSTRAINT [FK_PagoProfesorDetalle_SesionClaseId] FOREIGN KEY ([SesionClaseId]) REFERENCES [Clases].[SesionClase] ([SesionClaseId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PagoProfesorDetalle_Sesion]
    ON [Finanzas].[PagoProfesorDetalle] ([SesionClaseId]);
GO
CREATE NONCLUSTERED INDEX [IX_PagoProfesorDetalle_Pago]
    ON [Finanzas].[PagoProfesorDetalle] ([PagoProfesorId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clases incluidas en cada pago a profesor (una clase solo se paga una vez).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesorDetalle';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesorDetalle', @level2type = N'COLUMN', @level2name = N'PagoProfesorDetalleId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Copia de ProfesorTarifa vigente.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesorDetalle', @level2type = N'COLUMN', @level2name = N'TarifaHora';
GO
