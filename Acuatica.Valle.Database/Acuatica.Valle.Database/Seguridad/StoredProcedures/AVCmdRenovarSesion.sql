/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdRenovarSesion]
   Clave lógica  : Seguridad.RenovarSesion   (StoredProcedure.json)
   Usado por     : POST /api/seguridad/auth/renovar
   Descripción   : Valida el token de renovación y lo ROTA: guarda el hash del nuevo token, así
                   el anterior deja de servir. Si la sesión ya venció la cierra como EXPIRADA;
                   si el usuario fue desactivado la cierra como REVOCADA.

   Parámetros    :
     @RefreshTokenHashActual  Hash del token que mandó el navegador (cookie).
     @RefreshTokenHashNuevo   Hash del token nuevo.
     @FechaExpiraUtc          Vencimiento del token nuevo.
     @Ip, @UserAgent          Datos del cliente.

   Resultado     : 1 fila -> ResultadoRenovacion (Resultado, SesionId, UsuarioId)
                   Resultado: RENOVADA | NO_EXISTE | CERRADA | EXPIRADA | USUARIO_INACTIVO
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdRenovarSesion]
    @RefreshTokenHashActual CHAR(64),
    @RefreshTokenHashNuevo  CHAR(64),
    @FechaExpiraUtc         DATETIME2(0),
    @Ip                     VARCHAR(45)   = NULL,
    @UserAgent              NVARCHAR(400) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Ahora     DATETIME2(0) = SYSUTCDATETIME();
    DECLARE @Resultado VARCHAR(20)  = 'NO_EXISTE';
    DECLARE @SesionId  BIGINT, @UsuarioId INT, @FechaExpira DATETIME2(0), @FechaCierre DATETIME2(0), @UsuarioActivo BIT;

    BEGIN TRANSACTION;

    -- UPDLOCK/HOLDLOCK: dos renovaciones simultáneas con el mismo token no pueden rotarlo dos veces.
    SELECT
        @SesionId      = s.SesionId,
        @UsuarioId     = s.UsuarioId,
        @FechaExpira   = s.FechaExpiraUtc,
        @FechaCierre   = s.FechaCierreUtc,
        @UsuarioActivo = u.Activo
    FROM Seguridad.SesionUsuario AS s WITH (UPDLOCK, HOLDLOCK)
    INNER JOIN Seguridad.Usuario AS u ON u.UsuarioId = s.UsuarioId
    WHERE s.RefreshTokenHash = @RefreshTokenHashActual;

    IF @SesionId IS NOT NULL
    BEGIN
        IF @FechaCierre IS NOT NULL
            SET @Resultado = 'CERRADA';
        ELSE IF @FechaExpira <= @Ahora
        BEGIN
            SET @Resultado = 'EXPIRADA';
            UPDATE Seguridad.SesionUsuario SET FechaCierreUtc = @Ahora, MotivoCierre = 'EXPIRADA' WHERE SesionId = @SesionId;
        END
        ELSE IF @UsuarioActivo = 0
        BEGIN
            SET @Resultado = 'USUARIO_INACTIVO';
            UPDATE Seguridad.SesionUsuario SET FechaCierreUtc = @Ahora, MotivoCierre = 'REVOCADA' WHERE SesionId = @SesionId;
        END
        ELSE
        BEGIN
            SET @Resultado = 'RENOVADA';

            UPDATE Seguridad.SesionUsuario
            SET RefreshTokenHash = @RefreshTokenHashNuevo,
                FechaExpiraUtc   = @FechaExpiraUtc,
                Ip               = ISNULL(@Ip, Ip),
                UserAgent        = ISNULL(LEFT(@UserAgent, 400), UserAgent)
            WHERE SesionId = @SesionId;

            UPDATE Seguridad.Usuario SET UltimoAccesoUtc = @Ahora WHERE UsuarioId = @UsuarioId;
        END
    END

    COMMIT TRANSACTION;

    SELECT
        Resultado = @Resultado,
        SesionId  = @SesionId,
        UsuarioId = @UsuarioId;
END;
GO
