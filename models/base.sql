SELECT load_extension('mod_spatialite');

SELECT InitSpatialMetaData(TRUE);


CREATE TABLE base (
  -- use an autoincrementing integer as the primary key for use in gis applications
  -- some applications may require the first integer field as an unique integer
  fid INTEGER PRIMARY KEY AUTOINCREMENT,

  -- `id` is a uuid generated at the time of creation by the application or the user
  -- All relations from the  business domain have to use this
  -- Advantage 1: Different data sources can be merged without conflicts into one database
  -- Advantage 2: Relations and references are not broken by changes in the primary key by ogr2ogr when transfering data
  -- Should not be set as deault value on database level. So it can be enforced, that id is set by the application/user
  -- The unique constraint unfortunately prevents the copy for the id during a merge operation in QGIS
  id TEXT NOT NULL UNIQUE,
  
  -- thematic attributes
  name TEXT,
  description TEXT,
  
  -- audit attributes fro editor tracking. Could be set to NOT NULL to endforce tracking
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

SELECT AddGeometryColumn( 'base' , 'geom' , 2056 , 'LINESTRING' , 'XYZ', 1);
SELECT CreateSpatialIndex( 'base' , 'geom' );
