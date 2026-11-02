/*============================================================================================
  Tabla      : Alumnos.Alumno
  Descripción: Alumno de la escuela (rol de una Persona). Se registra sin necesidad de capturar pago (nota 09/03/2026).
  Atiende    : RFN01 · Control de alumnos / Detalles del alumno
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Alumnos].[Alumno]
(
    [AlumnoId] INT IDENTITY (1, 1) NOT NULL,
    [PersonaId] INT NOT NULL,
    [Matricula] VARCHAR(20) CONSTRAINT [DF_Alumno_Matricula] DEFAULT (CONCAT('AV-', RIGHT(CONCAT('000000', NEXT VALUE FOR [Alumnos].[SeqMatricula]), 6))) NOT NULL,
    [PadeceEnfermedad] BIT CONSTRAINT [DF_Alumno_PadeceEnfermedad] DEFAULT (0) NOT NULL,
    [NivelId] TINYINT NULL,
    [FechaIngreso] DATE CONSTRAINT [DF_Alumno_FechaIngreso] DEFAULT (CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time (Mexico)' AS DATE)) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Alumno_Activo] DEFAULT (1) NOT NULL,
    [FechaBaja] DATE NULL,
    [MotivoBaja] NVARCHAR(250) NULL,
    [FotoUrl] VARCHAR(300) NULL,
    [Observaciones] NVARCHAR(500) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Alumno_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Alumno] PRIMARY KEY CLUSTERED ([AlumnoId]),
    CONSTRAINT [UQ_Alumno_PersonaId] UNIQUE ([PersonaId]),
    CONSTRAINT [UQ_Alumno_Matricula] UNIQUE ([Matricula]),
    CONSTRAINT [FK_Alumno_PersonaId] FOREIGN KEY ([PersonaId]) REFERENCES [Personas].[Persona] ([PersonaId]),
    CONSTRAINT [FK_Alumno_NivelId] FOREIGN KEY ([NivelId]) REFERENCES [Catalogo].[Nivel] ([NivelId]),
    CONSTRAINT [FK_Alumno_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Alumno_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Alumno_Activo]
    ON [Alumnos].[Alumno] ([Activo])
    INCLUDE ([PersonaId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alumno de la escuela (rol de una Persona). Se registra sin necesidad de capturar pago (nota 09/03/2026).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'AlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre, fecha de nacimiento, teléfono y domicilio viven en Persona.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'PersonaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Folio visible del alumno (ej. AV-000123).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'Matricula';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sí/No. El detalle va en AlumnoCondicionMedica.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'PadeceEnfermedad';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de registro / ingreso.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'FechaIngreso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estatus Activo / Inactivo.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'Activo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para analizar deserción por temporada.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'MotivoBaja';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'RowVer';
GO
