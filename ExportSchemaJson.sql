SET NOCOUNT ON;

DECLARE @FullSchema NVARCHAR(MAX) = '{}';

-- Tables metadata
SET @FullSchema = JSON_MODIFY(@FullSchema, '$.Tables', (
    SELECT 
        t.TABLE_SCHEMA,
        t.TABLE_NAME,
        (SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH,
                COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
         FROM INFORMATION_SCHEMA.COLUMNS c
         WHERE c.TABLE_NAME = t.TABLE_NAME AND c.TABLE_SCHEMA = t.TABLE_SCHEMA
         FOR JSON PATH) AS Columns,
        (SELECT tc.CONSTRAINT_NAME, tc.CONSTRAINT_TYPE,
                (SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
                 WHERE kcu.CONSTRAINT_NAME = tc.CONSTRAINT_NAME
                 FOR JSON PATH) AS Columns
         FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
         WHERE tc.TABLE_NAME = t.TABLE_NAME AND tc.CONSTRAINT_TYPE IN ('PRIMARY KEY', 'UNIQUE')
         FOR JSON PATH) AS Keys,
        (SELECT fk.name AS ForeignKeyName, OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
                (SELECT c.name AS ColumnName, rc.name AS ReferencedColumn
                 FROM sys.foreign_key_columns fkc
                 JOIN sys.columns c ON fkc.parent_column_id = c.column_id AND c.object_id = fk.parent_object_id
                 JOIN sys.columns rc ON fkc.referenced_column_id = rc.column_id AND rc.object_id = fk.referenced_object_id
                 WHERE fkc.constraint_object_id = fk.object_id
                 FOR JSON PATH) AS ColumnMapping
         FROM sys.foreign_keys fk
         WHERE fk.parent_object_id = OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME)
         FOR JSON PATH) AS ForeignKeys,
        (SELECT con.name AS ConstraintName, con.definition AS ConstraintDefinition
         FROM sys.check_constraints con
         WHERE con.parent_object_id = OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME)
         FOR JSON PATH) AS CheckConstraints,
        (SELECT idx.name AS IndexName, idx.is_unique AS IsUnique, idx.is_primary_key AS IsPrimaryKey,
                (SELECT col.name FROM sys.index_columns ic 
                 JOIN sys.columns col ON ic.object_id = col.object_id AND ic.column_id = col.column_id
                 WHERE ic.object_id = idx.object_id AND ic.index_id = idx.index_id
                 ORDER BY ic.key_ordinal
                 FOR JSON PATH) AS IndexColumns
         FROM sys.indexes idx
         WHERE idx.object_id = OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME) AND idx.is_hypothetical = 0 AND idx.name IS NOT NULL
         FOR JSON PATH) AS Indexes,
        (SELECT trg.name AS TriggerName, OBJECTPROPERTY(trg.object_id, 'ExecIsUpdateTrigger') AS IsUpdate,
                OBJECTPROPERTY(trg.object_id, 'ExecIsDeleteTrigger') AS IsDelete,
                OBJECTPROPERTY(trg.object_id, 'ExecIsInsertTrigger') AS IsInsert,
                OBJECT_DEFINITION(trg.object_id) AS TriggerDefinition
         FROM sys.triggers trg
         WHERE trg.parent_id = OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME)
         FOR JSON PATH) AS Triggers
    FROM INFORMATION_SCHEMA.TABLES t
    WHERE t.TABLE_TYPE = 'BASE TABLE'
    ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME
    FOR JSON PATH
));

-- Stored Procedures
SET @FullSchema = JSON_MODIFY(@FullSchema, '$.StoredProcedures', (
    SELECT SPECIFIC_SCHEMA AS SchemaName, SPECIFIC_NAME AS ProcedureName, ROUTINE_DEFINITION AS ProcedureDefinition
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_TYPE = 'PROCEDURE'
    ORDER BY SPECIFIC_SCHEMA, SPECIFIC_NAME
    FOR JSON PATH
));

-- Views
SET @FullSchema = JSON_MODIFY(@FullSchema, '$.Views', (
    SELECT TABLE_SCHEMA AS SchemaName, TABLE_NAME AS ViewName, VIEW_DEFINITION AS ViewDefinition
    FROM INFORMATION_SCHEMA.VIEWS
    ORDER BY TABLE_SCHEMA, TABLE_NAME
    FOR JSON PATH
));

-- Functions
SET @FullSchema = JSON_MODIFY(@FullSchema, '$.Functions', (
    SELECT SPECIFIC_SCHEMA AS SchemaName, SPECIFIC_NAME AS FunctionName, ROUTINE_DEFINITION AS FunctionDefinition, DATA_TYPE AS ReturnType
    FROM INFORMATION_SCHEMA.ROUTINES
    WHERE ROUTINE_TYPE = 'FUNCTION'
    ORDER BY SPECIFIC_SCHEMA, SPECIFIC_NAME
    FOR JSON PATH
));

SELECT @FullSchema AS DatabaseSchema;
