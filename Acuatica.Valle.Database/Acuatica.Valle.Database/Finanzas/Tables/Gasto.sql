/*============================================================================================
  Tabla      : Finanzas.Gasto
  Descripción: Salidas de dinero que no son nómina: químicos, mantenimiento, servicios, renta, equipo…
  Atiende    : Gastos / mantenimiento
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[Gasto]
(
    [GastoId] INT IDENTITY (1, 1) NOT NULL,
    [CategoriaGastoId] SMALLINT NOT NULL,
    [ProveedorId] INT NULL,
    [MantenimientoId] INT NULL,
    [FechaGasto] DATE NOT NULL,
    [Concepto] NVARCHAR(200) NOT NULL,
    [Monto] DECIMAL(10,2) NOT NULL,
    [MetodoPagoId] TINYINT NOT NULL,
    [FolioFactura] VARCHAR(60) NULL,
    [ComprobanteUrl] VARCHAR(300) NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Gasto_Estatus] DEFAULT ('APLICADO') NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Gasto_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Gasto] PRIMARY KEY CLUSTERED ([GastoId]),
    CONSTRAINT [FK_Gasto_CategoriaGastoId] FOREIGN KEY ([CategoriaGastoId]) REFERENCES [Catalogo].[CategoriaGasto] ([CategoriaGastoId]),
    CONSTRAINT [FK_Gasto_ProveedorId] FOREIGN KEY ([ProveedorId]) REFERENCES [Operacion].[Proveedor] ([ProveedorId]),
    CONSTRAINT [FK_Gasto_MantenimientoId] FOREIGN KEY ([MantenimientoId]) REFERENCES [Operacion].[Mantenimiento] ([MantenimientoId]),
    CONSTRAINT [FK_Gasto_FechaGasto] FOREIGN KEY ([FechaGasto]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_Gasto_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_Gasto_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Gasto_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Gasto_Monto] CHECK ([Monto] > 0),
    CONSTRAINT [CK_Gasto_Estatus] CHECK ([Estatus] IN ('APLICADO','CANCELADO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_Gasto_Fecha]
    ON [Finanzas].[Gasto] ([FechaGasto])
    INCLUDE ([CategoriaGastoId], [Monto], [Estatus]);
GO
CREATE NONCLUSTERED INDEX [IX_Gasto_Mantenimiento]
    ON [Finanzas].[Gasto] ([MantenimientoId])
    WHERE [MantenimientoId] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Salidas de dinero que no son nómina: químicos, mantenimiento, servicios, renta, equipo…',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'GastoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el gasto es de un mantenimiento.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'MantenimientoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
