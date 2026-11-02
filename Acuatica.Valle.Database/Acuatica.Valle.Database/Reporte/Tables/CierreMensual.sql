/*============================================================================================
  Tabla      : Reporte.CierreMensual
  Descripción: Foto de los indicadores del mes al cerrarlo. Hace rápidos los comparativos contra meses anteriores.
  Atiende    : RFN06 · Comparativa mes anterior
============================================================================================*/
CREATE TABLE [Reporte].[CierreMensual]
(
    [CierreMensualId] INT IDENTITY (1, 1) NOT NULL,
    [Anio] SMALLINT NOT NULL,
    [Mes] TINYINT NOT NULL,
    [IngresosAlumnos] DECIMAL(12,2) NOT NULL,
    [PagosProfesores] DECIMAL(12,2) NOT NULL,
    [GastosOperacion] DECIMAL(12,2) NOT NULL,
    [GastosMantenimiento] DECIMAL(12,2) NOT NULL,
    [Utilidad] DECIMAL(12,2) NOT NULL,
    [SaldoPorCobrar] DECIMAL(12,2) NOT NULL,
    [AlumnosActivos] INT NOT NULL,
    [AlumnosNuevos] INT NOT NULL,
    [AlumnosBaja] INT NOT NULL,
    [ClasesImpartidas] INT NOT NULL,
    [TotalAsistencias] INT NOT NULL,
    [PorcentajeAsistencia] DECIMAL(5,2) NOT NULL,
    [FechaCierreUtc] DATETIME2(0) CONSTRAINT [DF_CierreMensual_FechaCierreUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CerradoPor] INT NOT NULL,
    CONSTRAINT [PK_CierreMensual] PRIMARY KEY CLUSTERED ([CierreMensualId]),
    CONSTRAINT [FK_CierreMensual_CerradoPor] FOREIGN KEY ([CerradoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_CierreMensual_Mes] CHECK ([Mes] BETWEEN 1 AND 12)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CierreMensual_Periodo]
    ON [Reporte].[CierreMensual] ([Anio], [Mes]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foto de los indicadores del mes al cerrarlo. Hace rápidos los comparativos contra meses anteriores.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'CierreMensual';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'CierreMensual', @level2type = N'COLUMN', @level2name = N'CierreMensualId';
GO
