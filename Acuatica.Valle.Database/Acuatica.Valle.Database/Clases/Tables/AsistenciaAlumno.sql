/*============================================================================================
  Tabla      : Clases.AsistenciaAlumno
  Descripción: Asistencia de un alumno a una clase. Puede venir del lector de huella o capturarse manualmente.
  Atiende    : RFN04 / RFN05 · Registrar asistencia, Asistencia del día
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[AsistenciaAlumno]
(
    [AsistenciaAlumnoId] BIGINT IDENTITY (1, 1) NOT NULL,
    [SesionClaseId] INT NOT NULL,
    [AlumnoId] INT NOT NULL,
    [Estatus] VARCHAR(11) CONSTRAINT [DF_AsistenciaAlumno_Estatus] DEFAULT ('ASISTIO') NOT NULL,
    [Origen] VARCHAR(6) CONSTRAINT [DF_AsistenciaAlumno_Origen] DEFAULT ('MANUAL') NOT NULL,
    [RegistroAccesoId] BIGINT NULL,
    [FechaHoraRegistroUtc] DATETIME2(0) CONSTRAINT [DF_AsistenciaAlumno_FechaHoraRegistroUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_AsistenciaAlumno_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_AsistenciaAlumno] PRIMARY KEY CLUSTERED ([AsistenciaAlumnoId]),
    CONSTRAINT [FK_AsistenciaAlumno_SesionClaseId] FOREIGN KEY ([SesionClaseId]) REFERENCES [Clases].[SesionClase] ([SesionClaseId]),
    CONSTRAINT [FK_AsistenciaAlumno_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AsistenciaAlumno_RegistroAccesoId] FOREIGN KEY ([RegistroAccesoId]) REFERENCES [Acceso].[RegistroAcceso] ([RegistroAccesoId]),
    CONSTRAINT [FK_AsistenciaAlumno_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_AsistenciaAlumno_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_AsistenciaAlumno_Estatus] CHECK ([Estatus] IN ('ASISTIO','FALTA','JUSTIFICADA','RETARDO')),
    CONSTRAINT [CK_AsistenciaAlumno_Origen] CHECK ([Origen] IN ('MANUAL','HUELLA'))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_AsistenciaAlumno_SesionAlumno]
    ON [Clases].[AsistenciaAlumno] ([SesionClaseId], [AlumnoId]);
GO
CREATE NONCLUSTERED INDEX [IX_AsistenciaAlumno_Alumno]
    ON [Clases].[AsistenciaAlumno] ([AlumnoId])
    INCLUDE ([Estatus], [SesionClaseId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asistencia de un alumno a una clase. Puede venir del lector de huella o capturarse manualmente.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'AsistenciaAlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Checada que la originó.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'RegistroAccesoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
