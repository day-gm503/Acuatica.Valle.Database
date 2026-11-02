/*============================================================================================
  Acuática Valle · Instalación completa de la base de datos (modelo ER v1.2)

  ARCHIVO GENERADO a partir de los scripts del proyecto. No se edita a mano: los cambios se
  hacen en las tablas del proyecto y este archivo se vuelve a generar.

  Uso: ábrelo en SSMS o Azure Data Studio y ejecútalo completo (F5). Crea la base
  [AcuaticaValle] si no existe, los 10 esquemas, las 44 tablas, secuencias, índices,
  descripciones y los datos iniciales.

  Solo sirve para una base NUEVA. Para actualizar una base existente se publica el proyecto
  (clic derecho > Publicar), que calcula las diferencias sin perder datos.
============================================================================================*/
IF DB_ID(N'AcuaticaValle') IS NULL
    CREATE DATABASE [AcuaticaValle];
GO
USE [AcuaticaValle];
GO
IF SCHEMA_ID(N'Seguridad') IS NOT NULL
BEGIN
    RAISERROR(N'La base [AcuaticaValle] ya tiene el modelo instalado. Use Publicar del proyecto para actualizarla.', 16, 1);
    SET NOEXEC ON;
END;
GO
SET XACT_ABORT ON;
GO

/* ---------------------------------------------------------------- Esquemas */
/* Esquema Seguridad: Usuarios, roles, permisos por módulo, sesiones y bitácora. */
CREATE SCHEMA [Seguridad]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuarios, roles, permisos por módulo, sesiones y bitácora.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad';
GO

/* Esquema Catalogo: Catálogos configurables y parámetros del sistema. */
CREATE SCHEMA [Catalogo]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogos configurables y parámetros del sistema.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo';
GO

/* Esquema Personas: Datos personales únicos (alumno, tutor o profesor). */
CREATE SCHEMA [Personas]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos personales únicos (alumno, tutor o profesor).',
    @level0type = N'SCHEMA', @level0name = N'Personas';
GO

/* Esquema Alumnos: Alumnos, tutores de menores y condiciones médicas. */
CREATE SCHEMA [Alumnos]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alumnos, tutores de menores y condiciones médicas.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos';
GO

/* Esquema Personal: Profesores y su tarifa por hora. */
CREATE SCHEMA [Personal]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Profesores y su tarifa por hora.',
    @level0type = N'SCHEMA', @level0name = N'Personal';
GO

/* Esquema Clases: Horarios, inscripciones, clases impartidas y asistencia. */
CREATE SCHEMA [Clases]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horarios, inscripciones, clases impartidas y asistencia.',
    @level0type = N'SCHEMA', @level0name = N'Clases';
GO

/* Esquema Finanzas: Tarifas, cargos, pagos de alumnos, nómina de profesores, gastos y caja. */
CREATE SCHEMA [Finanzas]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tarifas, cargos, pagos de alumnos, nómina de profesores, gastos y caja.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas';
GO

/* Esquema Operacion: Albercas, proveedores, mantenimiento y calidad del agua. */
CREATE SCHEMA [Operacion]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Albercas, proveedores, mantenimiento y calidad del agua.',
    @level0type = N'SCHEMA', @level0name = N'Operacion';
GO

/* Esquema Acceso: Lector de huella / control de entradas y salidas. */
CREATE SCHEMA [Acceso]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lector de huella / control de entradas y salidas.',
    @level0type = N'SCHEMA', @level0name = N'Acceso';
GO

/* Esquema Reporte: Dimensión calendario (temporadas) y cierres mensuales. */
CREATE SCHEMA [Reporte]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensión calendario (temporadas) y cierres mensuales.',
    @level0type = N'SCHEMA', @level0name = N'Reporte';
GO

/* ---------------------------------------------------------------- Secuencias */
/* Consecutivo de la matrícula del alumno (AV-000123). La usa el DEFAULT de Alumnos.Alumno.Matricula. */
CREATE SEQUENCE [Alumnos].[SeqMatricula]
    AS INT
    START WITH 1
    INCREMENT BY 1
    NO CYCLE
    CACHE 10;
GO

/* Consecutivo del folio del recibo de pago (P-0000123). La usa el DEFAULT de Finanzas.Pago.Folio. */
CREATE SEQUENCE [Finanzas].[SeqFolioPago]
    AS INT
    START WITH 1
    INCREMENT BY 1
    NO CYCLE
    CACHE 10;
GO

/* ---------------------------------------------------------------- Tablas (en orden de dependencias) */
/*============================================================================================
  Tabla      : Seguridad.Usuario
  Descripción: Usuarios que inician sesión en el sistema (administración, recepción, profesores).
  Atiende    : RSN01 · Configuración > Usuarios
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Seguridad].[Usuario]
(
    [UsuarioId] INT IDENTITY (1, 1) NOT NULL,
    [NombreUsuario] NVARCHAR(50) NOT NULL,
    [NombreCompleto] NVARCHAR(150) NOT NULL,
    [Correo] NVARCHAR(150) NULL,
    [Telefono] VARCHAR(20) NULL,
    [PasswordHash] VARCHAR(256) NOT NULL,
    [DebeCambiarPassword] BIT CONSTRAINT [DF_Usuario_DebeCambiarPassword] DEFAULT (1) NOT NULL,
    [IntentosFallidos] TINYINT CONSTRAINT [DF_Usuario_IntentosFallidos] DEFAULT (0) NOT NULL,
    [BloqueadoHastaUtc] DATETIME2(0) NULL,
    [UltimoAccesoUtc] DATETIME2(0) NULL,
    [Activo] BIT CONSTRAINT [DF_Usuario_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Usuario_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Usuario] PRIMARY KEY CLUSTERED ([UsuarioId]),
    CONSTRAINT [UQ_Usuario_NombreUsuario] UNIQUE ([NombreUsuario]),
    CONSTRAINT [FK_Usuario_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Usuario_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Usuario_Correo]
    ON [Seguridad].[Usuario] ([Correo])
    WHERE [Correo] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuarios que inician sesión en el sistema (administración, recepción, profesores).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Login. Único.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'NombreUsuario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Único cuando existe (índice filtrado).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'Correo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hash PBKDF2/Argon2 con sal y parámetros. Nunca la contraseña.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'PasswordHash';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obliga a cambiar la contraseña en el siguiente inicio.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'DebeCambiarPassword';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bloqueo temporal por intentos fallidos.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'BloqueadoHastaUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Usuario', @level2type = N'COLUMN', @level2name = N'RowVer';
GO

/*============================================================================================
  Tabla      : Seguridad.Rol
  Descripción: Roles del sistema (Administrador, Recepción, Profesor…).
  Atiende    : RSN01 · Roles
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Seguridad].[Rol]
(
    [RolId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Clave] VARCHAR(30) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [EsSistema] BIT CONSTRAINT [DF_Rol_EsSistema] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Rol_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Rol_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Rol] PRIMARY KEY CLUSTERED ([RolId]),
    CONSTRAINT [UQ_Rol_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Rol_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Rol_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Roles del sistema (Administrador, Recepción, Profesor…).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'RolId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ADMIN, RECEPCION, PROFESOR…',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = no se puede borrar ni renombrar desde la UI.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'EsSistema';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Rol', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Seguridad.UsuarioRol
  Descripción: Roles asignados a cada usuario (N:M).
  Atiende    : RSN01 · Tipo de usuario
============================================================================================*/
CREATE TABLE [Seguridad].[UsuarioRol]
(
    [UsuarioId] INT NOT NULL,
    [RolId] SMALLINT NOT NULL,
    [FechaAsignacionUtc] DATETIME2(0) CONSTRAINT [DF_UsuarioRol_FechaAsignacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [AsignadoPor] INT NULL,
    CONSTRAINT [PK_UsuarioRol] PRIMARY KEY CLUSTERED ([UsuarioId], [RolId]),
    CONSTRAINT [FK_UsuarioRol_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_UsuarioRol_RolId] FOREIGN KEY ([RolId]) REFERENCES [Seguridad].[Rol] ([RolId]),
    CONSTRAINT [FK_UsuarioRol_AsignadoPor] FOREIGN KEY ([AsignadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Roles asignados a cada usuario (N:M).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'UsuarioRol';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'UsuarioRol', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'UsuarioRol', @level2type = N'COLUMN', @level2name = N'RolId';
GO

/*============================================================================================
  Tabla      : Seguridad.Modulo
  Descripción: Módulos / secciones del menú (Dashboard, Control de alumnos, Calendario, Reportes, Configuración).
  Atiende    : RSN01 · Permiso a módulos
============================================================================================*/
CREATE TABLE [Seguridad].[Modulo]
(
    [ModuloId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [ModuloPadreId] SMALLINT NULL,
    [Clave] VARCHAR(40) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [Ruta] VARCHAR(120) NULL,
    [Icono] VARCHAR(50) NULL,
    [Orden] TINYINT CONSTRAINT [DF_Modulo_Orden] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Modulo_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Modulo] PRIMARY KEY CLUSTERED ([ModuloId]),
    CONSTRAINT [UQ_Modulo_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Modulo_ModuloPadreId] FOREIGN KEY ([ModuloPadreId]) REFERENCES [Seguridad].[Modulo] ([ModuloId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Módulos / secciones del menú (Dashboard, Control de alumnos, Calendario, Reportes, Configuración).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'ModuloId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para submenús.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'ModuloPadreId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DASHBOARD, ALUMNOS, CALENDARIO, REPORTES, CONFIGURACION',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ruta del front (/alumnos).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Modulo', @level2type = N'COLUMN', @level2name = N'Ruta';
GO

/*============================================================================================
  Tabla      : Seguridad.Permiso
  Descripción: Acciones permitidas dentro de un módulo (ver, crear, editar, eliminar, exportar…).
  Atiende    : RSN01 · Permiso a funciones
============================================================================================*/
CREATE TABLE [Seguridad].[Permiso]
(
    [PermisoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [ModuloId] SMALLINT NOT NULL,
    [Clave] VARCHAR(60) NOT NULL,
    [Nombre] NVARCHAR(100) NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [Activo] BIT CONSTRAINT [DF_Permiso_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Permiso] PRIMARY KEY CLUSTERED ([PermisoId]),
    CONSTRAINT [UQ_Permiso_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Permiso_ModuloId] FOREIGN KEY ([ModuloId]) REFERENCES [Seguridad].[Modulo] ([ModuloId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Acciones permitidas dentro de un módulo (ver, crear, editar, eliminar, exportar…).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Permiso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Permiso', @level2type = N'COLUMN', @level2name = N'PermisoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. alumnos.ver, alumnos.crear, pagos.registrar, reportes.exportar',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Permiso', @level2type = N'COLUMN', @level2name = N'Clave';
GO

/*============================================================================================
  Tabla      : Seguridad.RolPermiso
  Descripción: Permisos otorgados a cada rol (N:M).
  Atiende    : RSN01
============================================================================================*/
CREATE TABLE [Seguridad].[RolPermiso]
(
    [RolId] SMALLINT NOT NULL,
    [PermisoId] SMALLINT NOT NULL,
    [FechaAsignacionUtc] DATETIME2(0) CONSTRAINT [DF_RolPermiso_FechaAsignacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [AsignadoPor] INT NULL,
    CONSTRAINT [PK_RolPermiso] PRIMARY KEY CLUSTERED ([RolId], [PermisoId]),
    CONSTRAINT [FK_RolPermiso_RolId] FOREIGN KEY ([RolId]) REFERENCES [Seguridad].[Rol] ([RolId]),
    CONSTRAINT [FK_RolPermiso_PermisoId] FOREIGN KEY ([PermisoId]) REFERENCES [Seguridad].[Permiso] ([PermisoId]),
    CONSTRAINT [FK_RolPermiso_AsignadoPor] FOREIGN KEY ([AsignadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Permisos otorgados a cada rol (N:M).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'RolPermiso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'RolPermiso', @level2type = N'COLUMN', @level2name = N'RolId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'RolPermiso', @level2type = N'COLUMN', @level2name = N'PermisoId';
GO

/*============================================================================================
  Tabla      : Seguridad.SesionUsuario
  Descripción: Sesiones abiertas (token de renovación). Permite cerrar sesiones desde el servidor.
  Atiende    : Login
============================================================================================*/
CREATE TABLE [Seguridad].[SesionUsuario]
(
    [SesionId] BIGINT IDENTITY (1, 1) NOT NULL,
    [UsuarioId] INT NOT NULL,
    [RefreshTokenHash] CHAR(64) NOT NULL,
    [FechaInicioUtc] DATETIME2(0) CONSTRAINT [DF_SesionUsuario_FechaInicioUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [FechaExpiraUtc] DATETIME2(0) NOT NULL,
    [FechaCierreUtc] DATETIME2(0) NULL,
    [MotivoCierre] VARCHAR(30) NULL,
    [Ip] VARCHAR(45) NULL,
    [UserAgent] NVARCHAR(400) NULL,
    CONSTRAINT [PK_SesionUsuario] PRIMARY KEY CLUSTERED ([SesionId]),
    CONSTRAINT [UQ_SesionUsuario_RefreshTokenHash] UNIQUE ([RefreshTokenHash]),
    CONSTRAINT [FK_SesionUsuario_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE NONCLUSTERED INDEX [IX_SesionUsuario_Usuario]
    ON [Seguridad].[SesionUsuario] ([UsuarioId], [FechaCierreUtc]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sesiones abiertas (token de renovación). Permite cerrar sesiones desde el servidor.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario', @level2type = N'COLUMN', @level2name = N'SesionId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'SHA-256 del token de renovación vigente.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario', @level2type = N'COLUMN', @level2name = N'RefreshTokenHash';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LOGOUT, EXPIRADA, REVOCADA',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'SesionUsuario', @level2type = N'COLUMN', @level2name = N'MotivoCierre';
GO

/*============================================================================================
  Tabla      : Seguridad.Bitacora
  Descripción: Auditoría de acciones (quién hizo qué y cuándo). Sin FK a propósito: registrar nunca debe fallar.
  Atiende    : Seguridad / trazabilidad
============================================================================================*/
CREATE TABLE [Seguridad].[Bitacora]
(
    [BitacoraId] BIGINT IDENTITY (1, 1) NOT NULL,
    [FechaUtc] DATETIME2(3) CONSTRAINT [DF_Bitacora_FechaUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [UsuarioId] INT NULL,
    [Accion] VARCHAR(50) NOT NULL,
    [Entidad] VARCHAR(60) NULL,
    [EntidadId] VARCHAR(40) NULL,
    [ValoresAnteriores] NVARCHAR(MAX) NULL,
    [ValoresNuevos] NVARCHAR(MAX) NULL,
    [Exito] BIT CONSTRAINT [DF_Bitacora_Exito] DEFAULT (1) NOT NULL,
    [Ip] VARCHAR(45) NULL,
    CONSTRAINT [PK_Bitacora] PRIMARY KEY CLUSTERED ([BitacoraId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Bitacora_Fecha]
    ON [Seguridad].[Bitacora] ([FechaUtc] DESC)
    INCLUDE ([Accion], [UsuarioId]);
GO
CREATE NONCLUSTERED INDEX [IX_Bitacora_Entidad]
    ON [Seguridad].[Bitacora] ([Entidad], [EntidadId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Auditoría de acciones (quién hizo qué y cuándo). Sin FK a propósito: registrar nunca debe fallar.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'BitacoraId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sin FK a propósito.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'LOGIN, CREAR, EDITAR, ELIMINAR, CANCELAR_PAGO…',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'Accion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla afectada (Finanzas.Pago).',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'Entidad';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'ValoresAnteriores';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'JSON.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad', @level1type = N'TABLE', @level1name = N'Bitacora', @level2type = N'COLUMN', @level2name = N'ValoresNuevos';
GO

/*============================================================================================
  Tabla      : Catalogo.TipoPeriodoPago
  Descripción: Por clase, semanal, quincenal o mensual.
  Atiende    : RFN03 · Tipo de pago
============================================================================================*/
CREATE TABLE [Catalogo].[TipoPeriodoPago]
(
    [TipoPeriodoPagoId] TINYINT NOT NULL,
    [Clave] VARCHAR(20) NOT NULL,
    [Nombre] NVARCHAR(40) NOT NULL,
    [DiasDuracion] SMALLINT NULL,
    [Orden] TINYINT CONSTRAINT [DF_TipoPeriodoPago_Orden] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_TipoPeriodoPago_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_TipoPeriodoPago] PRIMARY KEY CLUSTERED ([TipoPeriodoPagoId]),
    CONSTRAINT [UQ_TipoPeriodoPago_Clave] UNIQUE ([Clave])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Por clase, semanal, quincenal o mensual.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago', @level2type = N'COLUMN', @level2name = N'TipoPeriodoPagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CLASE, SEMANAL, QUINCENAL, MENSUAL',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1, 7, 15 o NULL = mes calendario. Solo propone la fecha de fin; el cobro sale de las clases reales del periodo.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoPeriodoPago', @level2type = N'COLUMN', @level2name = N'DiasDuracion';
GO

/*============================================================================================
  Tabla      : Catalogo.MetodoPago
  Descripción: Forma de pago: efectivo, transferencia, tarjeta…
  Atiende    : RFN03
============================================================================================*/
CREATE TABLE [Catalogo].[MetodoPago]
(
    [MetodoPagoId] TINYINT NOT NULL,
    [Clave] VARCHAR(20) NOT NULL,
    [Nombre] NVARCHAR(40) NOT NULL,
    [RequiereReferencia] BIT CONSTRAINT [DF_MetodoPago_RequiereReferencia] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_MetodoPago_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_MetodoPago] PRIMARY KEY CLUSTERED ([MetodoPagoId]),
    CONSTRAINT [UQ_MetodoPago_Clave] UNIQUE ([Clave])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Forma de pago: efectivo, transferencia, tarjeta…',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'MetodoPago';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'MetodoPago', @level2type = N'COLUMN', @level2name = N'MetodoPagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Transferencia/tarjeta exigen número de referencia.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'MetodoPago', @level2type = N'COLUMN', @level2name = N'RequiereReferencia';
GO

/*============================================================================================
  Tabla      : Catalogo.ConceptoCobro
  Descripción: Qué se le cobra al alumno: mensualidad, inscripción, clase suelta, uniforme…
  Atiende    : RFN03 (expansión)
============================================================================================*/
CREATE TABLE [Catalogo].[ConceptoCobro]
(
    [ConceptoCobroId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Clave] VARCHAR(30) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [EsColegiatura] BIT CONSTRAINT [DF_ConceptoCobro_EsColegiatura] DEFAULT (1) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_ConceptoCobro_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_ConceptoCobro] PRIMARY KEY CLUSTERED ([ConceptoCobroId]),
    CONSTRAINT [UQ_ConceptoCobro_Clave] UNIQUE ([Clave])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Qué se le cobra al alumno: mensualidad, inscripción, clase suelta, uniforme…',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'ConceptoCobro';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'ConceptoCobro', @level2type = N'COLUMN', @level2name = N'ConceptoCobroId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = cubre clases (mensualidad / semana / clase).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'ConceptoCobro', @level2type = N'COLUMN', @level2name = N'EsColegiatura';
GO

/*============================================================================================
  Tabla      : Catalogo.Nivel
  Descripción: Nivel o grupo de natación (bebés, principiante, intermedio, avanzado, competencia).
  Atiende    : Expansión (grupos por nivel)
============================================================================================*/
CREATE TABLE [Catalogo].[Nivel]
(
    [NivelId] TINYINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(50) NOT NULL,
    [EdadMinima] TINYINT NULL,
    [EdadMaxima] TINYINT NULL,
    [Orden] TINYINT CONSTRAINT [DF_Nivel_Orden] DEFAULT (0) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Nivel_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_Nivel] PRIMARY KEY CLUSTERED ([NivelId]),
    CONSTRAINT [UQ_Nivel_Nombre] UNIQUE ([Nombre])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nivel o grupo de natación (bebés, principiante, intermedio, avanzado, competencia).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Nivel';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Nivel', @level2type = N'COLUMN', @level2name = N'NivelId';
GO

/*============================================================================================
  Tabla      : Catalogo.CategoriaGasto
  Descripción: Clasificación de gastos (químicos, mantenimiento, servicios, renta, equipo…). Admite subcategorías.
  Atiende    : Reporte de gastos
============================================================================================*/
CREATE TABLE [Catalogo].[CategoriaGasto]
(
    [CategoriaGastoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [CategoriaPadreId] SMALLINT NULL,
    [Clave] VARCHAR(30) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_CategoriaGasto_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_CategoriaGasto] PRIMARY KEY CLUSTERED ([CategoriaGastoId]),
    CONSTRAINT [UQ_CategoriaGasto_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_CategoriaGasto_CategoriaPadreId] FOREIGN KEY ([CategoriaPadreId]) REFERENCES [Catalogo].[CategoriaGasto] ([CategoriaGastoId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clasificación de gastos (químicos, mantenimiento, servicios, renta, equipo…). Admite subcategorías.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'CategoriaGasto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'CategoriaGasto', @level2type = N'COLUMN', @level2name = N'CategoriaGastoId';
GO

/*============================================================================================
  Tabla      : Catalogo.TipoMantenimiento
  Descripción: Tipos de mantenimiento de la alberca (limpieza, filtros, bomba, calentador, químicos…).
  Atiende    : Mantenimiento de alberca
============================================================================================*/
CREATE TABLE [Catalogo].[TipoMantenimiento]
(
    [TipoMantenimientoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [EsPreventivo] BIT CONSTRAINT [DF_TipoMantenimiento_EsPreventivo] DEFAULT (1) NOT NULL,
    [FrecuenciaDias] SMALLINT NULL,
    [Activo] BIT CONSTRAINT [DF_TipoMantenimiento_Activo] DEFAULT (1) NOT NULL,
    CONSTRAINT [PK_TipoMantenimiento] PRIMARY KEY CLUSTERED ([TipoMantenimientoId]),
    CONSTRAINT [UQ_TipoMantenimiento_Nombre] UNIQUE ([Nombre])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipos de mantenimiento de la alberca (limpieza, filtros, bomba, calentador, químicos…).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento', @level2type = N'COLUMN', @level2name = N'TipoMantenimientoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 preventivo, 0 correctivo.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento', @level2type = N'COLUMN', @level2name = N'EsPreventivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para programar el siguiente mantenimiento preventivo.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'TipoMantenimiento', @level2type = N'COLUMN', @level2name = N'FrecuenciaDias';
GO

/*============================================================================================
  Tabla      : Catalogo.Temporada
  Descripción: Temporadas del negocio (alta, baja, vacaciones de verano, decembrina…).
  Atiende    : Reporte de temporadas bajas
============================================================================================*/
CREATE TABLE [Catalogo].[Temporada]
(
    [TemporadaId] TINYINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(50) NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [Color] CHAR(7) NULL,
    CONSTRAINT [PK_Temporada] PRIMARY KEY CLUSTERED ([TemporadaId]),
    CONSTRAINT [UQ_Temporada_Nombre] UNIQUE ([Nombre])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Temporadas del negocio (alta, baja, vacaciones de verano, decembrina…).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Temporada';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Temporada', @level2type = N'COLUMN', @level2name = N'TemporadaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'#RRGGBB para gráficas.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Temporada', @level2type = N'COLUMN', @level2name = N'Color';
GO

/*============================================================================================
  Tabla      : Catalogo.Parametro
  Descripción: Parámetros del sistema clave/valor (días de aviso de vencimiento, tolerancia de retardo, datos de la escuela…).
  Atiende    : Configuración
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Catalogo].[Parametro]
(
    [ParametroId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Clave] VARCHAR(60) NOT NULL,
    [Valor] NVARCHAR(500) NOT NULL,
    [TipoDato] VARCHAR(10) CONSTRAINT [DF_Parametro_TipoDato] DEFAULT ('TEXTO') NOT NULL,
    [Descripcion] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Parametro_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Parametro] PRIMARY KEY CLUSTERED ([ParametroId]),
    CONSTRAINT [UQ_Parametro_Clave] UNIQUE ([Clave]),
    CONSTRAINT [FK_Parametro_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Parametro_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Parametro_TipoDato] CHECK ([TipoDato] IN ('TEXTO','ENTERO','DECIMAL','BOOL','FECHA','JSON'))
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Parámetros del sistema clave/valor (días de aviso de vencimiento, tolerancia de retardo, datos de la escuela…).',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'ParametroId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'DIAS_AVISO_VENCIMIENTO, MINUTOS_TOLERANCIA, BLOQUEAR_ACCESO_CON_ADEUDO…',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'Clave';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Catalogo', @level1type = N'TABLE', @level1name = N'Parametro', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Personas.Persona
  Descripción: Datos personales y de contacto de cualquier persona: alumno, padre/madre/tutor o profesor. Se captura una sola vez; un padre que también es alumno es la misma Persona.
  Atiende    : RFN01 / RFN04 · Datos personales sin duplicar
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Personas].[Persona]
(
    [PersonaId] INT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [ApellidoPaterno] NVARCHAR(60) NOT NULL,
    [ApellidoMaterno] NVARCHAR(60) NULL,
    [NombreCompleto] AS (CAST([Nombre] + N' ' + [ApellidoPaterno] + ISNULL(N' ' + [ApellidoMaterno], N'') AS NVARCHAR(210))) PERSISTED NOT NULL,
    [FechaNacimiento] DATE NULL,
    [CURP] VARCHAR(18) NULL,
    [Telefono] VARCHAR(20) NULL,
    [TelefonoAlterno] VARCHAR(20) NULL,
    [Correo] NVARCHAR(150) NULL,
    [Domicilio] NVARCHAR(300) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Persona_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Persona] PRIMARY KEY CLUSTERED ([PersonaId]),
    CONSTRAINT [FK_Persona_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Persona_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Persona_CURP]
    ON [Personas].[Persona] ([CURP])
    WHERE [CURP] IS NOT NULL;
GO
CREATE NONCLUSTERED INDEX [IX_Persona_NombreCompleto]
    ON [Personas].[Persona] ([NombreCompleto])
    INCLUDE ([Telefono], [FechaNacimiento]);
GO
CREATE NONCLUSTERED INDEX [IX_Persona_Telefono]
    ON [Personas].[Persona] ([Telefono])
    INCLUDE ([NombreCompleto])
    WHERE [Telefono] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos personales y de contacto de cualquier persona: alumno, padre/madre/tutor o profesor. Se captura una sola vez; un padre que también es alumno es la misma Persona.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'PersonaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Calculada y persistida: para búsqueda y listados.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'NombreCompleto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Obligatoria para alumnos (la valida el SP). La edad y si es menor de edad se calculan.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'FechaNacimiento';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Opcional. Única cuando existe: ayuda a detectar personas repetidas.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'CURP';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Personas', @level1type = N'TABLE', @level1name = N'Persona', @level2type = N'COLUMN', @level2name = N'RowVer';
GO

/*============================================================================================
  Tabla      : Alumnos.Alumno
  Descripción: Alumno de la escuela (rol de una Persona). Se registra sin necesidad de capturar pago (nota 09/03/2026).
  Atiende    : RFN01 · Control de alumnos / Detalles del alumno
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Alumnos].[Alumno]
(
    [AlumnoId] INT IDENTITY (1, 1) NOT NULL,
    [PersonaId] INT NOT NULL,
    [Matricula] VARCHAR(20) CONSTRAINT [DF_Alumno_Matricula] DEFAULT (CONCAT('AV-', RIGHT(CONCAT('000000', NEXT VALUE FOR [Alumnos].[SeqMatricula]), 6))) NOT NULL,
    [PadeceEnfermedad] BIT CONSTRAINT [DF_Alumno_PadeceEnfermedad] DEFAULT (0) NOT NULL,
    [NivelId] TINYINT NULL,
    [FechaIngreso] DATE CONSTRAINT [DF_Alumno_FechaIngreso] DEFAULT (CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time (Mexico)' AS DATE)) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Alumno_Activo] DEFAULT (1) NOT NULL,
    [FechaBaja] DATE NULL,
    [MotivoBaja] NVARCHAR(250) NULL,
    [FotoUrl] VARCHAR(300) NULL,
    [Observaciones] NVARCHAR(500) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Alumno_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Alumno] PRIMARY KEY CLUSTERED ([AlumnoId]),
    CONSTRAINT [UQ_Alumno_PersonaId] UNIQUE ([PersonaId]),
    CONSTRAINT [UQ_Alumno_Matricula] UNIQUE ([Matricula]),
    CONSTRAINT [FK_Alumno_PersonaId] FOREIGN KEY ([PersonaId]) REFERENCES [Personas].[Persona] ([PersonaId]),
    CONSTRAINT [FK_Alumno_NivelId] FOREIGN KEY ([NivelId]) REFERENCES [Catalogo].[Nivel] ([NivelId]),
    CONSTRAINT [FK_Alumno_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Alumno_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Alumno_Activo]
    ON [Alumnos].[Alumno] ([Activo])
    INCLUDE ([PersonaId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Alumno de la escuela (rol de una Persona). Se registra sin necesidad de capturar pago (nota 09/03/2026).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'AlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre, fecha de nacimiento, teléfono y domicilio viven en Persona.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'PersonaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Folio visible del alumno (ej. AV-000123).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'Matricula';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Sí/No. El detalle va en AlumnoCondicionMedica.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'PadeceEnfermedad';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de registro / ingreso.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'FechaIngreso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estatus Activo / Inactivo.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'Activo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para analizar deserción por temporada.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'MotivoBaja';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'Alumno', @level2type = N'COLUMN', @level2name = N'RowVer';
GO

/*============================================================================================
  Tabla      : Alumnos.AlumnoTutor
  Descripción: Padre, madre o tutor de un alumno MENOR de edad (solo se captura en ese caso). El tutor es una Persona: puede ser también alumno o tutor de varios hermanos.
  Atiende    : RFN01 · Padre, madre o tutor (solo menores)
============================================================================================*/
CREATE TABLE [Alumnos].[AlumnoTutor]
(
    [AlumnoId] INT NOT NULL,
    [TutorPersonaId] INT NOT NULL,
    [Parentesco] VARCHAR(15) NOT NULL,
    [EsResponsablePago] BIT CONSTRAINT [DF_AlumnoTutor_EsResponsablePago] DEFAULT (1) NOT NULL,
    [EsContactoEmergencia] BIT CONSTRAINT [DF_AlumnoTutor_EsContactoEmergencia] DEFAULT (1) NOT NULL,
    [PuedeRecoger] BIT CONSTRAINT [DF_AlumnoTutor_PuedeRecoger] DEFAULT (1) NOT NULL,
    [FechaRegistroUtc] DATETIME2(0) CONSTRAINT [DF_AlumnoTutor_FechaRegistroUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    CONSTRAINT [PK_AlumnoTutor] PRIMARY KEY CLUSTERED ([AlumnoId], [TutorPersonaId]),
    CONSTRAINT [FK_AlumnoTutor_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AlumnoTutor_TutorPersonaId] FOREIGN KEY ([TutorPersonaId]) REFERENCES [Personas].[Persona] ([PersonaId]),
    CONSTRAINT [CK_AlumnoTutor_Parentesco] CHECK ([Parentesco] IN ('MADRE','PADRE','TUTOR','ABUELO','OTRO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_AlumnoTutor_Tutor]
    ON [Alumnos].[AlumnoTutor] ([TutorPersonaId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Padre, madre o tutor de un alumno MENOR de edad (solo se captura en ese caso). El tutor es una Persona: puede ser también alumno o tutor de varios hermanos.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoTutor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoTutor', @level2type = N'COLUMN', @level2name = N'AlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Persona que es tutor. No puede ser la misma Persona del alumno (lo valida el SP).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoTutor', @level2type = N'COLUMN', @level2name = N'TutorPersonaId';
GO

/*============================================================================================
  Tabla      : Alumnos.AlumnoCondicionMedica
  Descripción: Enfermedades, alergias o lesiones del alumno (puede tener varias).
  Atiende    : RFN01 · ¿Padece enfermedad? / Nombre de enfermedad
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Alumnos].[AlumnoCondicionMedica]
(
    [CondicionMedicaId] INT IDENTITY (1, 1) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [Tipo] VARCHAR(12) CONSTRAINT [DF_AlumnoCondicionMedica_Tipo] DEFAULT ('ENFERMEDAD') NOT NULL,
    [Nombre] NVARCHAR(120) NOT NULL,
    [Indicaciones] NVARCHAR(500) NULL,
    [Activa] BIT CONSTRAINT [DF_AlumnoCondicionMedica_Activa] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_AlumnoCondicionMedica_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_AlumnoCondicionMedica] PRIMARY KEY CLUSTERED ([CondicionMedicaId]),
    CONSTRAINT [FK_AlumnoCondicionMedica_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AlumnoCondicionMedica_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_AlumnoCondicionMedica_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_AlumnoCondicionMedica_Tipo] CHECK ([Tipo] IN ('ENFERMEDAD','ALERGIA','LESION','OTRO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_AlumnoCondicionMedica_Alumno]
    ON [Alumnos].[AlumnoCondicionMedica] ([AlumnoId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Enfermedades, alergias o lesiones del alumno (puede tener varias).',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'CondicionMedicaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. Hipertensión, asma.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'Nombre';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Qué hacer en caso de emergencia.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'Indicaciones';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Alumnos', @level1type = N'TABLE', @level1name = N'AlumnoCondicionMedica', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Personal.Profesor
  Descripción: Profesores / instructores (rol de una Persona). Opcionalmente ligados a un usuario del sistema.
  Atiende    : RFN04 · Profesores
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Personal].[Profesor]
(
    [ProfesorId] INT IDENTITY (1, 1) NOT NULL,
    [PersonaId] INT NOT NULL,
    [UsuarioId] INT NULL,
    [Especialidad] NVARCHAR(100) NULL,
    [ColorCalendario] CHAR(7) NULL,
    [FechaIngreso] DATE CONSTRAINT [DF_Profesor_FechaIngreso] DEFAULT (CAST(SYSDATETIMEOFFSET() AT TIME ZONE 'Central Standard Time (Mexico)' AS DATE)) NOT NULL,
    [Activo] BIT CONSTRAINT [DF_Profesor_Activo] DEFAULT (1) NOT NULL,
    [FechaBaja] DATE NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Profesor_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Profesor] PRIMARY KEY CLUSTERED ([ProfesorId]),
    CONSTRAINT [UQ_Profesor_PersonaId] UNIQUE ([PersonaId]),
    CONSTRAINT [FK_Profesor_PersonaId] FOREIGN KEY ([PersonaId]) REFERENCES [Personas].[Persona] ([PersonaId]),
    CONSTRAINT [FK_Profesor_UsuarioId] FOREIGN KEY ([UsuarioId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Profesor_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Profesor_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Profesor_Usuario]
    ON [Personal].[Profesor] ([UsuarioId])
    WHERE [UsuarioId] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Profesores / instructores (rol de una Persona). Opcionalmente ligados a un usuario del sistema.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'ProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre, edad, teléfono y domicilio viven en Persona.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'PersonaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el profesor entra al sistema.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'UsuarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Color del profesor en el calendario (#RRGGBB).',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'ColorCalendario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'Profesor', @level2type = N'COLUMN', @level2name = N'RowVer';
GO

/*============================================================================================
  Tabla      : Personal.ProfesorTarifa
  Descripción: Pago por hora del profesor con vigencia (historial de aumentos).
  Atiende    : RFN04 · Pago por horas
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Personal].[ProfesorTarifa]
(
    [ProfesorTarifaId] INT IDENTITY (1, 1) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [MontoPorHora] DECIMAL(10,2) NOT NULL,
    [VigenteDesde] DATE NOT NULL,
    [VigenteHasta] DATE NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_ProfesorTarifa_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_ProfesorTarifa] PRIMARY KEY CLUSTERED ([ProfesorTarifaId]),
    CONSTRAINT [FK_ProfesorTarifa_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_ProfesorTarifa_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_ProfesorTarifa_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_ProfesorTarifa_MontoPorHora] CHECK ([MontoPorHora] >= 0),
    CONSTRAINT [CK_ProfesorTarifa_Vigencia] CHECK ([VigenteHasta] IS NULL OR [VigenteHasta] >= [VigenteDesde])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_ProfesorTarifa_Vigencia]
    ON [Personal].[ProfesorTarifa] ([ProfesorId], [VigenteDesde]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago por hora del profesor con vigencia (historial de aumentos).',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'ProfesorTarifaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = vigente.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'VigenteHasta';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Personal', @level1type = N'TABLE', @level1name = N'ProfesorTarifa', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Operacion.Alberca
  Descripción: Albercas / instalaciones de la escuela.
  Atiende    : Mantenimiento de alberca
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[Alberca]
(
    [AlbercaId] TINYINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [NumeroCarriles] TINYINT NULL,
    [CapacidadMaxima] SMALLINT NULL,
    [VolumenLitros] INT NULL,
    [ProfundidadMinM] DECIMAL(3,2) NULL,
    [ProfundidadMaxM] DECIMAL(3,2) NULL,
    [Activa] BIT CONSTRAINT [DF_Alberca_Activa] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Alberca_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Alberca] PRIMARY KEY CLUSTERED ([AlbercaId]),
    CONSTRAINT [UQ_Alberca_Nombre] UNIQUE ([Nombre]),
    CONSTRAINT [FK_Alberca_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Alberca_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Albercas / instalaciones de la escuela.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'AlbercaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Personas simultáneas.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'CapacidadMaxima';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Para dosificar químicos.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'VolumenLitros';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Alberca', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

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

/*============================================================================================
  Tabla      : Clases.AlumnoHorario
  Descripción: Inscripción del alumno a un bloque de horario (Registrar horario: Lunes 8–9, Miércoles 8–9…).
  Atiende    : RFN02 · Registro de horario
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[AlumnoHorario]
(
    [AlumnoHorarioId] INT IDENTITY (1, 1) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [ClaseHorarioId] INT NOT NULL,
    [FechaInicio] DATE NOT NULL,
    [FechaFin] DATE NULL,
    [Activo] BIT CONSTRAINT [DF_AlumnoHorario_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_AlumnoHorario_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_AlumnoHorario] PRIMARY KEY CLUSTERED ([AlumnoHorarioId]),
    CONSTRAINT [FK_AlumnoHorario_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AlumnoHorario_ClaseHorarioId] FOREIGN KEY ([ClaseHorarioId]) REFERENCES [Clases].[ClaseHorario] ([ClaseHorarioId]),
    CONSTRAINT [FK_AlumnoHorario_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_AlumnoHorario_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_AlumnoHorario_Activo]
    ON [Clases].[AlumnoHorario] ([AlumnoId], [ClaseHorarioId])
    WHERE [Activo] = 1;
GO
CREATE NONCLUSTERED INDEX [IX_AlumnoHorario_Clase]
    ON [Clases].[AlumnoHorario] ([ClaseHorarioId], [Activo])
    INCLUDE ([AlumnoId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Inscripción del alumno a un bloque de horario (Registrar horario: Lunes 8–9, Miércoles 8–9…).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'AlumnoHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = sigue inscrito.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'FechaFin';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AlumnoHorario', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Reporte.Calendario
  Descripción: Dimensión fecha: un renglón por día con temporada, festivos y días operativos. Base de todos los reportes por periodo.
  Atiende    : RFN06 · Reportes por semana/mes, temporadas bajas
============================================================================================*/
CREATE TABLE [Reporte].[Calendario]
(
    [Fecha] DATE NOT NULL,
    [Anio] SMALLINT NOT NULL,
    [Mes] TINYINT NOT NULL,
    [NombreMes] NVARCHAR(12) NOT NULL,
    [Trimestre] TINYINT NOT NULL,
    [SemanaAnio] TINYINT NOT NULL,
    [SemanaMes] TINYINT NOT NULL,
    [DiaSemana] TINYINT NOT NULL,
    [NombreDia] NVARCHAR(12) NOT NULL,
    [EsFinDeSemana] BIT NOT NULL,
    [EsFeriado] BIT CONSTRAINT [DF_Calendario_EsFeriado] DEFAULT (0) NOT NULL,
    [DescripcionFeriado] NVARCHAR(100) NULL,
    [EsDiaOperativo] BIT CONSTRAINT [DF_Calendario_EsDiaOperativo] DEFAULT (1) NOT NULL,
    [TemporadaId] TINYINT NULL,
    CONSTRAINT [PK_Calendario] PRIMARY KEY CLUSTERED ([Fecha]),
    CONSTRAINT [FK_Calendario_TemporadaId] FOREIGN KEY ([TemporadaId]) REFERENCES [Catalogo].[Temporada] ([TemporadaId])
);
GO
CREATE NONCLUSTERED INDEX [IX_Calendario_AnioMes]
    ON [Reporte].[Calendario] ([Anio], [Mes])
    INCLUDE ([SemanaMes], [TemporadaId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dimensión fecha: un renglón por día con temporada, festivos y días operativos. Base de todos los reportes por periodo.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'Fecha';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Semana ISO.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'SemanaAnio';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Semana 1–5 del mes (reporte semanal).',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'SemanaMes';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = lunes … 7 = domingo.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'DiaSemana';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 = escuela cerrada.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'Calendario', @level2type = N'COLUMN', @level2name = N'EsDiaOperativo';
GO

/*============================================================================================
  Tabla      : Clases.SesionClase
  Descripción: Clase real en una fecha. Registra suplencias, cancelaciones y las horas que impartió el profesor (base de su pago).
  Atiende    : RFN04 · Calendario / Profesores en turno / Reportes
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[SesionClase]
(
    [SesionClaseId] INT IDENTITY (1, 1) NOT NULL,
    [ClaseHorarioId] INT NULL,
    [Fecha] DATE NOT NULL,
    [HoraInicio] TIME(0) NOT NULL,
    [HoraFin] TIME(0) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [EsSuplencia] BIT CONSTRAINT [DF_SesionClase_EsSuplencia] DEFAULT (0) NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_SesionClase_Estatus] DEFAULT ('PROGRAMADA') NOT NULL,
    [MotivoCancelacion] NVARCHAR(250) NULL,
    [EntradaProfesorUtc] DATETIME2(0) NULL,
    [SalidaProfesorUtc] DATETIME2(0) NULL,
    [HorasPagables] DECIMAL(4,2) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_SesionClase_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_SesionClase] PRIMARY KEY CLUSTERED ([SesionClaseId]),
    CONSTRAINT [FK_SesionClase_ClaseHorarioId] FOREIGN KEY ([ClaseHorarioId]) REFERENCES [Clases].[ClaseHorario] ([ClaseHorarioId]),
    CONSTRAINT [FK_SesionClase_Fecha] FOREIGN KEY ([Fecha]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_SesionClase_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_SesionClase_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_SesionClase_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_SesionClase_Estatus] CHECK ([Estatus] IN ('PROGRAMADA','IMPARTIDA','CANCELADA')),
    CONSTRAINT [CK_SesionClase_Horas] CHECK ([HoraFin] > [HoraInicio])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_SesionClase_HorarioFecha]
    ON [Clases].[SesionClase] ([ClaseHorarioId], [Fecha])
    WHERE [ClaseHorarioId] IS NOT NULL;
GO
CREATE NONCLUSTERED INDEX [IX_SesionClase_Fecha]
    ON [Clases].[SesionClase] ([Fecha], [HoraInicio])
    INCLUDE ([ProfesorId], [Estatus]);
GO
CREATE NONCLUSTERED INDEX [IX_SesionClase_Profesor]
    ON [Clases].[SesionClase] ([ProfesorId], [Fecha])
    INCLUDE ([Estatus], [HorasPagables]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clase real en una fecha. Registra suplencias, cancelaciones y las horas que impartió el profesor (base de su pago).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'SesionClaseId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = clase extra / muestra.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'ClaseHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Quien la impartió (puede ser suplente).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'ProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. mantenimiento, clima, día festivo.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'MotivoCancelacion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Checada del profesor (huella o manual).',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'EntradaProfesorUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Horas a pagar al profesor por esta clase.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'HorasPagables';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'SesionClase', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Acceso.Credencial
  Descripción: Credencial de acceso de un alumno o profesor: huella (o tarjeta/QR a futuro). No guarda la plantilla biométrica.
  Atiende    : Lector de huella
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Acceso].[Credencial]
(
    [CredencialId] INT IDENTITY (1, 1) NOT NULL,
    [TipoCredencial] VARCHAR(7) CONSTRAINT [DF_Credencial_TipoCredencial] DEFAULT ('HUELLA') NOT NULL,
    [AlumnoId] INT NULL,
    [ProfesorId] INT NULL,
    [IdEnDispositivo] VARCHAR(30) NOT NULL,
    [Dedo] TINYINT NULL,
    [FechaEnrolamientoUtc] DATETIME2(0) CONSTRAINT [DF_Credencial_FechaEnrolamientoUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [Activa] BIT CONSTRAINT [DF_Credencial_Activa] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Credencial_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Credencial] PRIMARY KEY CLUSTERED ([CredencialId]),
    CONSTRAINT [FK_Credencial_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_Credencial_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_Credencial_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Credencial_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Credencial_TipoCredencial] CHECK ([TipoCredencial] IN ('HUELLA','TARJETA','QR')),
    CONSTRAINT [CK_Credencial_Dedo] CHECK ([Dedo] BETWEEN 1 AND 10),
    CONSTRAINT [CK_Credencial_Persona] CHECK (([AlumnoId] IS NOT NULL AND [ProfesorId] IS NULL) OR ([AlumnoId] IS NULL AND [ProfesorId] IS NOT NULL))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_Credencial_IdDispositivo]
    ON [Acceso].[Credencial] ([TipoCredencial], [IdEnDispositivo]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Credencial de acceso de un alumno o profesor: huella (o tarjeta/QR a futuro). No guarda la plantilla biométrica.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'CredencialId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de enrolamiento que devuelve el lector.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'IdEnDispositivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Credencial', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Acceso.Dispositivo
  Descripción: Lectores de huella / control de acceso instalados.
  Atiende    : Lector de huella
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Acceso].[Dispositivo]
(
    [DispositivoId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(60) NOT NULL,
    [Modelo] NVARCHAR(80) NULL,
    [NumeroSerie] VARCHAR(50) NOT NULL,
    [Ubicacion] NVARCHAR(100) NULL,
    [DireccionIp] VARCHAR(45) NULL,
    [UltimaSincronizacionUtc] DATETIME2(0) NULL,
    [Activo] BIT CONSTRAINT [DF_Dispositivo_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Dispositivo_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Dispositivo] PRIMARY KEY CLUSTERED ([DispositivoId]),
    CONSTRAINT [UQ_Dispositivo_NumeroSerie] UNIQUE ([NumeroSerie]),
    CONSTRAINT [FK_Dispositivo_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Dispositivo_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lectores de huella / control de acceso instalados.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'DispositivoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. Entrada principal.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'Ubicacion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Acceso', @level1type = N'TABLE', @level1name = N'Dispositivo', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

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

/*============================================================================================
  Tabla      : Clases.AsistenciaAlumno
  Descripción: Asistencia de un alumno a una clase. Puede venir del lector de huella o capturarse manualmente.
  Atiende    : RFN04 / RFN05 · Registrar asistencia, Asistencia del día
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Clases].[AsistenciaAlumno]
(
    [AsistenciaAlumnoId] BIGINT IDENTITY (1, 1) NOT NULL,
    [SesionClaseId] INT NOT NULL,
    [AlumnoId] INT NOT NULL,
    [Estatus] VARCHAR(11) CONSTRAINT [DF_AsistenciaAlumno_Estatus] DEFAULT ('ASISTIO') NOT NULL,
    [Origen] VARCHAR(6) CONSTRAINT [DF_AsistenciaAlumno_Origen] DEFAULT ('MANUAL') NOT NULL,
    [RegistroAccesoId] BIGINT NULL,
    [FechaHoraRegistroUtc] DATETIME2(0) CONSTRAINT [DF_AsistenciaAlumno_FechaHoraRegistroUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_AsistenciaAlumno_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_AsistenciaAlumno] PRIMARY KEY CLUSTERED ([AsistenciaAlumnoId]),
    CONSTRAINT [FK_AsistenciaAlumno_SesionClaseId] FOREIGN KEY ([SesionClaseId]) REFERENCES [Clases].[SesionClase] ([SesionClaseId]),
    CONSTRAINT [FK_AsistenciaAlumno_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_AsistenciaAlumno_RegistroAccesoId] FOREIGN KEY ([RegistroAccesoId]) REFERENCES [Acceso].[RegistroAcceso] ([RegistroAccesoId]),
    CONSTRAINT [FK_AsistenciaAlumno_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_AsistenciaAlumno_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_AsistenciaAlumno_Estatus] CHECK ([Estatus] IN ('ASISTIO','FALTA','JUSTIFICADA','RETARDO')),
    CONSTRAINT [CK_AsistenciaAlumno_Origen] CHECK ([Origen] IN ('MANUAL','HUELLA'))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_AsistenciaAlumno_SesionAlumno]
    ON [Clases].[AsistenciaAlumno] ([SesionClaseId], [AlumnoId]);
GO
CREATE NONCLUSTERED INDEX [IX_AsistenciaAlumno_Alumno]
    ON [Clases].[AsistenciaAlumno] ([AlumnoId])
    INCLUDE ([Estatus], [SesionClaseId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Asistencia de un alumno a una clase. Puede venir del lector de huella o capturarse manualmente.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'AsistenciaAlumnoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Checada que la originó.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'RegistroAccesoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Clases', @level1type = N'TABLE', @level1name = N'AsistenciaAlumno', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Finanzas.Tarifa
  Descripción: Precio por clase (1 hora) con vigencia. Puede variar por tipo de periodo (clase suelta vs. mensualidad) y nivel.
  Atiende    : RFN03 · Tarifa por horario de clase
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[Tarifa]
(
    [TarifaId] SMALLINT IDENTITY (1, 1) NOT NULL,
    [Nombre] NVARCHAR(80) NOT NULL,
    [ConceptoCobroId] SMALLINT NOT NULL,
    [TipoPeriodoPagoId] TINYINT NULL,
    [NivelId] TINYINT NULL,
    [PrecioPorClase] DECIMAL(10,2) NOT NULL,
    [VigenteDesde] DATE NOT NULL,
    [VigenteHasta] DATE NULL,
    [Activo] BIT CONSTRAINT [DF_Tarifa_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Tarifa_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Tarifa] PRIMARY KEY CLUSTERED ([TarifaId]),
    CONSTRAINT [FK_Tarifa_ConceptoCobroId] FOREIGN KEY ([ConceptoCobroId]) REFERENCES [Catalogo].[ConceptoCobro] ([ConceptoCobroId]),
    CONSTRAINT [FK_Tarifa_TipoPeriodoPagoId] FOREIGN KEY ([TipoPeriodoPagoId]) REFERENCES [Catalogo].[TipoPeriodoPago] ([TipoPeriodoPagoId]),
    CONSTRAINT [FK_Tarifa_NivelId] FOREIGN KEY ([NivelId]) REFERENCES [Catalogo].[Nivel] ([NivelId]),
    CONSTRAINT [FK_Tarifa_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Tarifa_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Tarifa_PrecioPorClase] CHECK ([PrecioPorClase] >= 0)
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio por clase (1 hora) con vigencia. Puede variar por tipo de periodo (clase suelta vs. mensualidad) y nivel.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'TarifaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ej. Clase suelta, Mensualidad.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'Nombre';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'NULL = aplica a cualquier periodo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'TipoPeriodoPagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio distinto por nivel (opcional).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'NivelId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio de una clase de 1 hora. Ej. 70.00',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'PrecioPorClase';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Tarifa', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Finanzas.Cargo
  Descripción: Lo que el alumno debe por un periodo (cuenta por cobrar). Total = clases reales del periodo × precio por clase. El saldo determina Pagado / Pago a cuenta / Pendiente.
  Atiende    : RFN03 / RFN05 · Información de pago, Adeudos, Pagos por vencer
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor); RowVer (concurrencia optimista)
============================================================================================*/
CREATE TABLE [Finanzas].[Cargo]
(
    [CargoId] INT IDENTITY (1, 1) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [ConceptoCobroId] SMALLINT NOT NULL,
    [TarifaId] SMALLINT NULL,
    [TipoPeriodoPagoId] TINYINT NOT NULL,
    [PeriodoInicio] DATE NOT NULL,
    [PeriodoFin] DATE NOT NULL,
    [ClasesEnPeriodo] SMALLINT NOT NULL,
    [PrecioUnitario] DECIMAL(10,2) NOT NULL,
    [Subtotal] DECIMAL(10,2) NOT NULL,
    [Descuento] DECIMAL(10,2) CONSTRAINT [DF_Cargo_Descuento] DEFAULT (0) NOT NULL,
    [Total] DECIMAL(10,2) NOT NULL,
    [MontoPagado] DECIMAL(10,2) CONSTRAINT [DF_Cargo_MontoPagado] DEFAULT (0) NOT NULL,
    [Saldo] AS (CAST([Total] - [MontoPagado] AS DECIMAL(10,2))) PERSISTED NOT NULL,
    [FechaVencimiento] DATE NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Cargo_Estatus] DEFAULT ('PENDIENTE') NOT NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Cargo_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    [RowVer] ROWVERSION NOT NULL,
    CONSTRAINT [PK_Cargo] PRIMARY KEY CLUSTERED ([CargoId]),
    CONSTRAINT [FK_Cargo_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_Cargo_ConceptoCobroId] FOREIGN KEY ([ConceptoCobroId]) REFERENCES [Catalogo].[ConceptoCobro] ([ConceptoCobroId]),
    CONSTRAINT [FK_Cargo_TarifaId] FOREIGN KEY ([TarifaId]) REFERENCES [Finanzas].[Tarifa] ([TarifaId]),
    CONSTRAINT [FK_Cargo_TipoPeriodoPagoId] FOREIGN KEY ([TipoPeriodoPagoId]) REFERENCES [Catalogo].[TipoPeriodoPago] ([TipoPeriodoPagoId]),
    CONSTRAINT [FK_Cargo_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Cargo_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Cargo_Estatus] CHECK ([Estatus] IN ('PENDIENTE','PARCIAL','PAGADO','CANCELADO')),
    CONSTRAINT [CK_Cargo_Periodo] CHECK ([PeriodoFin] >= [PeriodoInicio]),
    CONSTRAINT [CK_Cargo_Montos] CHECK ([Total] >= 0 AND [Descuento] >= 0 AND [MontoPagado] >= 0 AND [MontoPagado] <= [Total])
);
GO
CREATE NONCLUSTERED INDEX [IX_Cargo_Alumno]
    ON [Finanzas].[Cargo] ([AlumnoId], [PeriodoInicio] DESC)
    INCLUDE ([Estatus], [Saldo]);
GO
CREATE NONCLUSTERED INDEX [IX_Cargo_Pendientes]
    ON [Finanzas].[Cargo] ([FechaVencimiento])
    INCLUDE ([AlumnoId], [Saldo], [PeriodoFin])
    WHERE [Estatus] IN ('PENDIENTE','PARCIAL');
GO
CREATE NONCLUSTERED INDEX [IX_Cargo_PeriodoFin]
    ON [Finanzas].[Cargo] ([PeriodoFin])
    INCLUDE ([AlumnoId], [Estatus]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lo que el alumno debe por un periodo (cuenta por cobrar). Total = clases reales del periodo × precio por clase. El saldo determina Pagado / Pago a cuenta / Pendiente.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'CargoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de inicio de pago.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'PeriodoInicio';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de fin de pago.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'PeriodoFin';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clases reales que cubre (filas en CargoClase).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'ClasesEnPeriodo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precio por clase copiado al momento del cargo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'PrecioUnitario';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo total.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'Total';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Lo mantiene el SP de pagos dentro de la transacción.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'MontoPagado';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Calculada y persistida.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'Saldo';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'PENDIENTE=Pendiente, PARCIAL=Pago a cuenta, PAGADO=Pagado.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'Estatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Versión de la fila para control de concurrencia optimista.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Cargo', @level2type = N'COLUMN', @level2name = N'RowVer';
GO

/*============================================================================================
  Tabla      : Finanzas.CargoClase
  Descripción: Cada clase (fecha y hora) que cubre un cargo. Permite cobrar por clase, 2 horas seguidas el mismo día o el mes según los días reales.
  Atiende    : Cobro por clase / días reales
============================================================================================*/
CREATE TABLE [Finanzas].[CargoClase]
(
    [CargoClaseId] INT IDENTITY (1, 1) NOT NULL,
    [CargoId] INT NOT NULL,
    [Fecha] DATE NOT NULL,
    [ClaseHorarioId] INT NULL,
    [SesionClaseId] INT NULL,
    [Importe] DECIMAL(10,2) NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_CargoClase_Estatus] DEFAULT ('ACTIVA') NOT NULL,
    CONSTRAINT [PK_CargoClase] PRIMARY KEY CLUSTERED ([CargoClaseId]),
    CONSTRAINT [FK_CargoClase_CargoId] FOREIGN KEY ([CargoId]) REFERENCES [Finanzas].[Cargo] ([CargoId]),
    CONSTRAINT [FK_CargoClase_Fecha] FOREIGN KEY ([Fecha]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_CargoClase_ClaseHorarioId] FOREIGN KEY ([ClaseHorarioId]) REFERENCES [Clases].[ClaseHorario] ([ClaseHorarioId]),
    CONSTRAINT [FK_CargoClase_SesionClaseId] FOREIGN KEY ([SesionClaseId]) REFERENCES [Clases].[SesionClase] ([SesionClaseId]),
    CONSTRAINT [CK_CargoClase_Importe] CHECK ([Importe] >= 0),
    CONSTRAINT [CK_CargoClase_Estatus] CHECK ([Estatus] IN ('ACTIVA','CANCELADA','REPUESTA'))
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CargoClase_Clase]
    ON [Finanzas].[CargoClase] ([CargoId], [Fecha], [ClaseHorarioId]);
GO
CREATE NONCLUSTERED INDEX [IX_CargoClase_Sesion]
    ON [Finanzas].[CargoClase] ([SesionClaseId])
    WHERE [SesionClaseId] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cada clase (fecha y hora) que cubre un cargo. Permite cobrar por clase, 2 horas seguidas el mismo día o el mes según los días reales.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'CargoClaseId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bloque al que corresponde.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'ClaseHorarioId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Se liga cuando la sesión ya existe.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'SesionClaseId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'CANCELADA = la escuela canceló la clase (se reembolsa o se repone).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'CargoClase', @level2type = N'COLUMN', @level2name = N'Estatus';
GO

/*============================================================================================
  Tabla      : Finanzas.Pago
  Descripción: Pago recibido de un alumno (recibo). Un pago puede ser total o a cuenta.
  Atiende    : RFN03 · Pago total / Pago a cuenta
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[Pago]
(
    [PagoId] INT IDENTITY (1, 1) NOT NULL,
    [Folio] VARCHAR(20) CONSTRAINT [DF_Pago_Folio] DEFAULT (CONCAT('P-', RIGHT(CONCAT('0000000', NEXT VALUE FOR [Finanzas].[SeqFolioPago]), 7))) NOT NULL,
    [AlumnoId] INT NOT NULL,
    [FechaPago] DATE NOT NULL,
    [MetodoPagoId] TINYINT NOT NULL,
    [Monto] DECIMAL(10,2) NOT NULL,
    [Referencia] VARCHAR(60) NULL,
    [RecibidoPor] INT NOT NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Pago_Estatus] DEFAULT ('APLICADO') NOT NULL,
    [MotivoCancelacion] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Pago_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Pago] PRIMARY KEY CLUSTERED ([PagoId]),
    CONSTRAINT [UQ_Pago_Folio] UNIQUE ([Folio]),
    CONSTRAINT [FK_Pago_AlumnoId] FOREIGN KEY ([AlumnoId]) REFERENCES [Alumnos].[Alumno] ([AlumnoId]),
    CONSTRAINT [FK_Pago_FechaPago] FOREIGN KEY ([FechaPago]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_Pago_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_Pago_RecibidoPor] FOREIGN KEY ([RecibidoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Pago_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Pago_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Pago_Monto] CHECK ([Monto] > 0),
    CONSTRAINT [CK_Pago_Estatus] CHECK ([Estatus] IN ('APLICADO','CANCELADO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_Pago_Fecha]
    ON [Finanzas].[Pago] ([FechaPago])
    INCLUDE ([Monto], [Estatus], [MetodoPagoId]);
GO
CREATE NONCLUSTERED INDEX [IX_Pago_Alumno]
    ON [Finanzas].[Pago] ([AlumnoId], [FechaPago] DESC);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago recibido de un alumno (recibo). Un pago puede ser total o a cuenta.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'PagoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Folio del recibo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'Folio';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que cobró.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'RecibidoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Pago', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Finanzas.PagoAplicacion
  Descripción: A qué cargo(s) se aplica cada pago. Permite abonos parciales y un pago que cubre varios cargos.
  Atiende    : RFN03
============================================================================================*/
CREATE TABLE [Finanzas].[PagoAplicacion]
(
    [PagoAplicacionId] INT IDENTITY (1, 1) NOT NULL,
    [PagoId] INT NOT NULL,
    [CargoId] INT NOT NULL,
    [MontoAplicado] DECIMAL(10,2) NOT NULL,
    CONSTRAINT [PK_PagoAplicacion] PRIMARY KEY CLUSTERED ([PagoAplicacionId]),
    CONSTRAINT [FK_PagoAplicacion_PagoId] FOREIGN KEY ([PagoId]) REFERENCES [Finanzas].[Pago] ([PagoId]),
    CONSTRAINT [FK_PagoAplicacion_CargoId] FOREIGN KEY ([CargoId]) REFERENCES [Finanzas].[Cargo] ([CargoId]),
    CONSTRAINT [CK_PagoAplicacion_MontoAplicado] CHECK ([MontoAplicado] > 0)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PagoAplicacion]
    ON [Finanzas].[PagoAplicacion] ([PagoId], [CargoId]);
GO
CREATE NONCLUSTERED INDEX [IX_PagoAplicacion_Cargo]
    ON [Finanzas].[PagoAplicacion] ([CargoId])
    INCLUDE ([MontoAplicado]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'A qué cargo(s) se aplica cada pago. Permite abonos parciales y un pago que cubre varios cargos.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoAplicacion';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoAplicacion', @level2type = N'COLUMN', @level2name = N'PagoAplicacionId';
GO

/*============================================================================================
  Tabla      : Finanzas.PagoProfesor
  Descripción: Pago (nómina) a un profesor por un periodo, calculado de sus clases impartidas.
  Atiende    : RFN06 · Reporte de pagos a maestros
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[PagoProfesor]
(
    [PagoProfesorId] INT IDENTITY (1, 1) NOT NULL,
    [ProfesorId] INT NOT NULL,
    [PeriodoInicio] DATE NOT NULL,
    [PeriodoFin] DATE NOT NULL,
    [HorasTrabajadas] DECIMAL(6,2) NOT NULL,
    [Subtotal] DECIMAL(10,2) NOT NULL,
    [Bonos] DECIMAL(10,2) CONSTRAINT [DF_PagoProfesor_Bonos] DEFAULT (0) NOT NULL,
    [Deducciones] DECIMAL(10,2) CONSTRAINT [DF_PagoProfesor_Deducciones] DEFAULT (0) NOT NULL,
    [Total] DECIMAL(10,2) NOT NULL,
    [FechaPago] DATE NULL,
    [MetodoPagoId] TINYINT NULL,
    [Referencia] VARCHAR(60) NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_PagoProfesor_Estatus] DEFAULT ('BORRADOR') NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_PagoProfesor_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_PagoProfesor] PRIMARY KEY CLUSTERED ([PagoProfesorId]),
    CONSTRAINT [FK_PagoProfesor_ProfesorId] FOREIGN KEY ([ProfesorId]) REFERENCES [Personal].[Profesor] ([ProfesorId]),
    CONSTRAINT [FK_PagoProfesor_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_PagoProfesor_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_PagoProfesor_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_PagoProfesor_Estatus] CHECK ([Estatus] IN ('BORRADOR','PAGADO','CANCELADO')),
    CONSTRAINT [CK_PagoProfesor_Periodo] CHECK ([PeriodoFin] >= [PeriodoInicio])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PagoProfesor_Periodo]
    ON [Finanzas].[PagoProfesor] ([ProfesorId], [PeriodoInicio], [PeriodoFin])
    WHERE [Estatus] <> 'CANCELADO';
GO
CREATE NONCLUSTERED INDEX [IX_PagoProfesor_FechaPago]
    ON [Finanzas].[PagoProfesor] ([FechaPago])
    INCLUDE ([Total], [Estatus]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Pago (nómina) a un profesor por un periodo, calculado de sus clases impartidas.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'PagoProfesorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesor', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Finanzas.PagoProfesorDetalle
  Descripción: Clases incluidas en cada pago a profesor (una clase solo se paga una vez).
  Atiende    : RFN04 / RFN06
============================================================================================*/
CREATE TABLE [Finanzas].[PagoProfesorDetalle]
(
    [PagoProfesorDetalleId] INT IDENTITY (1, 1) NOT NULL,
    [PagoProfesorId] INT NOT NULL,
    [SesionClaseId] INT NOT NULL,
    [Horas] DECIMAL(4,2) NOT NULL,
    [TarifaHora] DECIMAL(10,2) NOT NULL,
    [Importe] DECIMAL(10,2) NOT NULL,
    CONSTRAINT [PK_PagoProfesorDetalle] PRIMARY KEY CLUSTERED ([PagoProfesorDetalleId]),
    CONSTRAINT [FK_PagoProfesorDetalle_PagoProfesorId] FOREIGN KEY ([PagoProfesorId]) REFERENCES [Finanzas].[PagoProfesor] ([PagoProfesorId]),
    CONSTRAINT [FK_PagoProfesorDetalle_SesionClaseId] FOREIGN KEY ([SesionClaseId]) REFERENCES [Clases].[SesionClase] ([SesionClaseId])
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_PagoProfesorDetalle_Sesion]
    ON [Finanzas].[PagoProfesorDetalle] ([SesionClaseId]);
GO
CREATE NONCLUSTERED INDEX [IX_PagoProfesorDetalle_Pago]
    ON [Finanzas].[PagoProfesorDetalle] ([PagoProfesorId]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Clases incluidas en cada pago a profesor (una clase solo se paga una vez).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesorDetalle';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesorDetalle', @level2type = N'COLUMN', @level2name = N'PagoProfesorDetalleId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Copia de ProfesorTarifa vigente.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'PagoProfesorDetalle', @level2type = N'COLUMN', @level2name = N'TarifaHora';
GO

/*============================================================================================
  Tabla      : Operacion.Proveedor
  Descripción: Proveedores de químicos, mantenimiento, equipo y servicios.
  Atiende    : Gastos
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[Proveedor]
(
    [ProveedorId] INT IDENTITY (1, 1) NOT NULL,
    [RazonSocial] NVARCHAR(150) NOT NULL,
    [RFC] VARCHAR(13) NULL,
    [Contacto] NVARCHAR(100) NULL,
    [Telefono] VARCHAR(20) NULL,
    [Correo] NVARCHAR(150) NULL,
    [Activo] BIT CONSTRAINT [DF_Proveedor_Activo] DEFAULT (1) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Proveedor_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Proveedor] PRIMARY KEY CLUSTERED ([ProveedorId]),
    CONSTRAINT [FK_Proveedor_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Proveedor_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Proveedores de químicos, mantenimiento, equipo y servicios.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'ProveedorId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Proveedor', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Operacion.Mantenimiento
  Descripción: Mantenimientos preventivos/correctivos de la alberca. El costo real se registra en Finanzas.Gasto.
  Atiende    : Mantenimiento de alberca
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[Mantenimiento]
(
    [MantenimientoId] INT IDENTITY (1, 1) NOT NULL,
    [AlbercaId] TINYINT NOT NULL,
    [TipoMantenimientoId] SMALLINT NOT NULL,
    [ProveedorId] INT NULL,
    [ResponsableId] INT NULL,
    [FechaProgramada] DATE NOT NULL,
    [FechaRealizada] DATE NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Mantenimiento_Estatus] DEFAULT ('PROGRAMADO') NOT NULL,
    [Descripcion] NVARCHAR(500) NOT NULL,
    [CostoEstimado] DECIMAL(10,2) NULL,
    [CierraAlberca] BIT CONSTRAINT [DF_Mantenimiento_CierraAlberca] DEFAULT (0) NOT NULL,
    [CierreInicioUtc] DATETIME2(0) NULL,
    [CierreFinUtc] DATETIME2(0) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Mantenimiento_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Mantenimiento] PRIMARY KEY CLUSTERED ([MantenimientoId]),
    CONSTRAINT [FK_Mantenimiento_AlbercaId] FOREIGN KEY ([AlbercaId]) REFERENCES [Operacion].[Alberca] ([AlbercaId]),
    CONSTRAINT [FK_Mantenimiento_TipoMantenimientoId] FOREIGN KEY ([TipoMantenimientoId]) REFERENCES [Catalogo].[TipoMantenimiento] ([TipoMantenimientoId]),
    CONSTRAINT [FK_Mantenimiento_ProveedorId] FOREIGN KEY ([ProveedorId]) REFERENCES [Operacion].[Proveedor] ([ProveedorId]),
    CONSTRAINT [FK_Mantenimiento_ResponsableId] FOREIGN KEY ([ResponsableId]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Mantenimiento_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Mantenimiento_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Mantenimiento_Estatus] CHECK ([Estatus] IN ('PROGRAMADO','REALIZADO','CANCELADO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_Mantenimiento_Alberca]
    ON [Operacion].[Mantenimiento] ([AlbercaId], [FechaProgramada])
    INCLUDE ([Estatus]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mantenimientos preventivos/correctivos de la alberca. El costo real se registra en Finanzas.Gasto.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'MantenimientoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario responsable interno.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'ResponsableId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = no hay clases (explica caídas de asistencia).',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'CierraAlberca';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'Mantenimiento', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Finanzas.Gasto
  Descripción: Salidas de dinero que no son nómina: químicos, mantenimiento, servicios, renta, equipo…
  Atiende    : Gastos / mantenimiento
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[Gasto]
(
    [GastoId] INT IDENTITY (1, 1) NOT NULL,
    [CategoriaGastoId] SMALLINT NOT NULL,
    [ProveedorId] INT NULL,
    [MantenimientoId] INT NULL,
    [FechaGasto] DATE NOT NULL,
    [Concepto] NVARCHAR(200) NOT NULL,
    [Monto] DECIMAL(10,2) NOT NULL,
    [MetodoPagoId] TINYINT NOT NULL,
    [FolioFactura] VARCHAR(60) NULL,
    [ComprobanteUrl] VARCHAR(300) NULL,
    [Estatus] VARCHAR(10) CONSTRAINT [DF_Gasto_Estatus] DEFAULT ('APLICADO') NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_Gasto_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_Gasto] PRIMARY KEY CLUSTERED ([GastoId]),
    CONSTRAINT [FK_Gasto_CategoriaGastoId] FOREIGN KEY ([CategoriaGastoId]) REFERENCES [Catalogo].[CategoriaGasto] ([CategoriaGastoId]),
    CONSTRAINT [FK_Gasto_ProveedorId] FOREIGN KEY ([ProveedorId]) REFERENCES [Operacion].[Proveedor] ([ProveedorId]),
    CONSTRAINT [FK_Gasto_MantenimientoId] FOREIGN KEY ([MantenimientoId]) REFERENCES [Operacion].[Mantenimiento] ([MantenimientoId]),
    CONSTRAINT [FK_Gasto_FechaGasto] FOREIGN KEY ([FechaGasto]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_Gasto_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_Gasto_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_Gasto_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_Gasto_Monto] CHECK ([Monto] > 0),
    CONSTRAINT [CK_Gasto_Estatus] CHECK ([Estatus] IN ('APLICADO','CANCELADO'))
);
GO
CREATE NONCLUSTERED INDEX [IX_Gasto_Fecha]
    ON [Finanzas].[Gasto] ([FechaGasto])
    INCLUDE ([CategoriaGastoId], [Monto], [Estatus]);
GO
CREATE NONCLUSTERED INDEX [IX_Gasto_Mantenimiento]
    ON [Finanzas].[Gasto] ([MantenimientoId])
    WHERE [MantenimientoId] IS NOT NULL;
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Salidas de dinero que no son nómina: químicos, mantenimiento, servicios, renta, equipo…',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'GastoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el gasto es de un mantenimiento.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'MantenimientoId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'Gasto', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Finanzas.MovimientoCaja
  Descripción: Libro único de entradas y salidas de dinero. Cada pago, pago a profesor o gasto genera su movimiento.
  Atiende    : Entradas y salidas / Reporte de ganancias
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Finanzas].[MovimientoCaja]
(
    [MovimientoCajaId] BIGINT IDENTITY (1, 1) NOT NULL,
    [FechaMovimiento] DATE NOT NULL,
    [Tipo] VARCHAR(7) NOT NULL,
    [Origen] VARCHAR(13) NOT NULL,
    [PagoId] INT NULL,
    [PagoProfesorId] INT NULL,
    [GastoId] INT NULL,
    [MetodoPagoId] TINYINT NOT NULL,
    [Monto] DECIMAL(10,2) NOT NULL,
    [Concepto] NVARCHAR(200) NOT NULL,
    [EsReverso] BIT CONSTRAINT [DF_MovimientoCaja_EsReverso] DEFAULT (0) NOT NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_MovimientoCaja_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_MovimientoCaja] PRIMARY KEY CLUSTERED ([MovimientoCajaId]),
    CONSTRAINT [FK_MovimientoCaja_FechaMovimiento] FOREIGN KEY ([FechaMovimiento]) REFERENCES [Reporte].[Calendario] ([Fecha]),
    CONSTRAINT [FK_MovimientoCaja_PagoId] FOREIGN KEY ([PagoId]) REFERENCES [Finanzas].[Pago] ([PagoId]),
    CONSTRAINT [FK_MovimientoCaja_PagoProfesorId] FOREIGN KEY ([PagoProfesorId]) REFERENCES [Finanzas].[PagoProfesor] ([PagoProfesorId]),
    CONSTRAINT [FK_MovimientoCaja_GastoId] FOREIGN KEY ([GastoId]) REFERENCES [Finanzas].[Gasto] ([GastoId]),
    CONSTRAINT [FK_MovimientoCaja_MetodoPagoId] FOREIGN KEY ([MetodoPagoId]) REFERENCES [Catalogo].[MetodoPago] ([MetodoPagoId]),
    CONSTRAINT [FK_MovimientoCaja_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_MovimientoCaja_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_MovimientoCaja_Tipo] CHECK ([Tipo] IN ('ENTRADA','SALIDA')),
    CONSTRAINT [CK_MovimientoCaja_OrigenValido] CHECK ([Origen] IN ('PAGO_ALUMNO','PAGO_PROFESOR','GASTO','AJUSTE')),
    CONSTRAINT [CK_MovimientoCaja_Monto] CHECK ([Monto] > 0),
    CONSTRAINT [CK_MovimientoCaja_Origen] CHECK (([Origen] = 'PAGO_ALUMNO' AND [PagoId] IS NOT NULL AND [PagoProfesorId] IS NULL AND [GastoId] IS NULL) OR ([Origen] = 'PAGO_PROFESOR' AND [PagoProfesorId] IS NOT NULL AND [PagoId] IS NULL AND [GastoId] IS NULL) OR ([Origen] = 'GASTO' AND [GastoId] IS NOT NULL AND [PagoId] IS NULL AND [PagoProfesorId] IS NULL) OR ([Origen] = 'AJUSTE' AND [PagoId] IS NULL AND [PagoProfesorId] IS NULL AND [GastoId] IS NULL))
);
GO
CREATE NONCLUSTERED INDEX [IX_MovimientoCaja_Fecha]
    ON [Finanzas].[MovimientoCaja] ([FechaMovimiento], [Tipo])
    INCLUDE ([Monto], [Origen]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Libro único de entradas y salidas de dinero. Cada pago, pago a profesor o gasto genera su movimiento.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'MovimientoCajaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Siempre positivo; el signo lo da Tipo.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'Monto';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 = contrapartida de una cancelación (no se borra nada).',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'EsReverso';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Finanzas', @level1type = N'TABLE', @level1name = N'MovimientoCaja', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Operacion.MedicionAgua
  Descripción: Bitácora de calidad del agua (cloro, pH, temperatura).
  Atiende    : Mantenimiento de alberca
  Incluye    : auditoría (FechaCreacionUtc, CreadoPor, FechaModificacionUtc, ModificadoPor)
============================================================================================*/
CREATE TABLE [Operacion].[MedicionAgua]
(
    [MedicionAguaId] INT IDENTITY (1, 1) NOT NULL,
    [AlbercaId] TINYINT NOT NULL,
    [FechaHoraUtc] DATETIME2(0) CONSTRAINT [DF_MedicionAgua_FechaHoraUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CloroLibrePpm] DECIMAL(4,2) NULL,
    [PH] DECIMAL(4,2) NULL,
    [TemperaturaC] DECIMAL(4,1) NULL,
    [Observaciones] NVARCHAR(250) NULL,
    [FechaCreacionUtc] DATETIME2(0) CONSTRAINT [DF_MedicionAgua_FechaCreacionUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CreadoPor] INT NULL,
    [FechaModificacionUtc] DATETIME2(0) NULL,
    [ModificadoPor] INT NULL,
    CONSTRAINT [PK_MedicionAgua] PRIMARY KEY CLUSTERED ([MedicionAguaId]),
    CONSTRAINT [FK_MedicionAgua_AlbercaId] FOREIGN KEY ([AlbercaId]) REFERENCES [Operacion].[Alberca] ([AlbercaId]),
    CONSTRAINT [FK_MedicionAgua_CreadoPor] FOREIGN KEY ([CreadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [FK_MedicionAgua_ModificadoPor] FOREIGN KEY ([ModificadoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId])
);
GO
CREATE NONCLUSTERED INDEX [IX_MedicionAgua_Alberca]
    ON [Operacion].[MedicionAgua] ([AlbercaId], [FechaHoraUtc] DESC);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de calidad del agua (cloro, pH, temperatura).',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'MedicionAguaId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) en que se creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'FechaCreacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'CreadoPor';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora (UTC) de la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'FechaModificacionUtc';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que hizo la última modificación.',
    @level0type = N'SCHEMA', @level0name = N'Operacion', @level1type = N'TABLE', @level1name = N'MedicionAgua', @level2type = N'COLUMN', @level2name = N'ModificadoPor';
GO

/*============================================================================================
  Tabla      : Reporte.CierreMensual
  Descripción: Foto de los indicadores del mes al cerrarlo. Hace rápidos los comparativos contra meses anteriores.
  Atiende    : RFN06 · Comparativa mes anterior
============================================================================================*/
CREATE TABLE [Reporte].[CierreMensual]
(
    [CierreMensualId] INT IDENTITY (1, 1) NOT NULL,
    [Anio] SMALLINT NOT NULL,
    [Mes] TINYINT NOT NULL,
    [IngresosAlumnos] DECIMAL(12,2) NOT NULL,
    [PagosProfesores] DECIMAL(12,2) NOT NULL,
    [GastosOperacion] DECIMAL(12,2) NOT NULL,
    [GastosMantenimiento] DECIMAL(12,2) NOT NULL,
    [Utilidad] DECIMAL(12,2) NOT NULL,
    [SaldoPorCobrar] DECIMAL(12,2) NOT NULL,
    [AlumnosActivos] INT NOT NULL,
    [AlumnosNuevos] INT NOT NULL,
    [AlumnosBaja] INT NOT NULL,
    [ClasesImpartidas] INT NOT NULL,
    [TotalAsistencias] INT NOT NULL,
    [PorcentajeAsistencia] DECIMAL(5,2) NOT NULL,
    [FechaCierreUtc] DATETIME2(0) CONSTRAINT [DF_CierreMensual_FechaCierreUtc] DEFAULT (SYSUTCDATETIME()) NOT NULL,
    [CerradoPor] INT NOT NULL,
    CONSTRAINT [PK_CierreMensual] PRIMARY KEY CLUSTERED ([CierreMensualId]),
    CONSTRAINT [FK_CierreMensual_CerradoPor] FOREIGN KEY ([CerradoPor]) REFERENCES [Seguridad].[Usuario] ([UsuarioId]),
    CONSTRAINT [CK_CierreMensual_Mes] CHECK ([Mes] BETWEEN 1 AND 12)
);
GO
CREATE UNIQUE NONCLUSTERED INDEX [UX_CierreMensual_Periodo]
    ON [Reporte].[CierreMensual] ([Anio], [Mes]);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Foto de los indicadores del mes al cerrarlo. Hace rápidos los comparativos contra meses anteriores.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'CierreMensual';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave primaria.',
    @level0type = N'SCHEMA', @level0name = N'Reporte', @level1type = N'TABLE', @level1name = N'CierreMensual', @level2type = N'COLUMN', @level2name = N'CierreMensualId';
GO

/* ---------------------------------------------------------------- Datos iniciales */
SET NOCOUNT ON;
GO
/*============================================================================================
  Datos iniciales · Catálogos
  Idempotente: solo inserta lo que falta. Nunca sobrescribe cambios hechos desde el sistema.
============================================================================================*/
PRINT N'Catálogos...';

-- Tipos de periodo de pago (llave fija, sin IDENTITY: la aplicación puede referirlos por Id).
MERGE [Catalogo].[TipoPeriodoPago] AS t
USING (VALUES
    (CAST(1 AS TINYINT), 'CLASE',     N'Por clase',  CAST(1  AS SMALLINT), CAST(1 AS TINYINT)),
    (2,                  'SEMANAL',   N'Semanal',    7,                    2),
    (3,                  'QUINCENAL', N'Quincenal',  15,                   3),
    (4,                  'MENSUAL',   N'Mensual',    NULL,                 4)  -- NULL = mes calendario
) AS s (TipoPeriodoPagoId, Clave, Nombre, DiasDuracion, Orden)
ON t.[TipoPeriodoPagoId] = s.TipoPeriodoPagoId
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([TipoPeriodoPagoId], [Clave], [Nombre], [DiasDuracion], [Orden])
    VALUES (s.TipoPeriodoPagoId, s.Clave, s.Nombre, s.DiasDuracion, s.Orden);

-- Métodos de pago (llave fija).
MERGE [Catalogo].[MetodoPago] AS t
USING (VALUES
    (CAST(1 AS TINYINT), 'EFECTIVO',      N'Efectivo',      CAST(0 AS BIT)),
    (2,                  'TRANSFERENCIA', N'Transferencia', 1),
    (3,                  'TARJETA',       N'Tarjeta',       1)
) AS s (MetodoPagoId, Clave, Nombre, RequiereReferencia)
ON t.[MetodoPagoId] = s.MetodoPagoId
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([MetodoPagoId], [Clave], [Nombre], [RequiereReferencia])
    VALUES (s.MetodoPagoId, s.Clave, s.Nombre, s.RequiereReferencia);

-- Conceptos de cobro.
MERGE [Catalogo].[ConceptoCobro] AS t
USING (VALUES
    ('COLEGIATURA',  N'Colegiatura (semana, quincena o mes)', CAST(1 AS BIT)),
    ('CLASE_SUELTA', N'Clase suelta',                          1),
    ('INSCRIPCION',  N'Inscripción',                           0),
    ('UNIFORME',     N'Uniforme / material',                   0)
) AS s (Clave, Nombre, EsColegiatura)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre], [EsColegiatura]) VALUES (s.Clave, s.Nombre, s.EsColegiatura);

-- Niveles de natación.
MERGE [Catalogo].[Nivel] AS t
USING (VALUES
    (N'Bebés',        CAST(0 AS TINYINT), CAST(3 AS TINYINT), CAST(1 AS TINYINT)),
    (N'Principiante', NULL,               NULL,               2),
    (N'Intermedio',   NULL,               NULL,               3),
    (N'Avanzado',     NULL,               NULL,               4),
    (N'Competencia',  NULL,               NULL,               5)
) AS s (Nombre, EdadMinima, EdadMaxima, Orden)
ON t.[Nombre] = s.Nombre
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Nombre], [EdadMinima], [EdadMaxima], [Orden]) VALUES (s.Nombre, s.EdadMinima, s.EdadMaxima, s.Orden);

-- Categorías de gasto (la nómina de profesores NO es gasto: vive en Finanzas.PagoProfesor).
MERGE [Catalogo].[CategoriaGasto] AS t
USING (VALUES
    ('QUIMICOS',      N'Químicos'),
    ('MANTENIMIENTO', N'Mantenimiento'),
    ('SERVICIOS',     N'Servicios (luz, agua, gas, internet)'),
    ('RENTA',         N'Renta'),
    ('EQUIPO',        N'Equipo y material'),
    ('OTROS',         N'Otros')
) AS s (Clave, Nombre)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre]) VALUES (s.Clave, s.Nombre);

-- Tipos de mantenimiento de la alberca (FrecuenciaDias programa el siguiente preventivo).
MERGE [Catalogo].[TipoMantenimiento] AS t
USING (VALUES
    (N'Limpieza general',          CAST(1 AS BIT), CAST(7   AS SMALLINT)),
    (N'Balanceo químico',          1,              7),
    (N'Retrolavado de filtros',    1,              14),
    (N'Revisión de bomba',         1,              90),
    (N'Revisión de calentador',    1,              180),
    (N'Reparación correctiva',     0,              NULL)
) AS s (Nombre, EsPreventivo, FrecuenciaDias)
ON t.[Nombre] = s.Nombre
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Nombre], [EsPreventivo], [FrecuenciaDias]) VALUES (s.Nombre, s.EsPreventivo, s.FrecuenciaDias);

-- Temporadas (qué meses son alta o baja está pendiente de confirmar con el cliente;
-- se asignan en Reporte.Calendario.TemporadaId cuando se definan).
MERGE [Catalogo].[Temporada] AS t
USING (VALUES
    (N'Temporada alta',        N'Meses de mayor inscripción.',            '#2E7D32'),
    (N'Temporada baja',        N'Meses de menor inscripción.',            '#C62828'),
    (N'Vacaciones de verano',  N'Cursos de verano.',                      '#F9A825'),
    (N'Temporada decembrina',  N'Vacaciones de diciembre y año nuevo.',   '#1565C0')
) AS s (Nombre, Descripcion, Color)
ON t.[Nombre] = s.Nombre
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Nombre], [Descripcion], [Color]) VALUES (s.Nombre, s.Descripcion, s.Color);

-- Alberca principal (una sola sede; se pueden agregar más albercas).
IF NOT EXISTS (SELECT 1 FROM [Operacion].[Alberca])
    INSERT INTO [Operacion].[Alberca] ([Nombre]) VALUES (N'Alberca principal');

GO
/*============================================================================================
  Datos iniciales · Parámetros del sistema (Catalogo.Parametro)
  Solo inserta las claves que no existen: los valores que se cambien desde Configuración se respetan.
============================================================================================*/
PRINT N'Parámetros...';

MERGE [Catalogo].[Parametro] AS t
USING (VALUES
    ('NOMBRE_ESCUELA',             N'Acuática Valle',                 'TEXTO',  N'Nombre de la escuela para recibos y reportes.'),
    ('DIAS_AVISO_VENCIMIENTO',     N'5',                              'ENTERO', N'Días antes del fin de periodo para mostrar "pagos por vencer".'),
    ('MINUTOS_TOLERANCIA_RETARDO', N'10',                             'ENTERO', N'Minutos después del inicio de la clase para marcar retardo.'),
    ('BLOQUEAR_ACCESO_CON_ADEUDO', N'0',                              'BOOL',   N'1 = el lector de huella niega la entrada con adeudo vencido. (Pendiente de confirmar con el cliente.)'),
    ('MAX_INTENTOS_LOGIN',         N'5',                              'ENTERO', N'Intentos fallidos de inicio de sesión antes de bloquear al usuario.'),
    ('MINUTOS_BLOQUEO_LOGIN',      N'15',                             'ENTERO', N'Minutos que dura el bloqueo por intentos fallidos.'),
    ('ZONA_HORARIA',               N'Central Standard Time (Mexico)', 'TEXTO',  N'Zona para convertir UTC a hora local (nombre válido para AT TIME ZONE).')
) AS s (Clave, Valor, TipoDato, Descripcion)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Valor], [TipoDato], [Descripcion]) VALUES (s.Clave, s.Valor, s.TipoDato, s.Descripcion);

GO
/*============================================================================================
  Datos iniciales · Seguridad: roles, módulos, permisos, permisos por rol y usuario administrador.

  Idempotente y respetuoso con lo que se configure desde el sistema:
  - Roles, módulos y permisos: solo se insertan los que faltan.
  - Permisos por rol: el rol ADMIN siempre recibe todos los permisos. Para los demás roles,
    la asignación base se aplica solo cuando el rol o el permiso se crean por primera vez;
    si después se le quita un permiso a RECEPCION, un nuevo despliegue no lo vuelve a poner.
============================================================================================*/
PRINT N'Seguridad...';

DECLARE @RolesNuevos    TABLE ([RolId] SMALLINT PRIMARY KEY);
DECLARE @PermisosNuevos TABLE ([PermisoId] SMALLINT PRIMARY KEY);

------------------------------------------------------------------ Roles
MERGE [Seguridad].[Rol] AS t
USING (VALUES
    ('SUPERUSUARIO', N'Superusuario', N'Desarrolladores del sistema. Acceso total sin restricciones; el API no le valida permisos.'),
    ('ADMIN',     N'Administrador', N'Acceso total al sistema.'),
    ('RECEPCION', N'Recepción',     N'Alumnos, horarios, asistencia, cobro y calendario.'),
    ('PROFESOR',  N'Profesor',      N'Su calendario, la lista de sus alumnos y pasar asistencia.')
) AS s (Clave, Nombre, Descripcion)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre], [Descripcion], [EsSistema]) VALUES (s.Clave, s.Nombre, s.Descripcion, 1)
OUTPUT inserted.[RolId] INTO @RolesNuevos;

------------------------------------------------------------------ Módulos (menú)
MERGE [Seguridad].[Modulo] AS t
USING (VALUES
    ('DASHBOARD',     N'Dashboard',          '/dashboard',     'dashboard', CAST(1 AS TINYINT)),
    ('ALUMNOS',       N'Control de alumnos', '/alumnos',       'alumnos',   2),
    ('CALENDARIO',    N'Calendario',         '/calendario',    'calendario',3),
    ('REPORTES',      N'Reportes',           '/reportes',      'reportes',  4),
    ('OPERACION',     N'Operación',          '/operacion',     'operacion', 5),
    ('CONFIGURACION', N'Configuración',      '/configuracion', 'ajustes',   6)
) AS s (Clave, Nombre, Ruta, Icono, Orden)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre], [Ruta], [Icono], [Orden]) VALUES (s.Clave, s.Nombre, s.Ruta, s.Icono, s.Orden);

-- Submódulos de Configuración.
MERGE [Seguridad].[Modulo] AS t
USING (
    SELECT s.Clave, s.Nombre, s.Ruta, s.Orden, p.[ModuloId] AS ModuloPadreId
    FROM (VALUES
        ('CONFIG_USUARIOS',   N'Usuarios',          '/configuracion/usuarios',   CAST(1 AS TINYINT)),
        ('CONFIG_ROLES',      N'Roles y permisos',  '/configuracion/roles',      2),
        ('CONFIG_PARAMETROS', N'Parámetros',        '/configuracion/parametros', 3)
    ) AS s (Clave, Nombre, Ruta, Orden)
    CROSS JOIN [Seguridad].[Modulo] AS p
    WHERE p.[Clave] = 'CONFIGURACION'
) AS s
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre], [Ruta], [Orden], [ModuloPadreId]) VALUES (s.Clave, s.Nombre, s.Ruta, s.Orden, s.ModuloPadreId);

------------------------------------------------------------------ Permisos (modulo.accion)
MERGE [Seguridad].[Permiso] AS t
USING (
    SELECT s.Clave, s.Nombre, m.[ModuloId]
    FROM (VALUES
        ('dashboard.ver',             'DASHBOARD',         N'Ver el dashboard'),
        ('alumnos.ver',               'ALUMNOS',           N'Ver alumnos'),
        ('alumnos.crear',             'ALUMNOS',           N'Registrar alumnos'),
        ('alumnos.editar',            'ALUMNOS',           N'Editar alumnos'),
        ('alumnos.baja',              'ALUMNOS',           N'Dar de baja alumnos'),
        ('alumnos.ver_datos_medicos', 'ALUMNOS',           N'Ver condiciones médicas del alumno'),
        ('horarios.asignar',          'ALUMNOS',           N'Registrar el horario del alumno'),
        ('pagos.ver',                 'ALUMNOS',           N'Ver información de pagos'),
        ('pagos.registrar',           'ALUMNOS',           N'Registrar pagos'),
        ('pagos.cancelar',            'ALUMNOS',           N'Cancelar pagos'),
        ('calendario.ver',            'CALENDARIO',        N'Ver el calendario'),
        ('calendario.editar',         'CALENDARIO',        N'Editar horarios, sesiones y suplencias'),
        ('asistencia.registrar',      'CALENDARIO',        N'Pasar asistencia'),
        ('profesores.ver',            'CALENDARIO',        N'Ver profesores'),
        ('profesores.editar',         'CALENDARIO',        N'Registrar y editar profesores y su tarifa'),
        ('profesores.pagar',          'CALENDARIO',        N'Calcular y registrar pagos a profesores'),
        ('reportes.ver',              'REPORTES',          N'Ver reportes'),
        ('reportes.exportar',         'REPORTES',          N'Exportar reportes'),
        ('reportes.cierre_mensual',   'REPORTES',          N'Hacer el cierre mensual'),
        ('gastos.ver',                'OPERACION',         N'Ver gastos'),
        ('gastos.registrar',          'OPERACION',         N'Registrar gastos'),
        ('gastos.cancelar',           'OPERACION',         N'Cancelar gastos'),
        ('mantenimiento.ver',         'OPERACION',         N'Ver mantenimientos y calidad del agua'),
        ('mantenimiento.registrar',   'OPERACION',         N'Registrar mantenimientos y mediciones de agua'),
        ('acceso.administrar',        'OPERACION',         N'Administrar lectores de huella y enrolar credenciales'),
        ('usuarios.ver',              'CONFIG_USUARIOS',   N'Ver usuarios'),
        ('usuarios.administrar',      'CONFIG_USUARIOS',   N'Crear, editar y desactivar usuarios'),
        ('roles.administrar',         'CONFIG_ROLES',      N'Administrar roles y permisos'),
        ('parametros.administrar',    'CONFIG_PARAMETROS', N'Editar parámetros del sistema'),
        ('bitacora.ver',              'CONFIGURACION',     N'Consultar la bitácora')
    ) AS s (Clave, Modulo, Nombre)
    JOIN [Seguridad].[Modulo] AS m ON m.[Clave] = s.Modulo
) AS s
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Nombre], [ModuloId]) VALUES (s.Clave, s.Nombre, s.ModuloId)
OUTPUT inserted.[PermisoId] INTO @PermisosNuevos;

------------------------------------------------------------------ Permisos por rol
-- ADMIN: todos los permisos, siempre.
INSERT INTO [Seguridad].[RolPermiso] ([RolId], [PermisoId])
SELECT r.[RolId], p.[PermisoId]
FROM [Seguridad].[Rol] AS r
CROSS JOIN [Seguridad].[Permiso] AS p
WHERE r.[Clave] = 'ADMIN'
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[RolPermiso] AS rp WHERE rp.[RolId] = r.[RolId] AND rp.[PermisoId] = p.[PermisoId]);

-- RECEPCION y PROFESOR: asignación base (solo para roles o permisos recién creados).
INSERT INTO [Seguridad].[RolPermiso] ([RolId], [PermisoId])
SELECT r.[RolId], p.[PermisoId]
FROM (VALUES
    ('RECEPCION', 'dashboard.ver'),
    ('RECEPCION', 'alumnos.ver'),
    ('RECEPCION', 'alumnos.crear'),
    ('RECEPCION', 'alumnos.editar'),
    ('RECEPCION', 'alumnos.baja'),
    ('RECEPCION', 'horarios.asignar'),
    ('RECEPCION', 'pagos.ver'),
    ('RECEPCION', 'pagos.registrar'),
    ('RECEPCION', 'calendario.ver'),
    ('RECEPCION', 'asistencia.registrar'),
    ('RECEPCION', 'profesores.ver'),
    ('RECEPCION', 'acceso.administrar'),
    ('PROFESOR',  'calendario.ver'),
    ('PROFESOR',  'alumnos.ver'),
    ('PROFESOR',  'asistencia.registrar')
) AS b (Rol, Permiso)
JOIN [Seguridad].[Rol]     AS r ON r.[Clave] = b.Rol
JOIN [Seguridad].[Permiso] AS p ON p.[Clave] = b.Permiso
WHERE (r.[RolId] IN (SELECT [RolId] FROM @RolesNuevos) OR p.[PermisoId] IN (SELECT [PermisoId] FROM @PermisosNuevos))
  AND NOT EXISTS (SELECT 1 FROM [Seguridad].[RolPermiso] AS rp WHERE rp.[RolId] = r.[RolId] AND rp.[PermisoId] = p.[PermisoId]);

------------------------------------------------------------------ Usuario administrador inicial
-- PasswordHash queda con un valor que NO corresponde a ninguna contraseña: nadie puede entrar
-- con este usuario hasta que la API le asigne una contraseña real (hash PBKDF2/Argon2).
IF NOT EXISTS (SELECT 1 FROM [Seguridad].[Usuario] WHERE [NombreUsuario] = N'admin')
BEGIN
    INSERT INTO [Seguridad].[Usuario] ([NombreUsuario], [NombreCompleto], [PasswordHash], [DebeCambiarPassword])
    VALUES (N'admin', N'Administrador del sistema', 'SIN_DEFINIR', 1);

    INSERT INTO [Seguridad].[UsuarioRol] ([UsuarioId], [RolId])
    SELECT u.[UsuarioId], r.[RolId]
    FROM [Seguridad].[Usuario] AS u
    CROSS JOIN [Seguridad].[Rol] AS r
    WHERE u.[NombreUsuario] = N'admin' AND r.[Clave] = 'ADMIN';
END;

GO
/*============================================================================================
  Datos iniciales · Reporte.Calendario
  Un renglón por día. Las fechas de SesionClase, CargoClase, Pago, Gasto y MovimientoCaja son
  llave foránea a esta tabla, así que el rango debe cubrir toda la operación.

  - Solo inserta los días que faltan: los cambios hechos a mano (días cerrados, temporadas,
    festivos locales) no se sobrescriben en un nuevo despliegue.
  - No depende de SET LANGUAGE ni de @@DATEFIRST: DiaSemana es ISO (1 = lunes … 7 = domingo).
  - Festivos oficiales (Ley Federal del Trabajo, art. 74). El 1 de octubre de cada 6 años
    (transmisión del Poder Ejecutivo) se incluye (2024, 2030).
  - EsDiaOperativo = 0 en festivos y, mientras el cliente no confirme qué días abre, en domingo
    (cambiar @DomingoOperativo a 1 si abren en domingo).
============================================================================================*/
PRINT N'Calendario...';

DECLARE @Desde            DATE = '20240101';
DECLARE @Hasta            DATE = '20351231';
DECLARE @DomingoOperativo BIT  = 0;

WITH Numeros AS
(
    SELECT TOP (DATEDIFF(DAY, @Desde, @Hasta) + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS n
    FROM sys.all_objects AS a
    CROSS JOIN sys.all_objects AS b
),
Dias AS
(
    SELECT d.Fecha,
           CAST(DATEDIFF(DAY, '19000101', d.Fecha) % 7 + 1 AS TINYINT) AS DiaSemana   -- 1900-01-01 fue lunes
    FROM Numeros
    CROSS APPLY (SELECT DATEADD(DAY, n, @Desde) AS Fecha) AS d
),
Base AS
(
    SELECT Fecha, DiaSemana,
           MONTH(Fecha) AS Mes,
           DAY(Fecha)   AS Dia,
           CASE
               WHEN MONTH(Fecha) = 1  AND DAY(Fecha) = 1                                   THEN N'Año Nuevo'
               WHEN MONTH(Fecha) = 2  AND DiaSemana = 1 AND DAY(Fecha) <= 7                 THEN N'Día de la Constitución'
               WHEN MONTH(Fecha) = 3  AND DiaSemana = 1 AND DAY(Fecha) BETWEEN 15 AND 21    THEN N'Natalicio de Benito Juárez'
               WHEN MONTH(Fecha) = 5  AND DAY(Fecha) = 1                                   THEN N'Día del Trabajo'
               WHEN MONTH(Fecha) = 9  AND DAY(Fecha) = 16                                  THEN N'Día de la Independencia'
               WHEN MONTH(Fecha) = 10 AND DAY(Fecha) = 1 AND (YEAR(Fecha) - 2024) % 6 = 0  THEN N'Transmisión del Poder Ejecutivo'
               WHEN MONTH(Fecha) = 11 AND DiaSemana = 1 AND DAY(Fecha) BETWEEN 15 AND 21    THEN N'Día de la Revolución'
               WHEN MONTH(Fecha) = 12 AND DAY(Fecha) = 25                                  THEN N'Navidad'
           END AS Feriado
    FROM Dias
)
INSERT INTO [Reporte].[Calendario]
    ([Fecha], [Anio], [Mes], [NombreMes], [Trimestre], [SemanaAnio], [SemanaMes], [DiaSemana], [NombreDia],
     [EsFinDeSemana], [EsFeriado], [DescripcionFeriado], [EsDiaOperativo], [TemporadaId])
SELECT b.Fecha,
       YEAR(b.Fecha),
       b.Mes,
       CHOOSE(b.Mes, N'Enero', N'Febrero', N'Marzo', N'Abril', N'Mayo', N'Junio', N'Julio',
                     N'Agosto', N'Septiembre', N'Octubre', N'Noviembre', N'Diciembre'),
       DATEPART(QUARTER, b.Fecha),
       DATEPART(ISO_WEEK, b.Fecha),
       (b.Dia - 1) / 7 + 1,
       b.DiaSemana,
       CHOOSE(b.DiaSemana, N'Lunes', N'Martes', N'Miércoles', N'Jueves', N'Viernes', N'Sábado', N'Domingo'),
       CASE WHEN b.DiaSemana IN (6, 7) THEN 1 ELSE 0 END,
       CASE WHEN b.Feriado IS NULL THEN 0 ELSE 1 END,
       b.Feriado,
       CASE WHEN b.Feriado IS NOT NULL THEN 0
            WHEN b.DiaSemana = 7 AND @DomingoOperativo = 0 THEN 0
            ELSE 1 END,
       NULL
FROM Base AS b
WHERE NOT EXISTS (SELECT 1 FROM [Reporte].[Calendario] AS c WHERE c.[Fecha] = b.Fecha);

GO
PRINT N'Base de datos AcuaticaValle instalada.';
GO
SET NOEXEC OFF;
GO
