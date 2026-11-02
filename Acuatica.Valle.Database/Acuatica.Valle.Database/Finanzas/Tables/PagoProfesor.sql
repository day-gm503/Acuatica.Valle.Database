/*============================================================================================
  Tabla      : Finanzas.PagoProfesor
  Descripción: Pago (nómina) a un profesor por un periodo, calculado de sus clases impartidas.
  Atiende    : RFN06 · Reporte de pagos a maestros
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[PagoProfesor]
(
    [PagoProfesorId] INT IDENTITY (1, 1) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [PeriodoInicio] DATE NOT NULL,
    [PeriodoFin] DATE NOT NULL,
    [HorasTrabajadas] DECIMAL(6,2) NOT NULL,
    [Subtotal] DECIMAL(10,2) NOT NULL,
    [Bonos] DECIMAL(10,2) CONSTRAINT [DF_PagoProfesor_Bonos] DEFAULT (0) NOT NULL,
    [Deducciones] DECIMAL(10,2) CONSTRAINT [DF_PagoProfesor_Deducciones] DEFAULT (0) NOT NULL,
    [Total] DECIMAL(10,2) NOT NULL,
    [FechaPago] DATE NULL,
    [MetodoPagoId] TINYINT NULL,
    [Referencia] VARCHAR(60) NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_PagoProfesor_Estatus] DEFAULT ('BORRADOR') NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_PagoProfesor_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_PagoProfesor] PRIMARY KEY CLUSTERED ([PagoProfesorId]),
    CONSTRAINT [FK_PagoProfesor_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_PagoProfesor_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_PagoProfesor_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_PagoProfesor_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_PagoProfesor_Estatus] CHECK ([Estatus] IN ('BORRADOR','PAGADO','CANCELADO')),
    CONSTRAINT [CK_PagoProfesor_Periodo] CHECK ([PeriodoFin] >= [PeriodoInicio])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PagoProfesor_Periodo]
    ON [Finanzas].[PagoProfesor] ([ProfesorId], [PeriodoInicio], [PeriodoFin])
    WHERE [Estatus] <> 'CANCELADO';
GO
CREATE NONCLUSTERED INDEX [IX_PagoProfesor_FechaPago]
    ON [Finanzas].[PagoProfesor] ([FechaPago])
    INCLUDE ([Total], [Estatus]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago (nómina) a un profesor por un periodo, calculado de sus clases impartidas.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'PagoProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
