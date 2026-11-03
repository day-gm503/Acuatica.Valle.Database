/* =====================================================================================
   Procedimiento : [Seguridad].[AVQryListadoBitacora]
   Clave lógica  : Seguridad.ListadoBitacora   (StoredProcedure.json)
   Endpoint      : GET /api/seguridad/bitacora
   Descripción   : Consulta paginada de la bitácora, de lo más reciente a lo más antiguo.
                   Las fechas del filtro son días en hora de México; se convierten a UTC para
                   aprovechar el índice IX_Bitacora_Fecha.

   Parámetros    :
     @FechaDesde, @FechaHasta  Días (hora local, inclusivos). Opcionales.
     @UsuarioId                Solo acciones de ese usuario.
     @Accion                   Acción exacta (LOGIN, CREAR_USUARIO…).
     @Entidad                  Tabla afectada (Seguridad.Usuario…).
     @Exito                    1 éxitos, 0 fallos, NULL todo.
     @Buscar                   Texto en acción, id afectado, usuario o IP.
     @NumeroPagina, @TamanoPagina

   Resultados (en este orden):
     1) Total de registros (INT)
     2) Página -> BitacoraDto
   Historial     :
     2026-11-02  Versión inicial.
   ===================================================================================== */
CREATE PROCEDURE [Seguridad].[AVQryListadoBitacora]
    @FechaDesde   DATE          = NULL,
    @FechaHasta   DATE          = NULL,
    @UsuarioId    INT           = NULL,
    @Accion       VARCHAR(50)   = NULL,
    @Entidad      VARCHAR(60)   = NULL,
    @Exito        BIT           = NULL,
    @Buscar       NVARCHAR(100) = NULL,
    @NumeroPagina INT           = 1,
    @TamanoPagina INT           = 50
AS
BEGIN
    SET NOCOUNT ON;

    IF @NumeroPagina IS NULL OR @NumeroPagina < 1 SET @NumeroPagina = 1;
    IF @TamanoPagina IS NULL OR @TamanoPagina < 1 SET @TamanoPagina = 50;

    DECLARE @DesdeUtc DATETIME2(3) = CASE WHEN @FechaDesde IS NULL THEN NULL ELSE
        CAST((CAST(@FechaDesde AS DATETIME2(3)) AT TIME ZONE 'Central Standard Time (Mexico)') AT TIME ZONE 'UTC' AS DATETIME2(3)) END;
    DECLARE @HastaUtc DATETIME2(3) = CASE WHEN @FechaHasta IS NULL THEN NULL ELSE
        CAST((CAST(DATEADD(DAY, 1, @FechaHasta) AS DATETIME2(3)) AT TIME ZONE 'Central Standard Time (Mexico)') AT TIME ZONE 'UTC' AS DATETIME2(3)) END;

    DECLARE @Patron NVARCHAR(102) = CASE WHEN NULLIF(LTRIM(RTRIM(@Buscar)), N'') IS NULL
                                         THEN NULL ELSE N'%' + LTRIM(RTRIM(@Buscar)) + N'%' END;

    SELECT b.BitacoraId
    INTO #Filtrados
    FROM Seguridad.Bitacora AS b
    LEFT JOIN Seguridad.Usuario AS u ON u.UsuarioId = b.UsuarioId
    WHERE (@DesdeUtc  IS NULL OR b.FechaUtc >= @DesdeUtc)
      AND (@HastaUtc  IS NULL OR b.FechaUtc <  @HastaUtc)
      AND (@UsuarioId IS NULL OR b.UsuarioId = @UsuarioId)
      AND (@Accion    IS NULL OR b.Accion    = @Accion)
      AND (@Entidad   IS NULL OR b.Entidad   = @Entidad)
      AND (@Exito     IS NULL OR b.Exito     = @Exito)
      AND (@Patron    IS NULL OR b.Accion LIKE @Patron OR b.EntidadId LIKE @Patron OR b.Ip LIKE @Patron
                              OR u.NombreUsuario LIKE @Patron OR u.NombreCompleto LIKE @Patron);

    /* ---------- 1) Total ---------- */
    SELECT COUNT(*) FROM #Filtrados;

    /* ---------- 2) Página ---------- */
    SELECT
        b.BitacoraId,
        b.FechaUtc,
        b.UsuarioId,
        u.NombreUsuario,
        UsuarioNombreCompleto = u.NombreCompleto,
        b.Accion,
        b.Entidad,
        b.EntidadId,
        b.ValoresAnteriores,
        b.ValoresNuevos,
        b.Exito,
        b.Ip
    FROM #Filtrados AS f
    INNER JOIN Seguridad.Bitacora AS b ON b.BitacoraId = f.BitacoraId
    LEFT JOIN Seguridad.Usuario   AS u ON u.UsuarioId  = b.UsuarioId
    ORDER BY b.FechaUtc DESC, b.BitacoraId DESC
    OFFSET (@NumeroPagina - 1) * @TamanoPagina ROWS
    FETCH NEXT @TamanoPagina ROWS ONLY;
END;
GO
