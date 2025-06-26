# SAC Route Network Editor

Created for the [Swiss Alpine Club](https://www.sac-cas.ch) to simplify the creation and management of route geometries with [QGIS](https://qgis.org/). The business logic and aggregation of information is handled by triggers in the SpatiaLite database.

How to use the project: Download the latest [release](https://github.com/andreglauser/sac-route-network-editor/releases) and open the route-editor.qgis with QGIS. The release contains some test-data. If a start with an empty database is desired: rename `route-editor.sqlite.empty` to `route-editor.sqlite` (remove .empty suffix).

## Overview of requirements

Routes are composed based on one or multiple sections. A section is composed on one or multiple segments. Segments are building a network of unique paths. Therefore a segment can be part of multiple routes. The base of the network of segments could be data from a national mapping agency or OpenStreetMap.

This kind of m:n relation brings its own challenges when performing create, split and merge operations in a map-based application. This project automates and simplifies the creation and editing of all levels of route data:

- Automatic building of relations between segments and sections
- Automatic handling of split-operations of segments (Creation of additional links between new segment and existing section)
- Automatic handling of merge-operations of segments
- Additional attributes for route-, section- and segment-features

## Development

The Project relies heavily on triggers in a SpatiaLite database and form settings in the QGIS-Project. To set up the development project execute [setup-dev-env.cmd](setup-dev-env.cmd). This handles the creation of a virtual python environment with the OSGeo4W-Installation. If the OSGeo4W-Installation is not in the default location the `OSGEO_ROOT` variable has to be modified.

The **database** is defined with the files in [database](database) and can be built with the execution of [build.py](build.py). If new sql-files are created they have to be added in `sql_scripts` in [build.py](build.py). There the order of execution is crucial. New tables should follow the structure of [database/base.sql](database/base.sql).

The **QGIS-Project** [route-editor/route-editor.qgs](route-editor/route-editor.qgs) can be modified after the creation of the database. When adding new tables make sure to execute [helpers/form_defaults.py](helpers/form_defaults.py) to define the necessary default settings in the form.

### Add test-data

Test-data of the area around Niesen based on [swissTLM3D, Bundesamt für Landestopografie swisstopo](https://www.swisstopo.admin.ch/de/landschaftsmodell-swisstlm3d) can be added with the `load_test_data` parameter in [build.py](build.py)