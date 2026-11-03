/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdIniciarSesion]
   Clave lógica  : Seguridad.IniciarSesion   (StoredProcedure.json)
   Usado por     : POST /api/seguridad/auth/iniciar-sesion (contraseña correcta)
   Descripción   : Abre una sesión: reinicia intentos fallidos y bloqueo, registra el último
                   acceso, cierra como EXPIRADA las sesiones vencidas del usuario y guarda el
                   hash del token de renovación (nunca el token).

   Parámetros    :
     @UsuarioId           Usuario que inicia sesión.
     @RefreshTokenHash    SHA-256 (hex, 64 caracteres) del token de renovación.
     @FechaExpiraUtc      Vencimiento del token de renovación.
     @Ip, @UserAgent      Datos del cliente.
     @NuevoPasswordHash   Opcional. Si el hash guardado usa parámetros viejos (menos
                          iteraciones) el API lo regenera y lo manda aquí.

   Resultado     : 1 fila -> SesionId
   Errores       : 50404 USUARIO_NO_ENCONTRADO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdIniciarSesion]
    @UsuarioId         INT,
    @RefreshTokenHash  CHAR(64),
    @FechaExpiraUtc    DATETIME2(0),
    @Ip                VARCHAR(45)   = NULL,
    @UserAgent         NVARCHAR(400) = NULL,
    @NuevoPasswordHash VARCHAR(256)  = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();

    BEGIN TRANSACTION;

    UPDATE Seguridad.Usuario
    SET IntentosFallidos  = 0,
        BloqueadoHastaUtc = NULL,
        UltimoAccesoUtc   = @Ahora,
        PasswordHash      = ISNULL(@NuevoPasswordHash, PasswordHash)
    WHERE UsuarioId = @UsuarioId
      AND Activo    = 1;

    IF @@ROWCOUNT = 0
        THROW 50404, N'USUARIO_NO_ENCONTRADO|El usuario no existe o está desactivado.', 1;

    UPDATE Seguridad.SesionUsuario
    SET FechaCierreUtc = @Ahora,
        MotivoCierre   = 'EXPIRADA'
    WHERE UsuarioId      = @UsuarioId
      AND FechaCierreUtc IS NULL
      AND FechaExpiraUtc <= @Ahora;

    INSERT INTO Seguridad.SesionUsuario (UsuarioId, RefreshTokenHash, FechaInicioUtc, FechaExpiraUtc, Ip, UserAgent)
    VALUES (@UsuarioId, @RefreshTokenHash, @Ahora, @FechaExpiraUtc, @Ip, LEFT(@UserAgent, 400));

    DECLARE @SesionId BIGINT = CAST(SCOPE_IDENTITY() AS BIGINT);

    COMMIT TRANSACTION;

    SELECT SesionId = @SesionId;
END;
GO
