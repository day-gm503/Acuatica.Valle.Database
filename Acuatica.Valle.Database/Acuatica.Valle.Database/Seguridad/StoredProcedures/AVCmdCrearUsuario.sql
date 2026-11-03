/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdCrearUsuario]
   Clave lógica  : Seguridad.CrearUsuario   (StoredProcedure.json)
   Endpoint      : POST /api/seguridad/usuarios
   Descripción   : Crea un usuario con sus roles en una sola transacción.

   Parámetros    :
     @NombreUsuario        Login (único, sin distinguir mayúsculas).
     @NombreCompleto       Nombre para mostrar.
     @Correo, @Telefono    Opcionales. El correo es único cuando existe.
     @PasswordHash         Hash PBKDF2 generado por el API.
     @DebeCambiarPassword  1 = la cambiará en su primer inicio de sesión.
     @RolesIds             JSON con los ids de rol, ej. '[1,3]'. Al menos uno.
     @CreadoPor            Usuario que hace el alta.

   Resultado     : 1 fila -> UsuarioId
   Errores       : 50400 ROL_REQUERIDO, ROL_INVALIDO
                   50409 NOMBRE_USUARIO_DUPLICADO, CORREO_DUPLICADO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdCrearUsuario]
    @NombreUsuario       NVARCHAR(50),
    @NombreCompleto      NVARCHAR(150),
    @Correo              NVARCHAR(150) = NULL,
    @Telefono            VARCHAR(20)   = NULL,
    @PasswordHash        VARCHAR(256),
    @DebeCambiarPassword BIT           = 1,
    @RolesIds            NVARCHAR(MAX),
    @CreadoPor           INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    SET @NombreUsuario = LTRIM(RTRIM(@NombreUsuario));
    SET @Correo        = NULLIF(LTRIM(RTRIM(@Correo)), N'');

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

    IF EXISTS (SELECT 1 FROM Seguridad.Usuario WHERE NombreUsuario = @NombreUsuario)
        THROW 50409, N'NOMBRE_USUARIO_DUPLICADO|Ya existe un usuario con ese nombre de usuario.', 1;

    IF @Correo IS NOT NULL AND EXISTS (SELECT 1 FROM Seguridad.Usuario WHERE Correo = @Correo)
        THROW 50409, N'CORREO_DUPLICADO|Ya existe un usuario con ese correo.', 1;

    DECLARE @UsuarioId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO Seguridad.Usuario (NombreUsuario, NombreCompleto, Correo, Telefono, PasswordHash, DebeCambiarPassword, CreadoPor)
        VALUES (@NombreUsuario, LTRIM(RTRIM(@NombreCompleto)), @Correo, NULLIF(LTRIM(RTRIM(@Telefono)), ''), @PasswordHash, @DebeCambiarPassword, @CreadoPor);

        SET @UsuarioId = CAST(SCOPE_IDENTITY() AS INT);

        INSERT INTO Seguridad.UsuarioRol (UsuarioId, RolId, AsignadoPor)
        SELECT @UsuarioId, RolId, @CreadoPor FROM @Roles;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

        -- Dos altas simultáneas con el mismo usuario/correo: gana la primera, la otra recibe 409.
        IF ERROR_NUMBER() IN (2601, 2627)
            THROW 50409, N'USUARIO_DUPLICADO|Ya existe un usuario con ese nombre de usuario o correo.', 1;

        THROW;
    END CATCH;

    SELECT UsuarioId = @UsuarioId;
END;
GO
