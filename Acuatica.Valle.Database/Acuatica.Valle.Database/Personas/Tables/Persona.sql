/*============================================================================================
  Tabla      : Personas.Persona
  Descripción: Datos personales y de contacto de cualquier persona: alumno, padre/madre/tutor o profesor. Se captura una sola vez; un padre que también es alumno es la misma Persona.
  Atiende    : RFN01 / RFN04 · Datos personales sin duplicar
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Personas].[Persona]
(
    [PersonaId] INT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [ApellidoPaterno] NVARCHAR(60) NOT NULL,
    [ApellidoMaterno] NVARCHAR(60) NULL,
    [NombreCompleto] AS (CAST([Nombre] + N' ' + [ApellidoPaterno] + ISNULL(N' ' + [ApellidoMaterno], N'') AS NVARCHAR(210))) PERSISTED NOT NULL,
    [FechaNacimiento] DATE NULL,
    [CURP] VARCHAR(18) NULL,
    [Telefono] VARCHAR(20) NULL,
    [TelefonoAlterno] VARCHAR(20) NULL,
    [Correo] NVARCHAR(150) NULL,
    [Domicilio] NVARCHAR(300) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Persona_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED ([PersonaId]),
    CONSTRAINT [FK_Persona_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Persona_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Persona_CURP]
    ON [Personas].[Persona] ([CURP])
    WHERE [CURP] IS NOT NULL;
GO
CREATE NONCLUSTERED INDEX [IX_Persona_NombreCompleto]
    ON [Personas].[Persona] ([NombreCompleto])
    INCLUDE ([Telefono], [FechaNacimiento]);
GO
CREATE NONCLUSTERED INDEX [IX_Persona_Telefono]
    ON [Personas].[Persona] ([Telefono])
    INCLUDE ([NombreCompleto])
    WHERE [Telefono] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos personales y de contacto de cualquier persona: alumno, padre/madre/tutor o profesor. Se captura una sola vez; un padre que también es alumno es la misma Persona.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'PersonaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Calculada y persistida: para búsqueda y listados.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'NombreCompleto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obligatoria para alumnos (la valida el SP). La edad y si es menor de edad se calculan.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'FechaNacimiento';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Opcional. Única cuando existe: ayuda a detectar personas repetidas.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'CURP';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'RowVer';
GO
