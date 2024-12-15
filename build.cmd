call "C:\OSGeo4W\bin\o4w_env.bat"

if exist build\route-editor.sqlite (
    del build\route-editor.sqlite
)
if exist build\route-editor.sqlite (
    echo Failed to delete build\route-editor.sqlite
    exit /b 1
)

sqlite3 build/route-editor.sqlite ".read  models/init_db.sql"
sqlite3 build/route-editor.sqlite ".read  models/schema.sql"
sqlite3 build/route-editor.sqlite ".read  models/route_manager.sql"

rem Back up the database
rem ogr2ogr -f GPKG temp/dump.gpkg build/route-editor.sqlite routes segments route_segments
rem Load data from Backup
rem ogr2ogr build/route-editor.sqlite -append -update -nlt PROMOTE_TO_MULTI temp/dump.gpkg routes
rem ogr2ogr build/route-editor.sqlite -append -update temp/dump.gpkg segments
rem ogr2ogr build/route-editor.sqlite -append -update temp/dump.gpkg route_segments
