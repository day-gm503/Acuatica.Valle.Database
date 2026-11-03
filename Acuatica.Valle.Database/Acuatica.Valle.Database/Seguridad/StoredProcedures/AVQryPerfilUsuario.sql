/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryPerfilUsuario]
   Clave lógica  : Seguridad.PerfilUsuario   (StoredProcedure.json)
   Usado por     : POST /api/seguridad/auth/iniciar-sesion
                   POST /api/seguridad/auth/renovar
                   GET  /api/seguridad/cuenta/perfil
   Descripción   : Todo lo que el frontend necesita para armar la sesión: datos del usuario,
                   roles, permisos y el menú de módulos al que tiene acceso.
                   El rol SUPERUSUARIO recibe todos los permisos y módulos activos.

   Parámetros    :
     @UsuarioId    Usuario.

   Resultados (en este orden, el repositorio los lee igual):
     1) Usuario   -> PerfilUsuarioDto       (vacío si no existe)
     2) Roles     -> RolResumenDto
     3) Permisos  -> string (Clave)
     4) Módulos   -> ModuloMenuDto          (un módulo aparece si tiene algún permiso del
                                              usuario o si lo tiene alguno de sus submódulos)
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryPerfilUsuario]
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EsSuperusuario BIT = CASE WHEN EXISTS (
        SELECT 1
        FROM Seguridad.UsuarioRol AS ur
        INNER JOIN Seguridad.Rol  AS r ON r.RolId = ur.RolId
        WHERE ur.UsuarioId = @UsuarioId AND r.Clave = 'SUPERUSUARIO' AND r.Activo = 1)
        THEN 1 ELSE 0 END;

    DECLARE @Permisos TABLE (PermisoId SMALLINT PRIMARY KEY, Clave VARCHAR(60) NOT NULL, ModuloId SMALLINT NOT NULL);

    INSERT INTO @Permisos (PermisoId, Clave, ModuloId)
    SELECT p.PermisoId, p.Clave, p.ModuloId
    FROM Seguridad.Permiso AS p
    WHERE p.Activo = 1
      AND (   @EsSuperusuario = 1
           OR EXISTS (SELECT 1
                      FROM Seguridad.UsuarioRol       AS ur
                      INNER JOIN Seguridad.Rol        AS r  ON r.RolId  = ur.RolId AND r.Activo = 1
                      INNER JOIN Seguridad.RolPermiso AS rp ON rp.RolId = r.RolId
                      WHERE ur.UsuarioId = @UsuarioId
                        AND rp.PermisoId = p.PermisoId));

    /* ---------- 1) Usuario ---------- */
    SELECT
        u.UsuarioId,
        u.NombreUsuario,
        u.NombreCompleto,
        u.Correo,
        u.Telefono,
        u.DebeCambiarPassword,
        u.UltimoAccesoUtc,
        EsSuperusuario = @EsSuperusuario
    FROM Seguridad.Usuario AS u
    WHERE u.UsuarioId = @UsuarioId;

    /* ---------- 2) Roles ---------- */
    SELECT r.RolId, r.Clave, r.Nombre
    FROM Seguridad.UsuarioRol AS ur
    INNER JOIN Seguridad.Rol  AS r ON r.RolId = ur.RolId
    WHERE ur.UsuarioId = @UsuarioId
      AND r.Activo     = 1
    ORDER BY r.Nombre;

    /* ---------- 3) Permisos ---------- */
    SELECT Clave FROM @Permisos ORDER BY Clave;

    /* ---------- 4) Módulos (menú) ---------- */
    SELECT
        m.ModuloId,
        m.ModuloPadreId,
        m.Clave,
        m.Nombre,
        m.Ruta,
        m.Icono,
        m.Orden
    FROM Seguridad.Modulo AS m
    WHERE m.Activo = 1
      AND (   EXISTS (SELECT 1 FROM @Permisos AS p WHERE p.ModuloId = m.ModuloId)
           OR EXISTS (SELECT 1
                      FROM Seguridad.Modulo AS h
                      INNER JOIN @Permisos  AS p ON p.ModuloId = h.ModuloId
                      WHERE h.ModuloPadreId = m.ModuloId
                        AND h.Activo        = 1))
    ORDER BY CASE WHEN m.ModuloPadreId IS NULL THEN 0 ELSE 1 END, m.ModuloPadreId, m.Orden, m.Nombre;
END;
GO
