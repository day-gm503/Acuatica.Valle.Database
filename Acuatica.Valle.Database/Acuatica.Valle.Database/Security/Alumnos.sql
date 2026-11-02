/* Esquema Alumnos: Alumnos, tutores de menores y condiciones médicas. */
CREATE SCHEMA [Alumnos]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alumnos, tutores de menores y condiciones médicas.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos';
GO
