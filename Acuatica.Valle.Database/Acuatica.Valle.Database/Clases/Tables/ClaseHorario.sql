/*============================================================================================
  Tabla      : Clases.ClaseHorario
  Descripción: Bloque de clase recurrente: día de la semana + hora + profesor titular (lo que se ve en el calendario).
  Atiende    : RFN02 / RFN04 · Calendario, Registrar horario
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[ClaseHorario]
(
    [ClaseHorarioId] INT IDENTITY (1, 1) NOT NULL,
    [DiaSemana] TINYINT NOT NULL,
    [HoraInicio] TIME(0) NOT NULL,
    [HoraFin] TIME(0) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [NivelId] TINYINT NULL,
    [AlbercaId] TINYINT NULL,
    [Carril] TINYINT NULL,
    [CupoMaximo] TINYINT CONSTRAINT [DF_ClaseHorario_CupoMaximo] DEFAULT (12) NOT NULL,
    [VigenteDesde] DATE NOT NULL,
    [VigenteHasta] DATE NULL,
    [Activo] BIT CONSTRAINT [DF_ClaseHorario_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_ClaseHorario_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_ClaseHorario] PRIMARY KEY CLUSTERED ([ClaseHorarioId]),
    CONSTRAINT [FK_ClaseHorario_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_ClaseHorario_NivelId] FOREIGN KEY ([NivelId]) REFERENCES [Catalogo].[Nivel] ([NivelId]),
    CONSTRAINT [FK_ClaseHorario_AlbercaId] FOREIGN KEY ([AlbercaId]) REFERENCES [Operacion].[Alberca] ([AlbercaId]),
    CONSTRAINT [FK_ClaseHorario_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_ClaseHorario_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_ClaseHorario_DiaSemana] CHECK ([DiaSemana] BETWEEN 1 AND 7),
    CONSTRAINT [CK_ClaseHorario_Horas] CHECK ([HoraFin] > [HoraInicio])
);
GO
CREATE NONCLUSTERED INDEX [IX_ClaseHorario_Dia]
    ON [Clases].[ClaseHorario] ([DiaSemana], [HoraInicio])
    INCLUDE ([ProfesorId], [Activo]);
GO
CREATE NONCLUSTERED INDEX [IX_ClaseHorario_Profesor]
    ON [Clases].[ClaseHorario] ([ProfesorId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bloque de clase recurrente: día de la semana + hora + profesor titular (lo que se ve en el calendario).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'ClaseHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = lunes … 7 = domingo (ISO).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'DiaSemana';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Profesor titular.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'ProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'ClaseHorario', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
