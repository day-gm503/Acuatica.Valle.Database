/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdRegistrarBitacora]
   Clave lógica  : Seguridad.RegistrarBitacora   (StoredProcedure.json)
   Usado por     : Filtro global de bitácora del API (todo POST, PUT, PATCH y DELETE).
   Descripción   : Inserta un renglón en Seguridad.Bitacora. Sin transacción ni validaciones:
                   registrar nunca debe hacer fallar la operación del usuario.

   Parámetros    :
     @UsuarioId           Quién (NULL si no hay sesión, ej. un inicio de sesión fallido).
     @Accion              LOGIN, CREAR_USUARIO, CAMBIAR_PASSWORD…
     @Entidad, @EntidadId Qué registro se afectó (opcional).
     @ValoresAnteriores   JSON con el estado previo (opcional).
     @ValoresNuevos       JSON con la solicitud (sin contraseñas ni tokens), ruta, código HTTP…
     @Exito               1 si la operación terminó bien.
     @Ip                  IP del cliente.
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdRegistrarBitacora]
    @UsuarioId         INT           = NULL,
    @Accion            VARCHAR(50),
    @Entidad           VARCHAR(60)   = NULL,
    @EntidadId         VARCHAR(40)   = NULL,
    @ValoresAnteriores NVARCHAR(MAX) = NULL,
    @ValoresNuevos     NVARCHAR(MAX) = NULL,
    @Exito             BIT           = 1,
    @Ip                VARCHAR(45)   = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Seguridad.Bitacora (UsuarioId, Accion, Entidad, EntidadId, ValoresAnteriores, ValoresNuevos, Exito, Ip)
    VALUES (@UsuarioId, LEFT(@Accion, 50), LEFT(@Entidad, 60), LEFT(@EntidadId, 40), @ValoresAnteriores, @ValoresNuevos, @Exito, LEFT(@Ip, 45));
END;
GO
