/* Esquema Catalogo: Catálogos configurables y parámetros del sistema. */
CREATE SCHEMA [Catalogo]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogos configurables y parámetros del sistema.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo';
GO
