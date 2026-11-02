/*============================================================================================
  Tabla      : Seguridad.Bitacora
  Descripción: Auditoría de acciones (quién hizo qué y cuándo). Sin FK a propósito: registrar nunca debe fallar.
  Atiende    : Seguridad / trazabilidad
============================================================================================*/
CREATE TABLE [Seguridad].[Bitacora]
(
    [BitacoraId] BIGINT IDENTITY (1, 1) NOT NULL,
    [FechaUtc] DATETIME2(3) CONSTRAINT [DF_Bitacora_FechaUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [UsuarioId] INT NULL,
    [Accion] VARCHAR(50) NOT NULL,
    [Entidad] VARCHAR(60) NULL,
    [EntidadId] VARCHAR(40) NULL,
    [ValoresAnteriores] NVARCHAR(MAX) NULL,
    [ValoresNuevos] NVARCHAR(MAX) NULL,
    [Exito] BIT CONSTRAINT [DF_Bitacora_Exito] DEFAULT (1) NOT NULL,
    [Ip] VARCHAR(45) NULL,
    CONSTRAINT [PK_Bitacora] PRIMARY KEY CLUSTERED ([BitacoraId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Bitacora_Fecha]
    ON [Seguridad].[Bitacora] ([FechaUtc] DESC)
    INCLUDE ([Accion], [UsuarioId]);
GO
CREATE NONCLUSTERED INDEX [IX_Bitacora_Entidad]
    ON [Seguridad].[Bitacora] ([Entidad], [EntidadId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auditoría de acciones (quién hizo qué y cuándo). Sin FK a propósito: registrar nunca debe fallar.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'BitacoraId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sin FK a propósito.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LOGIN, CREAR, EDITAR, ELIMINAR, CANCELAR_PAGO…',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'Accion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla afectada (Finanzas.Pago).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'Entidad';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'ValoresAnteriores';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'ValoresNuevos';
GO
