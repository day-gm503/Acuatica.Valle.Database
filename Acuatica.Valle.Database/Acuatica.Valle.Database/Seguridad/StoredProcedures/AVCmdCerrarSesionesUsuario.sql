/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdCerrarSesionesUsuario]
   Clave lógica  : Seguridad.CerrarSesionesUsuario   (StoredProcedure.json)
   Usado por     : POST /api/seguridad/cuenta/sesiones/cerrar-otras
                   POST /api/seguridad/usuarios/{usuarioId}/cerrar-sesiones
   Descripción   : Cierra todas las sesiones abiertas de un usuario, opcionalmente excepto una
                   (la sesión desde la que se hace la operación).

   Parámetros    :
     @UsuarioId        Usuario.
     @ExceptoSesionId  Sesión que se conserva (opcional).
     @Motivo           REVOCADA, CAMBIO_PASSWORD, USUARIO_DESACTIVADO…

   Resultado     : 1 fila -> SesionesCerradas
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdCerrarSesionesUsuario]
    @UsuarioId       INT,
    @ExceptoSesionId BIGINT      = NULL,
    @Motivo          VARCHAR(30) = 'REVOCADA'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    UPDATE Seguridad.SesionUsuario
    SET FechaCierreUtc = SYSUTCDATETIME(),
        MotivoCierre   = @Motivo
    WHERE UsuarioId      = @UsuarioId
      AND FechaCierreUtc IS NULL
      AND (@ExceptoSesionId IS NULL OR SesionId <> @ExceptoSesionId);

    SELECT SesionesCerradas = @@ROWCOUNT;
END;
GO
