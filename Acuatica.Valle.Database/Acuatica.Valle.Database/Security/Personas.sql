/* Esquema Personas: Datos personales únicos (alumno, tutor o profesor). */
CREATE SCHEMA [Personas]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos personales únicos (alumno, tutor o profesor).',
    @level0type = N'SCHEMA', @level0name = N'Personas';
GO
