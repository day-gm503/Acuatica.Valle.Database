/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryCredencialUsuario]
   Clave lógica  : Seguridad.CredencialUsuario   (StoredProcedure.json)
   Usado por     : POST /api/seguridad/auth/iniciar-sesion
                   PUT  /api/seguridad/cuenta/password
   Descripción   : Datos de acceso de un usuario (incluye el hash de la contraseña).
                   Busca por @UsuarioId o por @NombreUsuario (sin distinguir mayúsculas).

   Parámetros    :
     @UsuarioId      Identificador del usuario (opcional).
     @NombreUsuario  Nombre de usuario con el que inicia sesión (opcional).
                     Debe venir al menos uno de los dos.

   Resultado     : 0 o 1 fila -> CredencialUsuario
   Errores       : 50400 PARAMETRO_REQUERIDO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryCredencialUsuario]
    @UsuarioId     INT          = NULL,
    @NombreUsuario NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @UsuarioId IS NULL AND NULLIF(LTRIM(RTRIM(@NombreUsuario)), N'') IS NULL
        THROW 50400, N'PARAMETRO_REQUERIDO|Indica el usuario.', 1;

    SELECT
        u.UsuarioId,
        u.NombreUsuario,
        u.NombreCompleto,
        u.PasswordHash,
        u.Activo,
        u.DebeCambiarPassword,
        u.IntentosFallidos,
        u.BloqueadoHastaUtc,
        EsSuperusuario = CAST(CASE WHEN EXISTS (
                             SELECT 1
                             FROM Seguridad.UsuarioRol AS ur
                             INNER JOIN Seguridad.Rol  AS r ON r.RolId = ur.RolId
                             WHERE ur.UsuarioId = u.UsuarioId
                               AND r.Clave      = 'SUPERUSUARIO'
                               AND r.Activo     = 1)
                         THEN 1 ELSE 0 END AS BIT)
    FROM Seguridad.Usuario AS u
    WHERE (@UsuarioId     IS NULL OR u.UsuarioId     = @UsuarioId)
      AND (@NombreUsuario IS NULL OR u.NombreUsuario = LTRIM(RTRIM(@NombreUsuario)));
END;
GO
