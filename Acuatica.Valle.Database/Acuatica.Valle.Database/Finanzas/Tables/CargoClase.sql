/*============================================================================================
  Tabla      : Finanzas.CargoClase
  Descripción: Cada clase (fecha y hora) que cubre un cargo. Permite cobrar por clase, 2 horas seguidas el mismo día o el mes según los días reales.
  Atiende    : Cobro por clase / días reales
============================================================================================*/
CREATE TABLE [Finanzas].[CargoClase]
(
    [CargoClaseId] INT IDENTITY (1, 1) NOT NULL,
    [CargoId] INT NOT NULL,
    [Fecha] DATE NOT NULL,
    [ClaseHorarioId] INT NULL,
    [SesionClaseId] INT NULL,
    [Importe] DECIMAL(10,2) NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_CargoClase_Estatus] DEFAULT ('ACTIVA') NOT NULL,
    CONSTRAINT [PK_CargoClase] PRIMARY KEY CLUSTERED ([CargoClaseId]),
    CONSTRAINT [FK_CargoClase_CargoId] FOREIGN KEY ([CargoId]) REFERENCES [Finanzas].[Cargo] ([CargoId]),
    CONSTRAINT [FK_CargoClase_Fecha] FOREIGN KEY ([Fecha]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_CargoClase_ClaseHorarioId] FOREIGN KEY ([ClaseHorarioId]) REFERENCES [Clases].[ClaseHorario] ([ClaseHorarioId]),
    CONSTRAINT [FK_CargoClase_SesionClaseId] FOREIGN KEY ([SesionClaseId]) REFERENCES [Clases].[SesionClase] ([SesionClaseId]),
    CONSTRAINT [CK_CargoClase_Importe] CHECK ([Importe] >= 0),
    CONSTRAINT [CK_CargoClase_Estatus] CHECK ([Estatus] IN ('ACTIVA','CANCELADA','REPUESTA'))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CargoClase_Clase]
    ON [Finanzas].[CargoClase] ([CargoId], [Fecha], [ClaseHorarioId]);
GO
CREATE NONCLUSTERED INDEX [IX_CargoClase_Sesion]
    ON [Finanzas].[CargoClase] ([SesionClaseId])
    WHERE [SesionClaseId] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cada clase (fecha y hora) que cubre un cargo. Permite cobrar por clase, 2 horas seguidas el mismo día o el mes según los días reales.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'CargoClaseId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bloque al que corresponde.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'ClaseHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Se liga cuando la sesión ya existe.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'SesionClaseId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CANCELADA = la escuela canceló la clase (se reembolsa o se repone).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'Estatus';
GO
