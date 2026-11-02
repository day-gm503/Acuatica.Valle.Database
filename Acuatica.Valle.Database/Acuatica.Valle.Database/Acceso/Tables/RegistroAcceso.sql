/*============================================================================================
  Tabla      : Acceso.RegistroAcceso
  Descripción: Cada checada del lector (entrada/salida). Se procesa para generar asistencias.
  Atiende    : Lector de huella · entradas y salidas
============================================================================================*/
CREATE TABLE [Acceso].[RegistroAcceso]
(
    [RegistroAccesoId] BIGINT IDENTITY (1, 1) NOT NULL,
    [DispositivoId] SMALLINT NOT NULL,
    [CredencialId] INT NULL,
    [AlumnoId] INT NULL,
    [ProfesorId] INT NULL,
    [FechaHoraUtc] DATETIME2(0) NOT NULL,
    [TipoEvento] VARCHAR(7) NOT NULL,
    [Resultado] VARCHAR(13) CONSTRAINT [DF_RegistroAcceso_Resultado] DEFAULT ('PERMITIDO') NOT NULL,
    [MotivoDenegado] NVARCHAR(150) NULL,
    [IdEventoDispositivo] VARCHAR(50) NULL,
    [Procesado] BIT CONSTRAINT [DF_RegistroAcceso_Procesado] DEFAULT (0) NOT NULL,
    CONSTRAINT [PK_RegistroAcceso] PRIMARY KEY CLUSTERED ([RegistroAccesoId]),
    CONSTRAINT [FK_RegistroAcceso_DispositivoId] FOREIGN KEY ([DispositivoId]) REFERENCES [Acceso].[Dispositivo] ([DispositivoId]),
    CONSTRAINT [FK_RegistroAcceso_CredencialId] FOREIGN KEY ([CredencialId]) REFERENCES [Acceso].[Credencial] ([CredencialId]),
    CONSTRAINT [FK_RegistroAcceso_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_RegistroAcceso_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [CK_RegistroAcceso_TipoEvento] CHECK ([TipoEvento] IN ('ENTRADA','SALIDA')),
    CONSTRAINT [CK_RegistroAcceso_Resultado] CHECK ([Resultado] IN ('PERMITIDO','DENEGADO','NO_RECONOCIDO'))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_RegistroAcceso_Evento]
    ON [Acceso].[RegistroAcceso] ([DispositivoId], [IdEventoDispositivo])
    WHERE [IdEventoDispositivo] IS NOT NULL;
GO
CREATE NONCLUSTERED INDEX [IX_RegistroAcceso_Fecha]
    ON [Acceso].[RegistroAcceso] ([FechaHoraUtc])
    INCLUDE ([AlumnoId], [ProfesorId], [TipoEvento]);
GO
CREATE NONCLUSTERED INDEX [IX_RegistroAcceso_Pendientes]
    ON [Acceso].[RegistroAcceso] ([Procesado], [FechaHoraUtc])
    WHERE [Procesado] = 0;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cada checada del lector (entrada/salida). Se procesa para generar asistencias.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso', @level2type = N'COLUMN', @level2name = N'RegistroAccesoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = huella no reconocida.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso', @level2type = N'COLUMN', @level2name = N'CredencialId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Copia para consultas rápidas.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso', @level2type = N'COLUMN', @level2name = N'AlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. adeudo vencido, fuera de horario.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso', @level2type = N'COLUMN', @level2name = N'MotivoDenegado';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del evento en el lector, evita duplicados al sincronizar.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso', @level2type = N'COLUMN', @level2name = N'IdEventoDispositivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = ya se ligó a una asistencia.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'RegistroAcceso', @level2type = N'COLUMN', @level2name = N'Procesado';
GO
