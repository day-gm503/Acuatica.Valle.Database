/*============================================================================================
  Tabla      : Seguridad.Usuario
  Descripción: Usuarios que inician sesión en el sistema (administración, recepción, profesores).
  Atiende    : RSN01 · Configuración > Usuarios
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Seguridad].[Usuario]
(
    [UsuarioId] INT IDENTITY (1, 1) NOT NULL,
    [NombreUsuario] NVARCHAR(50) NOT NULL,
    [NombreCompleto] NVARCHAR(150) NOT NULL,
    [Correo] NVARCHAR(150) NULL,
    [Telefono] VARCHAR(20) NULL,
    [PasswordHash] VARCHAR(256) NOT NULL,
    [DebeCambiarPassword] BIT CONSTRAINT [DF_Usuario_DebeCambiarPassword] DEFAULT (1) NOT NULL,
    [IntentosFallidos] TINYINT CONSTRAINT [DF_Usuario_IntentosFallidos] DEFAULT (0) NOT NULL,
    [BloqueadoHastaUtc] DATETIME2(0) NULL,
    [UltimoAccesoUtc] DATETIME2(0) NULL,
    [Activo] BIT CONSTRAINT [DF_Usuario_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Usuario_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([UsuarioId]),
    CONSTRAINT [UQ_Usuario_NombreUsuario] UNIQUE ([NombreUsuario]),
    CONSTRAINT [FK_Usuario_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Usuario_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Usuario_Correo]
    ON [Seguridad].[Usuario] ([Correo])
    WHERE [Correo] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuarios que inician sesión en el sistema (administración, recepción, profesores).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Login. Único.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'NombreUsuario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Único cuando existe (índice filtrado).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'Correo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hash PBKDF2/Argon2 con sal y parámetros. Nunca la contraseña.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'PasswordHash';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obliga a cambiar la contraseña en el siguiente inicio.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'DebeCambiarPassword';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bloqueo temporal por intentos fallidos.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'BloqueadoHastaUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'RowVer';
GO
