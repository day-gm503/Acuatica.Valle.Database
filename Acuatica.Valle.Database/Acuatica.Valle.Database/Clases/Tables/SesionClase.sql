/*============================================================================================
  Tabla      : Clases.SesionClase
  Descripción: Clase real en una fecha. Registra suplencias, cancelaciones y las horas que impartió el profesor (base de su pago).
  Atiende    : RFN04 · Calendario / Profesores en turno / Reportes
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[SesionClase]
(
    [SesionClaseId] INT IDENTITY (1, 1) NOT NULL,
    [ClaseHorarioId] INT NULL,
    [Fecha] DATE NOT NULL,
    [HoraInicio] TIME(0) NOT NULL,
    [HoraFin] TIME(0) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [EsSuplencia] BIT CONSTRAINT [DF_SesionClase_EsSuplencia] DEFAULT (0) NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_SesionClase_Estatus] DEFAULT ('PROGRAMADA') NOT NULL,
    [MotivoCancelacion] NVARCHAR(250) NULL,
    [EntradaProfesorUtc] DATETIME2(0) NULL,
    [SalidaProfesorUtc] DATETIME2(0) NULL,
    [HorasPagables] DECIMAL(4,2) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_SesionClase_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_SesionClase] PRIMARY KEY CLUSTERED ([SesionClaseId]),
    CONSTRAINT [FK_SesionClase_ClaseHorarioId] FOREIGN KEY ([ClaseHorarioId]) REFERENCES [Clases].[ClaseHorario] ([ClaseHorarioId]),
    CONSTRAINT [FK_SesionClase_Fecha] FOREIGN KEY ([Fecha]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_SesionClase_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_SesionClase_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_SesionClase_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_SesionClase_Estatus] CHECK ([Estatus] IN ('PROGRAMADA','IMPARTIDA','CANCELADA')),
    CONSTRAINT [CK_SesionClase_Horas] CHECK ([HoraFin] > [HoraInicio])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SesionClase_HorarioFecha]
    ON [Clases].[SesionClase] ([ClaseHorarioId], [Fecha])
    WHERE [ClaseHorarioId] IS NOT NULL;
GO
CREATE NONCLUSTERED INDEX [IX_SesionClase_Fecha]
    ON [Clases].[SesionClase] ([Fecha], [HoraInicio])
    INCLUDE ([ProfesorId], [Estatus]);
GO
CREATE NONCLUSTERED INDEX [IX_SesionClase_Profesor]
    ON [Clases].[SesionClase] ([ProfesorId], [Fecha])
    INCLUDE ([Estatus], [HorasPagables]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clase real en una fecha. Registra suplencias, cancelaciones y las horas que impartió el profesor (base de su pago).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'SesionClaseId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = clase extra / muestra.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'ClaseHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Quien la impartió (puede ser suplente).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'ProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. mantenimiento, clima, día festivo.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'MotivoCancelacion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Checada del profesor (huella o manual).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'EntradaProfesorUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horas a pagar al profesor por esta clase.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'HorasPagables';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
