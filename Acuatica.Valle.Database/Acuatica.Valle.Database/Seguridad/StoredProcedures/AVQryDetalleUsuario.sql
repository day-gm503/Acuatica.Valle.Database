/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryDetalleUsuario]
   Clave lógica  : Seguridad.DetalleUsuario   (StoredProcedure.json)
   Endpoint      : GET /api/seguridad/usuarios/{usuarioId}
   Descripción   : Ficha de un usuario con sus roles. Incluye RowVer para la edición
                   (concurrencia optimista). Nunca devuelve el hash de la contraseña.

   Parámetros    :
     @UsuarioId    Usuario.

   Resultados (en este orden):
     1) Usuario -> UsuarioDetalleDto (vacío si no existe)
     2) Roles   -> RolResumenDto
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryDetalleUsuario]
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();

    /* ---------- 1) Usuario ---------- */
    SELECT
        u.UsuarioId,
        u.NombreUsuario,
        u.NombreCompleto,
        u.Correo,
        u.Telefono,
        u.Activo,
        u.DebeCambiarPassword,
        u.IntentosFallidos,
        Bloqueado = CAST(CASE WHEN u.BloqueadoHastaUtc > @Ahora THEN 1 ELSE 0 END AS BIT),
        u.BloqueadoHastaUtc,
        u.UltimoAccesoUtc,
        u.FechaCreacionUtc,
        CreadoPorNombre = c.NombreCompleto,
        u.FechaModificacionUtc,
        ModificadoPorNombre = m.NombreCompleto,
        EsSuperusuario = CAST(CASE WHEN EXISTS (
                             SELECT 1 FROM Seguridad.UsuarioRol AS ur
                             INNER JOIN Seguridad.Rol AS r ON r.RolId = ur.RolId
                             WHERE ur.UsuarioId = u.UsuarioId AND r.Clave = 'SUPERUSUARIO')
                         THEN 1 ELSE 0 END AS BIT),
        SesionesAbiertas = (SELECT COUNT(*) FROM Seguridad.SesionUsuario AS s
                            WHERE s.UsuarioId = u.UsuarioId AND s.FechaCierreUtc IS NULL AND s.FechaExpiraUtc > @Ahora),
        u.RowVer
    FROM Seguridad.Usuario AS u
    LEFT JOIN Seguridad.Usuario AS c ON c.UsuarioId = u.CreadoPor
    LEFT JOIN Seguridad.Usuario AS m ON m.UsuarioId = u.ModificadoPor
    WHERE u.UsuarioId = @UsuarioId;

    /* ---------- 2) Roles ---------- */
    SELECT r.RolId, r.Clave, r.Nombre
    FROM Seguridad.UsuarioRol AS ur
    INNER JOIN Seguridad.Rol  AS r ON r.RolId = ur.RolId
    WHERE ur.UsuarioId = @UsuarioId
    ORDER BY r.Nombre;
END;
GO
