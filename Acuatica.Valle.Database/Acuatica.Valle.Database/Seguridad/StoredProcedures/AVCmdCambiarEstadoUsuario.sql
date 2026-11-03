/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdCambiarEstadoUsuario]
   Clave lógica  : Seguridad.CambiarEstadoUsuario   (StoredProcedure.json)
   Endpoint      : PATCH /api/seguridad/usuarios/{usuarioId}/estado
   Descripción   : Activa o desactiva un usuario. Al desactivarlo cierra todas sus sesiones,
                   así pierde el acceso en su siguiente petición.

   Parámetros    :
     @UsuarioId      Usuario.
     @Activo         1 activar, 0 desactivar.
     @ModificadoPor  Usuario que hace el cambio.

   Resultado     : 1 fila -> SesionesCerradas
   Errores       : 50404 USUARIO_NO_ENCONTRADO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdCambiarEstadoUsuario]
    @UsuarioId     INT,
    @Activo        BIT,
    @ModificadoPor INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();
    DECLARE @SesionesCerradas INT = 0;

    BEGIN TRANSACTION;

    UPDATE Seguridad.Usuario
    SET Activo               = @Activo,
        FechaModificacionUtc = @Ahora,
        ModificadoPor        = @ModificadoPor
    WHERE UsuarioId = @UsuarioId;

    IF @@ROWCOUNT = 0
        THROW 50404, N'USUARIO_NO_ENCONTRADO|El usuario no existe.', 1;

    IF @Activo = 0
    BEGIN
        UPDATE Seguridad.SesionUsuario
        SET FechaCierreUtc = @Ahora,
            MotivoCierre   = 'USUARIO_DESACTIVADO'
        WHERE UsuarioId      = @UsuarioId
          AND FechaCierreUtc IS NULL;

        SET @SesionesCerradas = @@ROWCOUNT;
    END;

    COMMIT TRANSACTION;

    SELECT SesionesCerradas = @SesionesCerradas;
END;
GO
