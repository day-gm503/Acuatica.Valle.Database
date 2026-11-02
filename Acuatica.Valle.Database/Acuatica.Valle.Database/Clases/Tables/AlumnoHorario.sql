/*============================================================================================
  Tabla      : Clases.AlumnoHorario
  Descripción: Inscripción del alumno a un bloque de horario (Registrar horario: Lunes 8–9, Miércoles 8–9…).
  Atiende    : RFN02 · Registro de horario
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[AlumnoHorario]
(
    [AlumnoHorarioId] INT IDENTITY (1, 1) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [ClaseHorarioId] INT NOT NULL,
    [FechaInicio] DATE NOT NULL,
    [FechaFin] DATE NULL,
    [Activo] BIT CONSTRAINT [DF_AlumnoHorario_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_AlumnoHorario_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_AlumnoHorario] PRIMARY KEY CLUSTERED ([AlumnoHorarioId]),
    CONSTRAINT [FK_AlumnoHorario_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AlumnoHorario_ClaseHorarioId] FOREIGN KEY ([ClaseHorarioId]) REFERENCES [Clases].[ClaseHorario] ([ClaseHorarioId]),
    CONSTRAINT [FK_AlumnoHorario_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_AlumnoHorario_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_AlumnoHorario_Activo]
    ON [Clases].[AlumnoHorario] ([AlumnoId], [ClaseHorarioId])
    WHERE [Activo] = 1;
GO
CREATE NONCLUSTERED INDEX [IX_AlumnoHorario_Clase]
    ON [Clases].[AlumnoHorario] ([ClaseHorarioId], [Activo])
    INCLUDE ([AlumnoId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inscripción del alumno a un bloque de horario (Registrar horario: Lunes 8–9, Miércoles 8–9…).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'AlumnoHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = sigue inscrito.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'FechaFin';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
