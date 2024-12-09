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

rem ogr2ogr -f GPKG temp/dump.gpkg build/route-editor.sqlite routes segments route_segments
ogr2ogr -append -update -nlt PROMOTE_TO_MULTI build/route-editor.sqlite temp/dump.gpkg routes
ogr2ogr -append -update build/route-editor.sqlite temp/dump.gpkg segments
ogr2ogr -append -update build/route-editor.sqlite temp/dump.gpkg route_segments
