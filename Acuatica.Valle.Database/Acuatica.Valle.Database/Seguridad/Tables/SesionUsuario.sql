/*============================================================================================
  Tabla      : Seguridad.SesionUsuario
  Descripción: Sesiones abiertas (token de renovación). Permite cerrar sesiones desde el servidor.
  Atiende    : Login
============================================================================================*/
CREATE TABLE [Seguridad].[SesionUsuario]
(
    [SesionId] BIGINT IDENTITY (1, 1) NOT NULL,
    [UsuarioId] INT NOT NULL,
    [RefreshTokenHash] CHAR(64) NOT NULL,
    [FechaInicioUtc] DATETIME2(0) CONSTRAINT [DF_SesionUsuario_FechaInicioUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [FechaExpiraUtc] DATETIME2(0) NOT NULL,
    [FechaCierreUtc] DATETIME2(0) NULL,
    [MotivoCierre] VARCHAR(30) NULL,
    [Ip] VARCHAR(45) NULL,
    [UserAgent] NVARCHAR(400) NULL,
    CONSTRAINT [PK_SesionUsuario] PRIMARY KEY CLUSTERED ([SesionId]),
    CONSTRAINT [UQ_SesionUsuario_RefreshTokenHash] UNIQUE ([RefreshTokenHash]),
    CONSTRAINT [FK_SesionUsuario_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE NONCLUSTERED INDEX [IX_SesionUsuario_Usuario]
    ON [Seguridad].[SesionUsuario] ([UsuarioId], [FechaCierreUtc]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sesiones abiertas (token de renovación). Permite cerrar sesiones desde el servidor.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario', @level2type = N'COLUMN', @level2name = N'SesionId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SHA-256 del token de renovación vigente.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario', @level2type = N'COLUMN', @level2name = N'RefreshTokenHash';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LOGOUT, EXPIRADA, REVOCADA',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario', @level2type = N'COLUMN', @level2name = N'MotivoCierre';
GO
