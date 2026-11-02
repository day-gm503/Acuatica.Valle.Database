/* Esquema Reporte: Dimensión calendario (temporadas) y cierres mensuales. */
CREATE SCHEMA [Reporte]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensión calendario (temporadas) y cierres mensuales.',
    @level0type = N'SCHEMA', @level0name = N'Reporte';
GO
