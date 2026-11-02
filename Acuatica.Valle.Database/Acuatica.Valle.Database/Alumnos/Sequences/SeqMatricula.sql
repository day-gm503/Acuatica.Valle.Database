/* Consecutivo de la matrícula del alumno (AV-000123). La usa el DEFAULT de Alumnos.Alumno.Matricula. */
CREATE SEQUENCE [Alumnos].[SeqMatricula]
    AS INT
    START WITH 1
    INCREMENT BY 1
    NO CYCLE
    CACHE 10;
GO
