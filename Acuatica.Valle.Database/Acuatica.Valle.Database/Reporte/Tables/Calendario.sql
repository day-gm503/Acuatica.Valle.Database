/*============================================================================================
  Tabla      : Reporte.Calendario
  Descripción: Dimensión fecha: un renglón por día con temporada, festivos y días operativos. Base de todos los reportes por periodo.
  Atiende    : RFN06 · Reportes por semana/mes, temporadas bajas
============================================================================================*/
CREATE TABLE [Reporte].[Calendario]
(
    [Fecha] DATE NOT NULL,
    [Anio] SMALLINT NOT NULL,
    [Mes] TINYINT NOT NULL,
    [NombreMes] NVARCHAR(12) NOT NULL,
    [Trimestre] TINYINT NOT NULL,
    [SemanaAnio] TINYINT NOT NULL,
    [SemanaMes] TINYINT NOT NULL,
    [DiaSemana] TINYINT NOT NULL,
    [NombreDia] NVARCHAR(12) NOT NULL,
    [EsFinDeSemana] BIT NOT NULL,
    [EsFeriado] BIT CONSTRAINT [DF_Calendario_EsFeriado] DEFAULT (0) NOT NULL,
    [DescripcionFeriado] NVARCHAR(100) NULL,
    [EsDiaOperativo] BIT CONSTRAINT [DF_Calendario_EsDiaOperativo] DEFAULT (1) NOT NULL,
    [TemporadaId] TINYINT NULL,
    CONSTRAINT [PK_Calendario] PRIMARY KEY CLUSTERED ([Fecha]),
    CONSTRAINT [FK_Calendario_TemporadaId] FOREIGN KEY ([TemporadaId]) REFERENCES [Catalogo].[Temporada] ([TemporadaId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Calendario_AnioMes]
    ON [Reporte].[Calendario] ([Anio], [Mes])
    INCLUDE ([SemanaMes], [TemporadaId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensión fecha: un renglón por día con temporada, festivos y días operativos. Base de todos los reportes por periodo.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'Fecha';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Semana ISO.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'SemanaAnio';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Semana 1–5 del mes (reporte semanal).',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'SemanaMes';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = lunes … 7 = domingo.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'DiaSemana';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 = escuela cerrada.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'EsDiaOperativo';
GO
