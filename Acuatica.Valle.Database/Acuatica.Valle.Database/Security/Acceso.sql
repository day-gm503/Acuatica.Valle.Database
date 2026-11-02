/* Esquema Acceso: Lector de huella / control de entradas y salidas. */
CREATE SCHEMA [Acceso]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lector de huella / control de entradas y salidas.',
    @level0type = N'SCHEMA', @level0name = N'Acceso';
GO
