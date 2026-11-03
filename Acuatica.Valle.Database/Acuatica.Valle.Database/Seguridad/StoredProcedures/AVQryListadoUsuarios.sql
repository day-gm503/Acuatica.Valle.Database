/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryListadoUsuarios]
   Clave lógica  : Seguridad.ListadoUsuarios   (StoredProcedure.json)
   Endpoint      : GET /api/seguridad/usuarios
   Descripción   : Listado paginado, filtrado y ordenado de usuarios del sistema.
                   Los usuarios con rol SUPERUSUARIO solo aparecen si @IncluirSuperusuarios = 1
                   (el API lo activa únicamente cuando quien consulta también es superusuario).

   Parámetros    :
     @Buscar                Texto en usuario, nombre o correo (opcional).
     @Activo                1 activos, 0 inactivos, NULL todos.
     @RolId                 Solo usuarios con ese rol (opcional).
     @IncluirSuperusuarios  Ver descripción.
     @NumeroPagina          Página (desde 1).
     @TamanoPagina          Registros por página.
     @OrdenarPor            NombreUsuario | NombreCompleto | UltimoAcceso | FechaCreacion
     @Direccion             ASC | DESC

   Resultados (en este orden):
     1) Total de registros (INT)
     2) Página de usuarios -> UsuarioDto
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryListadoUsuarios]
    @Buscar               NVARCHAR(100) = NULL,
    @Activo               BIT           = NULL,
    @RolId                SMALLINT      = NULL,
    @IncluirSuperusuarios BIT           = 0,
    @NumeroPagina         INT           = 1,
    @TamanoPagina         INT           = 20,
    @OrdenarPor           VARCHAR(30)   = 'NombreCompleto',
    @Direccion            VARCHAR(4)    = 'ASC'
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();
    DECLARE @Patron NVARCHAR(102) = CASE WHEN NULLIF(LTRIM(RTRIM(@Buscar)), N'') IS NULL
                                         THEN NULL ELSE N'%' + LTRIM(RTRIM(@Buscar)) + N'%' END;

    IF @NumeroPagina IS NULL OR @NumeroPagina < 1 SET @NumeroPagina = 1;
    IF @TamanoPagina IS NULL OR @TamanoPagina < 1 SET @TamanoPagina = 20;

    DECLARE @RolSuperusuarioId SMALLINT = (SELECT RolId FROM Seguridad.Rol WHERE Clave = 'SUPERUSUARIO');

    SELECT u.UsuarioId
    INTO #Filtrados
    FROM Seguridad.Usuario AS u
    WHERE (@Activo IS NULL OR u.Activo = @Activo)
      AND (@Patron IS NULL OR u.NombreUsuario LIKE @Patron OR u.NombreCompleto LIKE @Patron OR u.Correo LIKE @Patron)
      AND (@RolId  IS NULL OR EXISTS (SELECT 1 FROM Seguridad.UsuarioRol AS ur WHERE ur.UsuarioId = u.UsuarioId AND ur.RolId = @RolId))
      AND (   @IncluirSuperusuarios = 1
           OR NOT EXISTS (SELECT 1 FROM Seguridad.UsuarioRol AS ur WHERE ur.UsuarioId = u.UsuarioId AND ur.RolId = @RolSuperusuarioId));

    /* ---------- 1) Total ---------- */
    SELECT COUNT(*) FROM #Filtrados;

    /* ---------- 2) Página ---------- */
    SELECT
        u.UsuarioId,
        u.NombreUsuario,
        u.NombreCompleto,
        u.Correo,
        u.Telefono,
        u.Activo,
        Bloqueado = CAST(CASE WHEN u.BloqueadoHastaUtc > @Ahora THEN 1 ELSE 0 END AS BIT),
        u.BloqueadoHastaUtc,
        u.DebeCambiarPassword,
        u.UltimoAccesoUtc,
        u.FechaCreacionUtc,
        EsSuperusuario = CAST(CASE WHEN EXISTS (SELECT 1 FROM Seguridad.UsuarioRol AS ur
                                                WHERE ur.UsuarioId = u.UsuarioId AND ur.RolId = @RolSuperusuarioId)
                              THEN 1 ELSE 0 END AS BIT),
        Roles = (SELECT STRING_AGG(r.Nombre, N', ') WITHIN GROUP (ORDER BY r.Nombre)
                 FROM Seguridad.UsuarioRol AS ur
                 INNER JOIN Seguridad.Rol  AS r ON r.RolId = ur.RolId
                 WHERE ur.UsuarioId = u.UsuarioId),
        SesionesAbiertas = (SELECT COUNT(*) FROM Seguridad.SesionUsuario AS s
                            WHERE s.UsuarioId = u.UsuarioId AND s.FechaCierreUtc IS NULL AND s.FechaExpiraUtc > @Ahora)
    FROM #Filtrados AS f
    INNER JOIN Seguridad.Usuario AS u ON u.UsuarioId = f.UsuarioId
    ORDER BY
        CASE WHEN @OrdenarPor = 'NombreUsuario'  AND @Direccion = 'ASC'  THEN u.NombreUsuario    END ASC,
        CASE WHEN @OrdenarPor = 'NombreUsuario'  AND @Direccion = 'DESC' THEN u.NombreUsuario    END DESC,
        CASE WHEN @OrdenarPor = 'NombreCompleto' AND @Direccion = 'ASC'  THEN u.NombreCompleto   END ASC,
        CASE WHEN @OrdenarPor = 'NombreCompleto' AND @Direccion = 'DESC' THEN u.NombreCompleto   END DESC,
        CASE WHEN @OrdenarPor = 'UltimoAcceso'   AND @Direccion = 'ASC'  THEN u.UltimoAccesoUtc  END ASC,
        CASE WHEN @OrdenarPor = 'UltimoAcceso'   AND @Direccion = 'DESC' THEN u.UltimoAccesoUtc  END DESC,
        CASE WHEN @OrdenarPor = 'FechaCreacion'  AND @Direccion = 'ASC'  THEN u.FechaCreacionUtc END ASC,
        CASE WHEN @OrdenarPor = 'FechaCreacion'  AND @Direccion = 'DESC' THEN u.FechaCreacionUtc END DESC,
        u.UsuarioId
    OFFSET (@NumeroPagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO
