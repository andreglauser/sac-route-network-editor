SET OSGEO_ROOT=C:\OSGeo4W
SET OSGEO_PYTHON=%OSGEO_ROOT%\apps\Python312\python.exe

rem To enable system site packages the venv has to be created explicitly
uv venv --system-site-packages --python %OSGEO_PYTHON%

rem Adds the QGIS LTR directories to the virtual environment
echo %OSGEO_ROOT%\apps\qgis-ltr\python > .venv\qgis-ltr.pth
echo %OSGEO_ROOT%\apps\qgis-ltr\python\plugins >> .venv\qgis-ltr.pth

rem Installs dependencies in the virtual environment
uv sync --dev