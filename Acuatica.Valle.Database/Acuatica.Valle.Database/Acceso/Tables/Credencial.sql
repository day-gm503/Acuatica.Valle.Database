/*============================================================================================
  Tabla      : Acceso.Credencial
  Descripción: Credencial de acceso de un alumno o profesor: huella (o tarjeta/QR a futuro). No guarda la plantilla biométrica.
  Atiende    : Lector de huella
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Acceso].[Credencial]
(
    [CredencialId] INT IDENTITY (1, 1) NOT NULL,
    [TipoCredencial] VARCHAR(7) CONSTRAINT [DF_Credencial_TipoCredencial] DEFAULT ('HUELLA') NOT NULL,
    [AlumnoId] INT NULL,
    [ProfesorId] INT NULL,
    [IdEnDispositivo] VARCHAR(30) NOT NULL,
    [Dedo] TINYINT NULL,
    [FechaEnrolamientoUtc] DATETIME2(0) CONSTRAINT [DF_Credencial_FechaEnrolamientoUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [Activa] BIT CONSTRAINT [DF_Credencial_Activa] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Credencial_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Credencial] PRIMARY KEY CLUSTERED ([CredencialId]),
    CONSTRAINT [FK_Credencial_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_Credencial_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_Credencial_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Credencial_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Credencial_TipoCredencial] CHECK ([TipoCredencial] IN ('HUELLA','TARJETA','QR')),
    CONSTRAINT [CK_Credencial_Dedo] CHECK ([Dedo] BETWEEN 1 AND 10),
    CONSTRAINT [CK_Credencial_Persona] CHECK (([AlumnoId] IS NOT NULL AND [ProfesorId] IS NULL) OR ([AlumnoId] IS NULL AND [ProfesorId] IS NOT NULL))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Credencial_IdDispositivo]
    ON [Acceso].[Credencial] ([TipoCredencial], [IdEnDispositivo]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Credencial de acceso de un alumno o profesor: huella (o tarjeta/QR a futuro). No guarda la plantilla biométrica.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'CredencialId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de enrolamiento que devuelve el lector.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'IdEnDispositivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
