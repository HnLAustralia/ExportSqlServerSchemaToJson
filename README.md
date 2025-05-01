# Database Schema Export Tool

## Overview
This tool exports a comprehensive SQL Server database schema to a formatted JSON file. It captures detailed information about tables, columns, constraints, foreign keys, indexes, and triggers, making it ideal for documentation and schema analysis purposes.

## Prerequisites
- SQL Server instance with appropriate access permissions
- SQL Server Command Line Tools (sqlcmd)
- PowerShell
- Access to the target database with Windows Authentication

## Files
The tool consists of two main files:
1. `ExportSchemaJson.cmd` - Command script that executes the export process
2. `ExportSchemaJson.sql` - SQL script that generates the JSON schema

## Configuration
Edit the variables at the top of `ExportSchemaJson.cmd`:
```batch
set "SERVER_NAME=localhost"    # SQL Server instance name
set "DATABASE_NAME=sysnet"     # Target database name
```

## Output Schema
The tool generates a JSON file named `Complete_<DATABASE_NAME>_DatabaseSchema.json` containing:

### Tables
- Table schema and name
- Columns
  - Column name
  - Data type
  - Nullability
  - Maximum length
  - Identity property
- Keys
  - Primary keys
  - Unique constraints
- Foreign Keys
  - Constraint name
  - Referenced table
  - Column mappings
- Check Constraints
  - Constraint name
  - Definition
- Indexes
  - Index name
  - Uniqueness
  - Primary key status
  - Indexed columns
- Triggers
  - Trigger name
  - Type (Insert/Update/Delete)
  - Definition

### Stored Procedures
- Schema name
- Procedure name
- Complete procedure definition

### Views
- Schema name
- View name
- Complete view definition

### Functions
- Schema name
- Function name
- Return type
- Complete function definition

## Usage
1. Open a command prompt with SQL Server access
2. Navigate to the script directory
3. Run `ExportSchemaJson.cmd`

The script will:
1. Export the raw schema to JSON
2. Format the JSON for readability
3. Clean up temporary files
4. Generate the final output file: `Complete_<DATABASE_NAME>_DatabaseSchema.json`

## Output Example
```json
{
  "Tables": [
    {
      "TABLE_SCHEMA": "dbo",
      "TABLE_NAME": "Users",
      "Columns": [
        {
          "COLUMN_NAME": "Id",
          "DATA_TYPE": "int",
          "IS_NULLABLE": "NO",
          "IS_IDENTITY": 1
        }
      ],
      "Keys": [
        {
          "CONSTRAINT_NAME": "PK_Users",
          "CONSTRAINT_TYPE": "PRIMARY KEY"
        }
      ]
    }
  ]
}
```

## Error Handling
- The script will display error messages if:
  - SQL Server is not accessible
  - Database does not exist
  - User lacks necessary permissions
  - JSON formatting fails

## Best Practices
1. Run during low-traffic periods for large databases
2. Verify database access before running
3. Store output files in version control for tracking schema changes
4. Review the JSON output to ensure all required schema elements are captured

## Troubleshooting
1. **Connection Issues**
   - Verify SERVER_NAME is correct
   - Ensure Windows Authentication is working
   - Check SQL Server is running

2. **Permission Issues**
   - Verify user has VIEW DEFINITION permissions
   - Check database access rights

3. **Output Issues**
   - Ensure sufficient disk space
   - Check write permissions in the output directory
