SELECT load_extension('mod_spatialite');

SELECT InitSpatialMetaData(TRUE);


CREATE TABLE base (
  -- use an autoincrementing integer as the primary key for use in gis applications
  -- some applications may require the first integer field as an unique integer
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  -- id is a uuid generated at the time of creation by the application oder user
  -- all relations from the specialist subject have to use this
  
  -- important advantage: relations and references are not broken by changes in the primary key by ogr2ogr when transfering data
  -- important advantage: different data sources can be merged without conflicts into one database

  -- not set as feault value on database level, to enforce, that it is set by the application/user
  -- the unique constraint unfortunately prevents the copy for the id during a merge operation in QGIS
  id TEXT NOT NULL UNIQUE,
  
  -- theamtic attributes
  name TEXT,
  description TEXT,
  
  -- audit attributes
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

SELECT AddGeometryColumn( 'base' , 'geom' , 2056 , 'LINESTRING' , 'XYZ', 1);
SELECT CreateSpatialIndex( 'base' , 'geom' );
