/*============================================================================================
  Script posterior a la implementación (Post-Deployment) · Acuatica.Valle.Database

  Se ejecuta al final de cada publicación del proyecto. Carga los datos iniciales que el
  sistema necesita para funcionar. Todos los scripts son idempotentes: se pueden ejecutar
  las veces que sea y solo insertan lo que falta.

  Orden:
    01 Catálogos  ·  02 Parámetros  ·  03 Seguridad (roles, módulos, permisos, admin)  ·  04 Calendario
============================================================================================*/
SET NOCOUNT ON;
SET XACT_ABORT ON;
GO
:r .\01_Catalogos.sql
GO
:r .\02_Parametros.sql
GO
:r .\03_Seguridad.sql
GO
:r .\04_Calendario.sql
GO
PRINT N'Datos iniciales cargados.';
GO
