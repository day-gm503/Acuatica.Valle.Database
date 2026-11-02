/*============================================================================================
  Tabla      : Alumnos.AlumnoCondicionMedica
  Descripción: Enfermedades, alergias o lesiones del alumno (puede tener varias).
  Atiende    : RFN01 · ¿Padece enfermedad? / Nombre de enfermedad
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Alumnos].[AlumnoCondicionMedica]
(
    [CondicionMedicaId] INT IDENTITY (1, 1) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [Tipo] VARCHAR(12) CONSTRAINT [DF_AlumnoCondicionMedica_Tipo] DEFAULT ('ENFERMEDAD') NOT NULL,
    [Nombre] NVARCHAR(120) NOT NULL,
    [Indicaciones] NVARCHAR(500) NULL,
    [Activa] BIT CONSTRAINT [DF_AlumnoCondicionMedica_Activa] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_AlumnoCondicionMedica_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_AlumnoCondicionMedica] PRIMARY KEY CLUSTERED ([CondicionMedicaId]),
    CONSTRAINT [FK_AlumnoCondicionMedica_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AlumnoCondicionMedica_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_AlumnoCondicionMedica_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_AlumnoCondicionMedica_Tipo] CHECK ([Tipo] IN ('ENFERMEDAD','ALERGIA','LESION','OTRO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_AlumnoCondicionMedica_Alumno]
    ON [Alumnos].[AlumnoCondicionMedica] ([AlumnoId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Enfermedades, alergias o lesiones del alumno (puede tener varias).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'CondicionMedicaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. Hipertensión, asma.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'Nombre';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Qué hacer en caso de emergencia.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'Indicaciones';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
