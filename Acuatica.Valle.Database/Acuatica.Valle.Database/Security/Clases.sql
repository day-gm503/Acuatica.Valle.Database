/* Esquema Clases: Horarios, inscripciones, clases impartidas y asistencia. */
CREATE SCHEMA [Clases]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horarios, inscripciones, clases impartidas y asistencia.',
    @level0type = N'SCHEMA', @level0name = N'Clases';
GO
