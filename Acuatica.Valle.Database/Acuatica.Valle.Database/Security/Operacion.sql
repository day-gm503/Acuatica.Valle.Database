/* Esquema Operacion: Albercas, proveedores, mantenimiento y calidad del agua. */
CREATE SCHEMA [Operacion]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Albercas, proveedores, mantenimiento y calidad del agua.',
    @level0type = N'SCHEMA', @level0name = N'Operacion';
GO
