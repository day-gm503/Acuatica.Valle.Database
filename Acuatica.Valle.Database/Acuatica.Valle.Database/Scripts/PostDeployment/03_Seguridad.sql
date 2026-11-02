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
