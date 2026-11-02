/*============================================================================================
  Tabla      : Operacion.Proveedor
  Descripción: Proveedores de químicos, mantenimiento, equipo y servicios.
  Atiende    : Gastos
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[Proveedor]
(
    [ProveedorId] INT IDENTITY (1, 1) NOT NULL,
    [RazonSocial] NVARCHAR(150) NOT NULL,
    [RFC] VARCHAR(13) NULL,
    [Contacto] NVARCHAR(100) NULL,
    [Telefono] VARCHAR(20) NULL,
    [Correo] NVARCHAR(150) NULL,
    [Activo] BIT CONSTRAINT [DF_Proveedor_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Proveedor_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED ([ProveedorId]),
    CONSTRAINT [FK_Proveedor_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Proveedor_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedores de químicos, mantenimiento, equipo y servicios.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'ProveedorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
