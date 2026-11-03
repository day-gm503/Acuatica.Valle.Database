/*============================================================================================
  Script manual · Usuario "root" (rol SUPERUSUARIO)

  Para qué : Cuenta de los DESARROLLADORES del sistema. Tiene acceso a todo sin restricción
             (el API no le valida permisos) y no aparece ni se puede administrar desde la
             pantalla de usuarios por quien no sea superusuario.
             El usuario "admin" (rol ADMIN) es el de los administradores del negocio.

  Datos    : Usuario     root
             Contraseña  1245   (temporal: el sistema obliga a cambiarla en el primer inicio)
             Rol         SUPERUSUARIO

  Cómo     : Ejecutar UNA vez en la base de Acuática Valle (SSMS o sqlcmd), después del
             despliegue del proyecto de base de datos y de los SPs de Seguridad.
             Es idempotente: si root ya existe solo le asegura el rol; NO cambia su
             contraseña salvo que pongas @RestablecerPassword = 1.

  Nota     : El hash es PBKDF2-SHA256 (210 000 iteraciones, sal aleatoria), el mismo formato
             que genera el API. La contraseña nunca se guarda en texto.
             Este script NO forma parte del post-deployment a propósito: una contraseña
             conocida no debe llegar sola a producción.
============================================================================================*/
-- sqlcmd (sin -I) y algunas herramientas abren la conexión con QUOTED_IDENTIFIER OFF; las tablas
-- con índices filtrados lo exigen en ON.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @RestablecerPassword BIT = 0;   -- 1 = vuelve a poner la contraseña 1245 (y obliga a cambiarla)

DECLARE @NombreUsuario  NVARCHAR(50)  = N'root';
DECLARE @NombreCompleto NVARCHAR(150) = N'Desarrollador del sistema';
DECLARE @PasswordHash   VARCHAR(256)  = 'PBKDF2-SHA256$210000$a3n9fSaUNlt/mNzGom7EJg==$dwx0LW6t4tvqn8zPNYmK9i+t5n3Z2wn9I9zHJNfXPX4=';  -- 1245

BEGIN TRANSACTION;

------------------------------------------------------------------ 1. Rol SUPERUSUARIO
-- También lo crea 03_Seguridad.sql; se repite aquí para que el script funcione solo.
IF NOT EXISTS (SELECT 1 FROM Seguridad.Rol WHERE Clave = 'SUPERUSUARIO')
    INSERT INTO Seguridad.Rol (Clave, Nombre, Descripcion, EsSistema)
    VALUES ('SUPERUSUARIO', N'Superusuario', N'Desarrolladores del sistema. Acceso total sin restricciones.', 1);

------------------------------------------------------------------ 2. Usuario root
IF NOT EXISTS (SELECT 1 FROM Seguridad.Usuario WHERE NombreUsuario = @NombreUsuario)
BEGIN
    INSERT INTO Seguridad.Usuario (NombreUsuario, NombreCompleto, PasswordHash, DebeCambiarPassword, Activo)
    VALUES (@NombreUsuario, @NombreCompleto, @PasswordHash, 1, 1);

    PRINT N'Usuario root creado.';
END
ELSE IF @RestablecerPassword = 1
BEGIN
    UPDATE Seguridad.Usuario
    SET PasswordHash         = @PasswordHash,
        DebeCambiarPassword  = 1,
        IntentosFallidos     = 0,
        BloqueadoHastaUtc    = NULL,
        Activo               = 1,
        FechaModificacionUtc = SYSUTCDATETIME()
    WHERE NombreUsuario = @NombreUsuario;

    -- Cualquier sesión abierta de root deja de servir.
    UPDATE s
    SET FechaCierreUtc = SYSUTCDATETIME(), MotivoCierre = 'CAMBIO_PASSWORD'
    FROM Seguridad.SesionUsuario AS s
    INNER JOIN Seguridad.Usuario AS u ON u.UsuarioId = s.UsuarioId
    WHERE u.NombreUsuario = @NombreUsuario AND s.FechaCierreUtc IS NULL;

    PRINT N'Contraseña de root restablecida a la temporal.';
END
ELSE
    PRINT N'El usuario root ya existía; su contraseña no se modificó.';

------------------------------------------------------------------ 3. Rol asignado
INSERT INTO Seguridad.UsuarioRol (UsuarioId, RolId)
SELECT u.UsuarioId, r.RolId
FROM Seguridad.Usuario AS u
CROSS JOIN Seguridad.Rol AS r
WHERE u.NombreUsuario = @NombreUsuario
  AND r.Clave         = 'SUPERUSUARIO'
  AND NOT EXISTS (SELECT 1 FROM Seguridad.UsuarioRol AS ur WHERE ur.UsuarioId = u.UsuarioId AND ur.RolId = r.RolId);

COMMIT TRANSACTION;

------------------------------------------------------------------ Verificación
SELECT u.UsuarioId, u.NombreUsuario, u.NombreCompleto, u.Activo, u.DebeCambiarPassword,
       Roles = STRING_AGG(r.Clave, ', ')
FROM Seguridad.Usuario AS u
LEFT JOIN Seguridad.UsuarioRol AS ur ON ur.UsuarioId = u.UsuarioId
LEFT JOIN Seguridad.Rol        AS r  ON r.RolId      = ur.RolId
WHERE u.NombreUsuario = @NombreUsuario
GROUP BY u.UsuarioId, u.NombreUsuario, u.NombreCompleto, u.Activo, u.DebeCambiarPassword;
