/* =====================================================================================
   Procedimiento : [Seguridad].[AVCmdRegistrarLoginFallido]
   Clave lógica  : Seguridad.RegistrarLoginFallido   (StoredProcedure.json)
   Usado por     : POST /api/seguridad/auth/iniciar-sesion (contraseña incorrecta)
   Descripción   : Suma un intento fallido. Al llegar a MAX_INTENTOS_LOGIN bloquea al usuario
                   MINUTOS_BLOQUEO_LOGIN minutos y reinicia el contador.
                   Los dos valores se leen de Catalogo.Parametro (5 y 15 si no existen).

   Parámetros    :
     @UsuarioId    Usuario que falló la contraseña.

   Resultado     : 1 fila -> ResultadoLoginFallido
                   (IntentosFallidos, BloqueadoHastaUtc, Bloqueado, IntentosMaximos)
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVCmdRegistrarLoginFallido]
    @UsuarioId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IntentosMaximos INT = TRY_CAST((SELECT Valor FROM Catalogo.Parametro WHERE Clave = 'MAX_INTENTOS_LOGIN')    AS INT);
    DECLARE @MinutosBloqueo  INT = TRY_CAST((SELECT Valor FROM Catalogo.Parametro WHERE Clave = 'MINUTOS_BLOQUEO_LOGIN') AS INT);

    IF @IntentosMaximos IS NULL OR @IntentosMaximos < 1 SET @IntentosMaximos = 5;
    IF @MinutosBloqueo  IS NULL OR @MinutosBloqueo  < 1 SET @MinutosBloqueo  = 15;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();

    UPDATE Seguridad.Usuario
    SET IntentosFallidos  = CASE WHEN IntentosFallidos + 1 >= @IntentosMaximos THEN 0 ELSE IntentosFallidos + 1 END,
        BloqueadoHastaUtc = CASE WHEN IntentosFallidos + 1 >= @IntentosMaximos
                                 THEN DATEADD(MINUTE, @MinutosBloqueo, @Ahora)
                                 ELSE BloqueadoHastaUtc END
    OUTPUT
        inserted.IntentosFallidos,
        inserted.BloqueadoHastaUtc,
        CAST(CASE WHEN inserted.BloqueadoHastaUtc > @Ahora THEN 1 ELSE 0 END AS BIT) AS Bloqueado,
        @IntentosMaximos AS IntentosMaximos
    WHERE UsuarioId = @UsuarioId;
END;
GO
