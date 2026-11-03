/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdCambiarPassword]
   Clave lógica  : Seguridad.CambiarPassword   (StoredProcedure.json)
   Usado por     : PUT  /api/seguridad/cuenta/password                         (el propio usuario)
                   POST /api/seguridad/usuarios/{usuarioId}/restablecer-password (administración)
   Descripción   : Guarda el nuevo hash de la contraseña, quita el bloqueo y cierra las
                   sesiones abiertas del usuario (opcionalmente conserva la actual).
                   La validación de la política de contraseñas la hace el API (el SP nunca
                   recibe la contraseña, solo el hash).

   Parámetros    :
     @UsuarioId            Usuario.
     @PasswordHash         Hash PBKDF2 generado por el API.
     @DebeCambiarPassword  1 = obligará a cambiarla en el próximo inicio (restablecimiento).
     @ModificadoPor        Usuario que hace el cambio.
     @CerrarSesiones       1 = cierra las sesiones abiertas.
     @ExceptoSesionId      Sesión que se conserva (la del usuario que cambia su contraseña).
     @MotivoCierre         Motivo con el que se cierran las sesiones.

   Resultado     : 1 fila -> SesionesCerradas
   Errores       : 50404 USUARIO_NO_ENCONTRADO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdCambiarPassword]
    @UsuarioId           INT,
    @PasswordHash        VARCHAR(256),
    @DebeCambiarPassword BIT,
    @ModificadoPor       INT,
    @CerrarSesiones      BIT         = 1,
    @ExceptoSesionId     BIGINT      = NULL,
    @MotivoCierre        VARCHAR(30) = 'CAMBIO_PASSWORD'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();
    DECLARE @SesionesCerradas INT = 0;

    BEGIN TRANSACTION;

    UPDATE Seguridad.Usuario
    SET PasswordHash         = @PasswordHash,
        DebeCambiarPassword  = @DebeCambiarPassword,
        IntentosFallidos     = 0,
        BloqueadoHastaUtc    = NULL,
        FechaModificacionUtc = @Ahora,
        ModificadoPor        = @ModificadoPor
    WHERE UsuarioId = @UsuarioId;

    IF @@ROWCOUNT = 0
        THROW 50404, N'USUARIO_NO_ENCONTRADO|El usuario no existe.', 1;

    IF @CerrarSesiones = 1
    BEGIN
        UPDATE Seguridad.SesionUsuario
        SET FechaCierreUtc = @Ahora,
            MotivoCierre   = @MotivoCierre
        WHERE UsuarioId      = @UsuarioId
          AND FechaCierreUtc IS NULL
          AND (@ExceptoSesionId IS NULL OR SesionId <> @ExceptoSesionId);

        SET @SesionesCerradas = @@ROWCOUNT;
    END;

    COMMIT TRANSACTION;

    SELECT SesionesCerradas = @SesionesCerradas;
END;
GO
