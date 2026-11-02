/*============================================================================================
  Tabla      : Personal.Profesor
  Descripción: Profesores / instructores (rol de una Persona). Opcionalmente ligados a un usuario del sistema.
  Atiende    : RFN04 · Profesores
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Personal].[Profesor]
(
    [ProfesorId] INT IDENTITY (1, 1) NOT NULL,
    [PersonaId] INT NOT NULL,
    [UsuarioId] INT NULL,
    [Especialidad] NVARCHAR(100) NULL,
    [ColorCalendario] CHAR(7) NULL,
    [FechaIngreso] DATE CONSTRAINT [DF_Profesor_FechaIngreso] DEFAULT (CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time (Mexico)' AS DATE)) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Profesor_Activo] DEFAULT (1) NOT NULL,
    [FechaBaja] DATE NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Profesor_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Profesor] PRIMARY KEY CLUSTERED ([ProfesorId]),
    CONSTRAINT [UQ_Profesor_PersonaId] UNIQUE ([PersonaId]),
    CONSTRAINT [FK_Profesor_PersonaId] FOREIGN KEY ([PersonaId]) REFERENCES [Personas].[Persona] ([PersonaId]),
    CONSTRAINT [FK_Profesor_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Profesor_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Profesor_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Profesor_Usuario]
    ON [Personal].[Profesor] ([UsuarioId])
    WHERE [UsuarioId] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Profesores / instructores (rol de una Persona). Opcionalmente ligados a un usuario del sistema.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'ProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre, edad, teléfono y domicilio viven en Persona.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'PersonaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el profesor entra al sistema.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Color del profesor en el calendario (#RRGGBB).',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'ColorCalendario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'RowVer';
GO
