/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryResumenUsuarios]
   Clave lógica  : Seguridad.ResumenUsuarios   (StoredProcedure.json)
   Endpoint      : GET /api/seguridad/usuarios/resumen
   Descripción   : Totales para el encabezado de Configuración > Usuarios.
                   Los superusuarios solo se cuentan si @IncluirSuperusuarios = 1.

   Parámetros    :
     @IncluirSuperusuarios  1 solo cuando quien consulta es superusuario.

   Resultado     : 1 fila -> UsuarioResumenDto
                   (Activos, Inactivos, Bloqueados, ConPasswordTemporal, SesionesAbiertas)
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryResumenUsuarios]
    @IncluirSuperusuarios BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();
    DECLARE @RolSuperusuarioId SMALLINT = (SELECT RolId FROM Seguridad.Rol WHERE Clave = 'SUPERUSUARIO');

    ;WITH Usuarios AS (
        SELECT u.UsuarioId, u.Activo, u.BloqueadoHastaUtc, u.DebeCambiarPassword
        FROM Seguridad.Usuario AS u
        WHERE @IncluirSuperusuarios = 1
           OR NOT EXISTS (SELECT 1 FROM Seguridad.UsuarioRol AS ur WHERE ur.UsuarioId = u.UsuarioId AND ur.RolId = @RolSuperusuarioId)
    )
    SELECT
        Activos             = ISNULL(SUM(CASE WHEN Activo = 1 THEN 1 ELSE 0 END), 0),
        Inactivos           = ISNULL(SUM(CASE WHEN Activo = 0 THEN 1 ELSE 0 END), 0),
        Bloqueados          = ISNULL(SUM(CASE WHEN Activo = 1 AND BloqueadoHastaUtc > @Ahora THEN 1 ELSE 0 END), 0),
        ConPasswordTemporal = ISNULL(SUM(CASE WHEN Activo = 1 AND DebeCambiarPassword = 1 THEN 1 ELSE 0 END), 0),
        SesionesAbiertas    = (SELECT COUNT(*)
                               FROM Seguridad.SesionUsuario AS s
                               INNER JOIN Usuarios AS x ON x.UsuarioId = s.UsuarioId
                               WHERE s.FechaCierreUtc IS NULL AND s.FechaExpiraUtc > @Ahora)
    FROM Usuarios;
END;
GO
