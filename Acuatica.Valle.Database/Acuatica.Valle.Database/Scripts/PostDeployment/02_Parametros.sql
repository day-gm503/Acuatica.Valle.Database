/*============================================================================================
  Datos iniciales · Parámetros del sistema (Catalogo.Parametro)
  Solo inserta las claves que no existen: los valores que se cambien desde Configuración se respetan.
============================================================================================*/
PRINT N'Parámetros...';

MERGE [Catalogo].[Parametro] AS t
USING (VALUES
    ('NOMBRE_ESCUELA',             N'Acuática Valle',                 'TEXTO',  N'Nombre de la escuela para recibos y reportes.'),
    ('DIAS_AVISO_VENCIMIENTO',     N'5',                              'ENTERO', N'Días antes del fin de periodo para mostrar "pagos por vencer".'),
    ('MINUTOS_TOLERANCIA_RETARDO', N'10',                             'ENTERO', N'Minutos después del inicio de la clase para marcar retardo.'),
    ('BLOQUEAR_ACCESO_CON_ADEUDO', N'0',                              'BOOL',   N'1 = el lector de huella niega la entrada con adeudo vencido. (Pendiente de confirmar con el cliente.)'),
    ('MAX_INTENTOS_LOGIN',         N'5',                              'ENTERO', N'Intentos fallidos de inicio de sesión antes de bloquear al usuario.'),
    ('MINUTOS_BLOQUEO_LOGIN',      N'15',                             'ENTERO', N'Minutos que dura el bloqueo por intentos fallidos.'),
    ('ZONA_HORARIA',               N'Central Standard Time (Mexico)', 'TEXTO',  N'Zona para convertir UTC a hora local (nombre válido para AT TIME ZONE).')
) AS s (Clave, Valor, TipoDato, Descripcion)
ON t.[Clave] = s.Clave
WHEN NOT MATCHED BY TARGET THEN
    INSERT ([Clave], [Valor], [TipoDato], [Descripcion]) VALUES (s.Clave, s.Valor, s.TipoDato, s.Descripcion);
