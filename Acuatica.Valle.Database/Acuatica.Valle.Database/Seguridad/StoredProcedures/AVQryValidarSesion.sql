/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryValidarSesion]
   Clave lógica  : Seguridad.ValidarSesion   (StoredProcedure.json)
   Usado por     : TODAS las peticiones con token (validación del JWT).
   Descripción   : Confirma que la sesión del token sigue abierta y vigente y que el usuario
                   está activo. Devuelve además los permisos ACTUALES del usuario, así un
                   cambio de roles o permisos aplica en la siguiente petición sin esperar a
                   que venza el token.

                   Debe ser muy rápido: busca por llave primaria de SesionUsuario.

   Parámetros    :
     @SesionId     Claim "sid" del token.
     @UsuarioId    Claim "sub" del token.

   Resultado     : 0 o 1 fila -> SesionValidada
                   (UsuarioId, NombreUsuario, DebeCambiarPassword, EsSuperusuario,
                    Permisos = claves separadas por "|")
                   Sin filas = sesión cerrada, vencida o usuario desactivado.
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryValidarSesion]
    @SesionId  BIGINT,
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();

    DECLARE @NombreUsuario NVARCHAR(50), @DebeCambiarPassword BIT;

    SELECT
        @NombreUsuario       = u.NombreUsuario,
        @DebeCambiarPassword = u.DebeCambiarPassword
    FROM Seguridad.SesionUsuario AS s
    INNER JOIN Seguridad.Usuario AS u ON u.UsuarioId = s.UsuarioId
    WHERE s.SesionId       = @SesionId
      AND s.UsuarioId      = @UsuarioId
      AND s.FechaCierreUtc IS NULL
      AND s.FechaExpiraUtc > @Ahora
      AND u.Activo         = 1;

    IF @NombreUsuario IS NULL
    BEGIN
        -- Conjunto vacío con las mismas columnas (el repositorio lo interpreta como "sesión inválida").
        SELECT TOP (0)
            UsuarioId = CAST(NULL AS INT), NombreUsuario = CAST(NULL AS NVARCHAR(50)),
            DebeCambiarPassword = CAST(NULL AS BIT), EsSuperusuario = CAST(NULL AS BIT),
            Permisos = CAST(NULL AS VARCHAR(MAX));
        RETURN;
    END;

    DECLARE @EsSuperusuario BIT = CASE WHEN EXISTS (
        SELECT 1
        FROM Seguridad.UsuarioRol AS ur
        INNER JOIN Seguridad.Rol  AS r ON r.RolId = ur.RolId
        WHERE ur.UsuarioId = @UsuarioId AND r.Clave = 'SUPERUSUARIO' AND r.Activo = 1)
        THEN 1 ELSE 0 END;

    SELECT
        UsuarioId           = @UsuarioId,
        NombreUsuario       = @NombreUsuario,
        DebeCambiarPassword = @DebeCambiarPassword,
        EsSuperusuario      = @EsSuperusuario,
        Permisos            = (
            SELECT STRING_AGG(CAST(p.Clave AS VARCHAR(MAX)), '|')
            FROM Seguridad.Permiso AS p
            WHERE p.Activo = 1
              AND (   @EsSuperusuario = 1
                   OR EXISTS (SELECT 1
                              FROM Seguridad.UsuarioRol  AS ur
                              INNER JOIN Seguridad.Rol        AS r  ON r.RolId  = ur.RolId AND r.Activo = 1
                              INNER JOIN Seguridad.RolPermiso AS rp ON rp.RolId = r.RolId
                              WHERE ur.UsuarioId = @UsuarioId
                                AND rp.PermisoId = p.PermisoId)));
END;
GO
