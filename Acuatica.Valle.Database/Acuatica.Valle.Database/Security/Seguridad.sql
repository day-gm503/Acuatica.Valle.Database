/* Esquema Seguridad: Usuarios, roles, permisos por módulo, sesiones y bitácora. */
CREATE SCHEMA [Seguridad]
    AUTHORIZATION [dbo];
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuarios, roles, permisos por módulo, sesiones y bitácora.',
    @level0type = N'SCHEMA', @level0name = N'Seguridad';
GO
