/*============================================================================================
  Tabla      : Finanzas.Cargo
  Descripción: Lo que el alumno debe por un periodo (cuenta por cobrar). Total = clases reales del periodo × precio por clase. El saldo determina Pagado / Pago a cuenta / Pendiente.
  Atiende    : RFN03 / RFN05 · Información de pago, Adeudos, Pagos por vencer
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Finanzas].[Cargo]
(
    [CargoId] INT IDENTITY (1, 1) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [ConceptoCobroId] SMALLINT NOT NULL,
    [TarifaId] SMALLINT NULL,
    [TipoPeriodoPagoId] TINYINT NOT NULL,
    [PeriodoInicio] DATE NOT NULL,
    [PeriodoFin] DATE NOT NULL,
    [ClasesEnPeriodo] SMALLINT NOT NULL,
    [PrecioUnitario] DECIMAL(10,2) NOT NULL,
    [Subtotal] DECIMAL(10,2) NOT NULL,
    [Descuento] DECIMAL(10,2) CONSTRAINT [DF_Cargo_Descuento] DEFAULT (0) NOT NULL,
    [Total] DECIMAL(10,2) NOT NULL,
    [MontoPagado] DECIMAL(10,2) CONSTRAINT [DF_Cargo_MontoPagado] DEFAULT (0) NOT NULL,
    [Saldo] AS (CAST([Total] - [MontoPagado] AS DECIMAL(10,2))) PERSISTED NOT NULL,
    [FechaVencimiento] DATE NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Cargo_Estatus] DEFAULT ('PENDIENTE') NOT NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Cargo_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cargo] PRIMARY KEY CLUSTERED ([CargoId]),
    CONSTRAINT [FK_Cargo_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_Cargo_ConceptoCobroId] FOREIGN KEY ([ConceptoCobroId]) REFERENCES [Catalogo].[ConceptoCobro] ([ConceptoCobroId]),
    CONSTRAINT [FK_Cargo_TarifaId] FOREIGN KEY ([TarifaId]) REFERENCES [Finanzas].[Tarifa] ([TarifaId]),
    CONSTRAINT [FK_Cargo_TipoPeriodoPagoId] FOREIGN KEY ([TipoPeriodoPagoId]) REFERENCES [Catalogo].[TipoPeriodoPago] ([TipoPeriodoPagoId]),
    CONSTRAINT [FK_Cargo_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Cargo_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Cargo_Estatus] CHECK ([Estatus] IN ('PENDIENTE','PARCIAL','PAGADO','CANCELADO')),
    CONSTRAINT [CK_Cargo_Periodo] CHECK ([PeriodoFin] >= [PeriodoInicio]),
    CONSTRAINT [CK_Cargo_Montos] CHECK ([Total] >= 0 AND [Descuento] >= 0 AND [MontoPagado] >= 0 AND [MontoPagado] <= [Total])
);
GO
CREATE NONCLUSTERED INDEX [IX_Cargo_Alumno]
    ON [Finanzas].[Cargo] ([AlumnoId], [PeriodoInicio] DESC)
    INCLUDE ([Estatus], [Saldo]);
GO
CREATE NONCLUSTERED INDEX [IX_Cargo_Pendientes]
    ON [Finanzas].[Cargo] ([FechaVencimiento])
    INCLUDE ([AlumnoId], [Saldo], [PeriodoFin])
    WHERE [Estatus] IN ('PENDIENTE','PARCIAL');
GO
CREATE NONCLUSTERED INDEX [IX_Cargo_PeriodoFin]
    ON [Finanzas].[Cargo] ([PeriodoFin])
    INCLUDE ([AlumnoId], [Estatus]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lo que el alumno debe por un periodo (cuenta por cobrar). Total = clases reales del periodo × precio por clase. El saldo determina Pagado / Pago a cuenta / Pendiente.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'CargoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de inicio de pago.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'PeriodoInicio';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de fin de pago.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'PeriodoFin';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clases reales que cubre (filas en CargoClase).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'ClasesEnPeriodo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio por clase copiado al momento del cargo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'PrecioUnitario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo total.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'Total';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lo mantiene el SP de pagos dentro de la transacción.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'MontoPagado';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Calculada y persistida.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'Saldo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PENDIENTE=Pendiente, PARCIAL=Pago a cuenta, PAGADO=Pagado.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'Estatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'RowVer';
GO
