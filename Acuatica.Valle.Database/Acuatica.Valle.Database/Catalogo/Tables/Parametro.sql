/*============================================================================================
  Tabla      : Catalogo.Parametro
  Descripción: Parámetros del sistema clave/valor (días de aviso de vencimiento, tolerancia de retardo, datos de la escuela…).
  Atiende    : Configuración
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Catalogo].[Parametro]
(
    [ParametroId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Clave] VARCHAR(60) NOT NULL,
    [Valor] NVARCHAR(500) NOT NULL,
    [TipoDato] VARCHAR(10) CONSTRAINT [DF_Parametro_TipoDato] DEFAULT ('TEXTO') NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Parametro_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Parametro] PRIMARY KEY CLUSTERED ([ParametroId]),
    CONSTRAINT [UQ_Parametro_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Parametro_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Parametro_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Parametro_TipoDato] CHECK ([TipoDato] IN ('TEXTO','ENTERO','DECIMAL','BOOL','FECHA','JSON'))
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Parámetros del sistema clave/valor (días de aviso de vencimiento, tolerancia de retardo, datos de la escuela…).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'ParametroId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DIAS_AVISO_VENCIMIENTO, MINUTOS_TOLERANCIA, BLOQUEAR_ACCESO_CON_ADEUDO…',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
