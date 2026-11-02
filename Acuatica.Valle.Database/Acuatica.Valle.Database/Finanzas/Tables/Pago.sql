/*============================================================================================
  Tabla      : Finanzas.Pago
  Descripción: Pago recibido de un alumno (recibo). Un pago puede ser total o a cuenta.
  Atiende    : RFN03 · Pago total / Pago a cuenta
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[Pago]
(
    [PagoId] INT IDENTITY (1, 1) NOT NULL,
    [Folio] VARCHAR(20) CONSTRAINT [DF_Pago_Folio] DEFAULT (CONCAT('P-', RIGHT(CONCAT('0000000', NEXT VALUE FOR [Finanzas].[SeqFolioPago]), 7))) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [FechaPago] DATE NOT NULL,
    [MetodoPagoId] TINYINT NOT NULL,
    [Monto] DECIMAL(10,2) NOT NULL,
    [Referencia] VARCHAR(60) NULL,
    [RecibidoPor] INT NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Pago_Estatus] DEFAULT ('APLICADO') NOT NULL,
    [MotivoCancelacion] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Pago_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Pago] PRIMARY KEY CLUSTERED ([PagoId]),
    CONSTRAINT [UQ_Pago_Folio] UNIQUE ([Folio]),
    CONSTRAINT [FK_Pago_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_Pago_FechaPago] FOREIGN KEY ([FechaPago]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_Pago_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_Pago_RecibidoPor] FOREIGN KEY ([RecibidoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Pago_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Pago_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Pago_Monto] CHECK ([Monto] > 0),
    CONSTRAINT [CK_Pago_Estatus] CHECK ([Estatus] IN ('APLICADO','CANCELADO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_Pago_Fecha]
    ON [Finanzas].[Pago] ([FechaPago])
    INCLUDE ([Monto], [Estatus], [MetodoPagoId]);
GO
CREATE NONCLUSTERED INDEX [IX_Pago_Alumno]
    ON [Finanzas].[Pago] ([AlumnoId], [FechaPago] DESC);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago recibido de un alumno (recibo). Un pago puede ser total o a cuenta.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'PagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Folio del recibo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'Folio';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que cobró.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'RecibidoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
