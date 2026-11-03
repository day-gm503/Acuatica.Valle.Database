/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryListadoRoles]
   Clave lógica  : Seguridad.ListadoRoles   (StoredProcedure.json)
   Endpoint      : GET /api/seguridad/roles
   Descripción   : Catálogo de roles para asignarlos a usuarios.
                   SUPERUSUARIO solo aparece si @IncluirSuperusuario = 1 (el API lo activa
                   únicamente cuando quien consulta es superusuario).

   Parámetros    :
     @IncluirSuperusuario  Ver descripción.
     @SoloActivos          1 = solo roles activos (por defecto).

   Resultado     : RolDto
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryListadoRoles]
    @IncluirSuperusuario BIT = 0,
    @SoloActivos         BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        r.RolId,
        r.Clave,
        r.Nombre,
        r.Descripcion,
        r.EsSistema,
        r.Activo,
        UsuariosAsignados = (SELECT COUNT(*) FROM Seguridad.UsuarioRol AS ur
                             INNER JOIN Seguridad.Usuario AS u ON u.UsuarioId = ur.UsuarioId AND u.Activo = 1
                             WHERE ur.RolId = r.RolId),
        PermisosAsignados = (SELECT COUNT(*) FROM Seguridad.RolPermiso AS rp WHERE rp.RolId = r.RolId)
    FROM Seguridad.Rol AS r
    WHERE (@IncluirSuperusuario = 1 OR r.Clave <> 'SUPERUSUARIO')
      AND (@SoloActivos = 0 OR r.Activo = 1)
    ORDER BY CASE r.Clave WHEN 'SUPERUSUARIO' THEN 0 WHEN 'ADMIN' THEN 1 ELSE 2 END, r.Nombre;
END;
GO
