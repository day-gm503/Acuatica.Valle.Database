/* Esquema Personal: Profesores y su tarifa por hora. */
CREATE SCHEMA [Personal]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Profesores y su tarifa por hora.',
    @level0type = N'SCHEMA', @level0name = N'Personal';
GO
