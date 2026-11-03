/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdActualizarUsuario]
   Clave lógica  : Seguridad.ActualizarUsuario   (StoredProcedure.json)
   Endpoint      : PUT /api/seguridad/usuarios/{usuarioId}
   Descripción   : Actualiza los datos generales y sincroniza los roles de un usuario.
                   El nombre de usuario (login) NO se cambia.
                   Usa RowVer: si alguien más modificó el usuario desde que se leyó, falla con
                   409 para no pisar sus cambios.

   Parámetros    :
     @UsuarioId            Usuario.
     @NombreCompleto       Nombre para mostrar.
     @Correo, @Telefono    Opcionales.
     @RolesIds             JSON con los ids de rol, ej. '[1,3]'. Al menos uno.
     @RowVer               Versión leída en GET /usuarios/{id}.
     @ModificadoPor        Usuario que hace el cambio.

   Resultado     : 1 fila -> RowVer (nueva versión)
   Errores       : 50400 ROL_REQUERIDO, ROL_INVALIDO
                   50404 USUARIO_NO_ENCONTRADO
                   50409 CONCURRENCIA, CORREO_DUPLICADO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdActualizarUsuario]
    @UsuarioId      INT,
    @NombreCompleto NVARCHAR(150),
    @Correo         NVARCHAR(150) = NULL,
    @Telefono       VARCHAR(20)   = NULL,
    @RolesIds       NVARCHAR(MAX),
    @RowVer         BINARY(8),
    @ModificadoPor  INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @Correo = NULLIF(LTRIM(RTRIM(@Correo)), N'');

    DECLARE @Roles TABLE (RolId SMALLINT PRIMARY KEY);

    INSERT INTO @Roles (RolId)
    SELECT DISTINCT TRY_CAST([value] AS SMALLINT)
    FROM OPENJSON(ISNULL(@RolesIds, N'[]'))
    WHERE TRY_CAST([value] AS SMALLINT) IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @Roles)
        THROW 50400, N'ROL_REQUERIDO|Asigna al menos un rol al usuario.', 1;

    IF EXISTS (SELECT 1 FROM @Roles AS x
               WHERE NOT EXISTS (SELECT 1 FROM Seguridad.Rol AS r WHERE r.RolId = x.RolId AND r.Activo = 1))
        THROW 50400, N'ROL_INVALIDO|Alguno de los roles no existe o está inactivo.', 1;

    IF @Correo IS NOT NULL AND EXISTS (SELECT 1 FROM Seguridad.Usuario WHERE Correo = @Correo AND UsuarioId <> @UsuarioId)
        THROW 50409, N'CORREO_DUPLICADO|Ya existe otro usuario con ese correo.', 1;

    BEGIN TRANSACTION;

    UPDATE Seguridad.Usuario
    SET NombreCompleto       = LTRIM(RTRIM(@NombreCompleto)),
        Correo               = @Correo,
        Telefono             = NULLIF(LTRIM(RTRIM(@Telefono)), ''),
        FechaModificacionUtc = SYSUTCDATETIME(),
        ModificadoPor        = @ModificadoPor
    WHERE UsuarioId = @UsuarioId
      AND RowVer    = @RowVer;

    IF @@ROWCOUNT = 0
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM Seguridad.Usuario WHERE UsuarioId = @UsuarioId)
            THROW 50404, N'USUARIO_NO_ENCONTRADO|El usuario no existe.', 1;

        THROW 50409, N'CONCURRENCIA|Otra persona modificó este usuario. Vuelve a cargarlo e intenta de nuevo.', 1;
    END;

    DELETE ur
    FROM Seguridad.UsuarioRol AS ur
    WHERE ur.UsuarioId = @UsuarioId
      AND NOT EXISTS (SELECT 1 FROM @Roles AS x WHERE x.RolId = ur.RolId);

    INSERT INTO Seguridad.UsuarioRol (UsuarioId, RolId, AsignadoPor)
    SELECT @UsuarioId, x.RolId, @ModificadoPor
    FROM @Roles AS x
    WHERE NOT EXISTS (SELECT 1 FROM Seguridad.UsuarioRol AS ur WHERE ur.UsuarioId = @UsuarioId AND ur.RolId = x.RolId);

    COMMIT TRANSACTION;

    SELECT RowVer FROM Seguridad.Usuario WHERE UsuarioId = @UsuarioId;
END;
GO
