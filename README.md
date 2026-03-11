# SAC Route Network Editor

Created for the [Swiss Alpine Club](https://www.sac-cas.ch) to simplify the creation and management of route geometries with [QGIS](https://qgis.org/). The business logic and aggregation of information are handled by triggers in the SpatiaLite database.

How to use the project: Download the latest [release](https://github.com/andreglauser/sac-route-network-editor/releases) and open `route-editor.qgs` with QGIS. The release contains some test data. If you want to start with an empty database, rename `route-editor.sqlite.empty` to `route-editor.sqlite` (remove the `.empty` suffix).

## Overview of requirements

Routes are composed of one or multiple sections. A section is composed of one or multiple segments. Segments form a network of unique paths. Therefore, a segment can be part of multiple routes. The base of the network of segments could be data from a national mapping agency or OpenStreetMap.

This kind of m:n relation brings its own challenges when performing create, split, and merge operations in a map-based application. This project automates and simplifies the creation and editing of all levels of route data:

- Automatic building of relations between segments and sections
- Automatic handling of segment split operations (creating additional links between new segments and existing sections)
- Automatic handling of segment merge operations
- Additional attributes for route, section, and segment features

## Development

The project relies heavily on triggers in a SpatiaLite database and form settings in the QGIS project. To set up the development environment, execute [setup-dev-env.cmd](setup-dev-env.cmd). This handles the creation of a virtual Python environment with the OSGeo4W installation. If the OSGeo4W installation is not in the default location, the `OSGEO_ROOT` variable has to be modified.

The **database** is defined by the files in [database](database) and can be built by executing [build.py](build.py). If new SQL files are created, they have to be added to `sql_scripts` in [build.py](build.py). The order of execution there is crucial. New tables should follow the structure of [database/base.sql](database/base.sql).

The **QGIS project** [route-editor/route-editor.qgs](route-editor/route-editor.qgs) can be modified after the creation of the database. When adding new tables, make sure to execute [helpers/form_defaults.py](helpers/form_defaults.py) to define the necessary default settings in the form.

## Create a Build / Project Template

To create a release, run the [build.py](build.py) script with `load_test_data: bool = False`. This creates a new database in the [route-editor](./route-editor) directory. By default, the spatial reference of the geometries is EPSG:2056 (Swiss CH1903+ / LV95). If another spatial reference has to be used, change the parameter `spatial_reference_system` in [init_db.sql](database/init_db.sql). In this case, you must also change the spatial reference of the layers in [route-editor.qgs](route-editor/route-editor.qgs).

### Add test data

Test data for the area around Niesen based on [swissTLM3D, Bundesamt für Landestopografie swisstopo](https://www.swisstopo.admin.ch/de/landschaftsmodell-swisstlm3d) can be added using the `load_test_data` parameter in [build.py](build.py).

### Compatibility with skitourenguru.ch

Routes published at [https://github.com/skitourenguru/Routes](https://github.com/skitourenguru/Routes) can be imported into an empty database of a route-editor project with [import_from_skitourenguru.cmd](./helpers/import_skitourenguru/import_from_skitourenguru.cmd). Parameters in `import_from_skitourenguru.cmd` need to be adapted. See inline documentation for more information. It is recommended to run the script using the `OSGeo4WShell` contained in every QGIS installation.

**Handling spatial reference:** When building the database for skitourenguru data, modify the definition of the spatial reference in [database/init_db.sql](./database/init_db.sql). This EPSG-ID will be used to create the geometry columns in the defined spatial reference. Changing the spatial reference later is error-prone.

#### Plans for in the near future:

- [ ] Change the collection of related segments of a section from vertices-counts to minimal shared segment length for better more reliable assignment of related segments to section.
- [ ] Modify the script for building the project template that takes an EPSG code as a parameter for creating the database and changing the spatial reference of the layers in the QGIS project.
