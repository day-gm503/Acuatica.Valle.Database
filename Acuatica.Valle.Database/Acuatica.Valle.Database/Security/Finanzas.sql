/* Esquema Finanzas: Tarifas, cargos, pagos de alumnos, nómina de profesores, gastos y caja. */
CREATE SCHEMA [Finanzas]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tarifas, cargos, pagos de alumnos, nómina de profesores, gastos y caja.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas';
GO
