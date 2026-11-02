/*============================================================================================
  Tabla      : Finanzas.MovimientoCaja
  Descripción: Libro único de entradas y salidas de dinero. Cada pago, pago a profesor o gasto genera su movimiento.
  Atiende    : Entradas y salidas / Reporte de ganancias
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[MovimientoCaja]
(
    [MovimientoCajaId] BIGINT IDENTITY (1, 1) NOT NULL,
    [FechaMovimiento] DATE NOT NULL,
    [Tipo] VARCHAR(7) NOT NULL,
    [Origen] VARCHAR(13) NOT NULL,
    [PagoId] INT NULL,
    [PagoProfesorId] INT NULL,
    [GastoId] INT NULL,
    [MetodoPagoId] TINYINT NOT NULL,
    [Monto] DECIMAL(10,2) NOT NULL,
    [Concepto] NVARCHAR(200) NOT NULL,
    [EsReverso] BIT CONSTRAINT [DF_MovimientoCaja_EsReverso] DEFAULT (0) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_MovimientoCaja_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_MovimientoCaja] PRIMARY KEY CLUSTERED ([MovimientoCajaId]),
    CONSTRAINT [FK_MovimientoCaja_FechaMovimiento] FOREIGN KEY ([FechaMovimiento]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_MovimientoCaja_PagoId] FOREIGN KEY ([PagoId]) REFERENCES [Finanzas].[Pago] ([PagoId]),
    CONSTRAINT [FK_MovimientoCaja_PagoProfesorId] FOREIGN KEY ([PagoProfesorId]) REFERENCES [Finanzas].[PagoProfesor] ([PagoProfesorId]),
    CONSTRAINT [FK_MovimientoCaja_GastoId] FOREIGN KEY ([GastoId]) REFERENCES [Finanzas].[Gasto] ([GastoId]),
    CONSTRAINT [FK_MovimientoCaja_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_MovimientoCaja_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_MovimientoCaja_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_MovimientoCaja_Tipo] CHECK ([Tipo] IN ('ENTRADA','SALIDA')),
    CONSTRAINT [CK_MovimientoCaja_OrigenValido] CHECK ([Origen] IN ('PAGO_ALUMNO','PAGO_PROFESOR','GASTO','AJUSTE')),
    CONSTRAINT [CK_MovimientoCaja_Monto] CHECK ([Monto] > 0),
    CONSTRAINT [CK_MovimientoCaja_Origen] CHECK (([Origen] = 'PAGO_ALUMNO' AND [PagoId] IS NOT NULL AND [PagoProfesorId] IS NULL AND [GastoId] IS NULL) OR ([Origen] = 'PAGO_PROFESOR' AND [PagoProfesorId] IS NOT NULL AND [PagoId] IS NULL AND [GastoId] IS NULL) OR ([Origen] = 'GASTO' AND [GastoId] IS NOT NULL AND [PagoId] IS NULL AND [PagoProfesorId] IS NULL) OR ([Origen] = 'AJUSTE' AND [PagoId] IS NULL AND [PagoProfesorId] IS NULL AND [GastoId] IS NULL))
);
GO
CREATE NONCLUSTERED INDEX [IX_MovimientoCaja_Fecha]
    ON [Finanzas].[MovimientoCaja] ([FechaMovimiento], [Tipo])
    INCLUDE ([Monto], [Origen]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Libro único de entradas y salidas de dinero. Cada pago, pago a profesor o gasto genera su movimiento.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'MovimientoCajaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Siempre positivo; el signo lo da Tipo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'Monto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = contrapartida de una cancelación (no se borra nada).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'EsReverso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
