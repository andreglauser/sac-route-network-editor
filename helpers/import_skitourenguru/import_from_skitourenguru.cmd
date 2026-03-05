@echo off
rem It is recommended to run the script with the `OSGeo4WShell`


rem Path to the route editor database template and the new database to be created.
rem Check out the download in the release section:
rem https://github.com/andreglauser/sac-route-network-editor/releases
SET route_editor_db_template="C:\temp\route-editor\route-editor.sqlite.empty"
SET route_editor_db="C:\temp\route-editor\route-editor_new.sqlite"

rem Paths to the source GeoJSON files containing compositions and segments
rem Latest file can be found at https://github.com/skitourenguru/Routes
SET composition_source="C:\temp\route-editor\Italy_Compositions.geojson"
SET segment_source="C:\temp\route-editor\Italy_Segments.geojson"


rem Logic to create a new route editor database and import the data

echo Creating new route editor database %route_editor_db%
copy %route_editor_db_template% %route_editor_db%

echo Importing compositions and segments from Skitourenguru
ogr2ogr -f "SQLite" -update -append %route_editor_db% %composition_source% -nln import_compositions
ogr2ogr -f "SQLite" -update -append %route_editor_db% %segment_source% -nln import_segments

echo Transforming imported data to route editor schema 
sqlite3 %route_editor_db% < %~dp0\transform.sql

echo:
echo Final steps:
echo Rename the newly created database file %route_editor_db% to route-editor.sqlite in the route editor folder to use it with the QGIS Project.
echo Control the correct SRID-Setting in the QGIS-Project for all the layers. 
echo If necessary set it to SRID 32632 (WGS 84 / UTM zone 32N) to display the data in the correct location.
echo:
echo Done. Have fun editing routes!