/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdCerrarSesion]
   Clave lógica  : Seguridad.CerrarSesion   (StoredProcedure.json)
   Usado por     : POST   /api/seguridad/auth/cerrar-sesion
                   DELETE /api/seguridad/cuenta/sesiones/{sesionId}
   Descripción   : Cierra una sesión abierta, identificada por su id o por el hash de su token
                   de renovación. Al cerrarla, el access token deja de servir de inmediato
                   (el API valida la sesión en cada petición).

   Parámetros    :
     @SesionId          Sesión a cerrar (opcional).
     @RefreshTokenHash  Hash del token de renovación (opcional, para cerrar desde la cookie).
     @UsuarioId         Si se indica, solo cierra la sesión si pertenece a ese usuario.
     @Motivo            LOGOUT, REVOCADA…

   Resultado     : 0 o 1 fila -> SesionCerrada (SesionId, UsuarioId)
   Errores       : 50400 PARAMETRO_REQUERIDO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdCerrarSesion]
    @SesionId         BIGINT      = NULL,
    @RefreshTokenHash CHAR(64)    = NULL,
    @UsuarioId        INT         = NULL,
    @Motivo           VARCHAR(30) = 'LOGOUT'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @SesionId IS NULL AND @RefreshTokenHash IS NULL
        THROW 50400, N'PARAMETRO_REQUERIDO|Indica la sesión a cerrar.', 1;

    UPDATE Seguridad.SesionUsuario
    SET FechaCierreUtc = SYSUTCDATETIME(),
        MotivoCierre   = @Motivo
    OUTPUT inserted.SesionId, inserted.UsuarioId
    WHERE FechaCierreUtc IS NULL
      AND (   (@SesionId         IS NOT NULL AND SesionId         = @SesionId)
           OR (@RefreshTokenHash IS NOT NULL AND RefreshTokenHash = @RefreshTokenHash))
      AND (@UsuarioId IS NULL OR UsuarioId = @UsuarioId);
END;
GO
