& "C:\OSGeo4W\bin\o4w_env.bat"
$env:GDAL_DATA = "C:\OSGeo4W\apps\gdal\share\gdal"

# Check if the file exists and try to delete it
if (Test-Path "build\route-editor.sqlite") {
    try {
        Remove-Item "build\route-editor.sqlite" -ErrorAction Stop
        Write-Host "Successfully deleted build\route-editor.sqlite"
    } catch {
        Write-Host "Failed to delete build\route-editor.sqlite"
        exit 1
    }
}

# Applies the schema to the database
& sqlite3 build/route-editor.sqlite ".read models/init_db.sql"
& sqlite3 build/route-editor.sqlite ".read models/schema.sql"
& sqlite3 build/route-editor.sqlite ".read models/route_manager.sql"

# Loads test data from the temporary dump. Uncomment the following lines to load the data
# & ogr2ogr -append -update -nlt PROMOTE_TO_MULTI build/route-editor.sqlite temp/dump.gpkg routes
# & ogr2ogr -append -update build/route-editor.sqlite temp/dump.gpkg segments
# & ogr2ogr -append -update build/route-editor.sqlite temp/dump.gpkg route_segments

Write-Host "Successfully created build\route-editor.sqlite"