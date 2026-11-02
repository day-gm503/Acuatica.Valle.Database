/*============================================================================================
  Tabla      : Alumnos.AlumnoTutor
  Descripción: Padre, madre o tutor de un alumno MENOR de edad (solo se captura en ese caso). El tutor es una Persona: puede ser también alumno o tutor de varios hermanos.
  Atiende    : RFN01 · Padre, madre o tutor (solo menores)
============================================================================================*/
CREATE TABLE [Alumnos].[AlumnoTutor]
(
    [AlumnoId] INT NOT NULL,
    [TutorPersonaId] INT NOT NULL,
    [Parentesco] VARCHAR(15) NOT NULL,
    [EsResponsablePago] BIT CONSTRAINT [DF_AlumnoTutor_EsResponsablePago] DEFAULT (1) NOT NULL,
    [EsContactoEmergencia] BIT CONSTRAINT [DF_AlumnoTutor_EsContactoEmergencia] DEFAULT (1) NOT NULL,
    [PuedeRecoger] BIT CONSTRAINT [DF_AlumnoTutor_PuedeRecoger] DEFAULT (1) NOT NULL,
    [FechaRegistroUtc] DATETIME2(0) CONSTRAINT [DF_AlumnoTutor_FechaRegistroUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    CONSTRAINT [PK_AlumnoTutor] PRIMARY KEY CLUSTERED ([AlumnoId], [TutorPersonaId]),
    CONSTRAINT [FK_AlumnoTutor_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AlumnoTutor_TutorPersonaId] FOREIGN KEY ([TutorPersonaId]) REFERENCES [Personas].[Persona] ([PersonaId]),
    CONSTRAINT [CK_AlumnoTutor_Parentesco] CHECK ([Parentesco] IN ('MADRE','PADRE','TUTOR','ABUELO','OTRO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_AlumnoTutor_Tutor]
    ON [Alumnos].[AlumnoTutor] ([TutorPersonaId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Padre, madre o tutor de un alumno MENOR de edad (solo se captura en ese caso). El tutor es una Persona: puede ser también alumno o tutor de varios hermanos.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoTutor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoTutor', @level2type = N'COLUMN', @level2name = N'AlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persona que es tutor. No puede ser la misma Persona del alumno (lo valida el SP).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoTutor', @level2type = N'COLUMN', @level2name = N'TutorPersonaId';
GO
