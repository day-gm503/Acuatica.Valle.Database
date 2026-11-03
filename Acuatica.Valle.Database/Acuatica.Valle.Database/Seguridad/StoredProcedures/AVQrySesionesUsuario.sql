/* =====================================================================================
   Procedimiento : [Seguridad].[AVQrySesionesUsuario]
   Clave lógica  : Seguridad.SesionesUsuario   (StoredProcedure.json)
   Usado por     : GET /api/seguridad/cuenta/sesiones
                   GET /api/seguridad/usuarios/{usuarioId}/sesiones
   Descripción   : Sesiones de un usuario, de la más reciente a la más antigua (máximo 50).

   Parámetros    :
     @UsuarioId      Usuario.
     @SoloAbiertas   1 = solo sesiones abiertas y vigentes (por defecto).

   Resultado     : SesionUsuarioDto
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQrySesionesUsuario]
    @UsuarioId    INT,
    @SoloAbiertas BIT = 1
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Ahora DATETIME2(0) = SYSUTCDATETIME();

    SELECT TOP (50)
        s.SesionId,
        s.FechaInicioUtc,
        s.FechaExpiraUtc,
        s.FechaCierreUtc,
        s.MotivoCierre,
        s.Ip,
        s.UserAgent,
        Abierta = CAST(CASE WHEN s.FechaCierreUtc IS NULL AND s.FechaExpiraUtc > @Ahora THEN 1 ELSE 0 END AS BIT)
    FROM Seguridad.SesionUsuario AS s
    WHERE s.UsuarioId = @UsuarioId
      AND (@SoloAbiertas = 0 OR (s.FechaCierreUtc IS NULL AND s.FechaExpiraUtc > @Ahora))
    ORDER BY s.FechaInicioUtc DESC, s.SesionId DESC;
END;
GO
