/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdDesbloquearUsuario]
   Clave lógica  : Seguridad.DesbloquearUsuario   (StoredProcedure.json)
   Endpoint      : POST /api/seguridad/usuarios/{usuarioId}/desbloquear
   Descripción   : Quita el bloqueo temporal por intentos fallidos sin esperar a que venza.

   Parámetros    :
     @UsuarioId      Usuario.
     @ModificadoPor  Usuario que hace el cambio.

   Errores       : 50404 USUARIO_NO_ENCONTRADO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdDesbloquearUsuario]
    @UsuarioId     INT,
    @ModificadoPor INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    UPDATE Seguridad.Usuario
    SET IntentosFallidos     = 0,
        BloqueadoHastaUtc    = NULL,
        FechaModificacionUtc = SYSUTCDATETIME(),
        ModificadoPor        = @ModificadoPor
    WHERE UsuarioId = @UsuarioId;

    IF @@ROWCOUNT = 0
        THROW 50404, N'USUARIO_NO_ENCONTRADO|El usuario no existe.', 1;
END;
GO
