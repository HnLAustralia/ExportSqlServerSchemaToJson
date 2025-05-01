@echo off
set "SERVER_NAME=localhost"
set "DATABASE_NAME=sysnet"

@echo Exporting database schema...
sqlcmd -S %SERVER_NAME% -d %DATABASE_NAME% -E -i ExportSchemaJson.sql -o Complete_%DATABASE_NAME%_DatabaseSchema.json -y0 -Y0

@echo Formatting JSON output...
powershell -Command "(Get-Content Complete_%DATABASE_NAME%_DatabaseSchema.json -Raw) -replace '\r?\n\s*','' | Set-Content -Path Complete_%DATABASE_NAME%_DatabaseSchema_oneline.json; Get-Content Complete_%DATABASE_NAME%_DatabaseSchema_oneline.json -Raw | ConvertFrom-Json | ConvertTo-Json -Depth 100 | Set-Content -Path Complete_%DATABASE_NAME%_DatabaseSchema.json"

@echo Cleaning up temporary files...
del Complete_%DATABASE_NAME%_DatabaseSchema_oneline.json

@echo Done!