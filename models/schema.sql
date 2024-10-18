-- See base.sql for explination of basic attributes
SELECT load_extension('mod_spatialite');

SELECT InitSpatialMetaData(TRUE);

DROP TABLE IF EXISTS config;
CREATE TABLE config (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,

  key TEXT UNIQUE,
  value TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

INSERT INTO config (key, value, description, created_at, created_by) VALUES 
  ('version', '0.1', 'Version of the database schema', datetime('now'), 'system'),
  ('execute_triggers', 'true', 'Enable or disable triggers', datetime('now'), 'system');


DROP TABLE IF EXISTS segments;
CREATE TABLE segments (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  name TEXT,
  description TEXT,

  -- used to track gis editing action (merge & split):
  -- if old_id IS NULL then it is a new segment
  -- if id = old_id, then it is an update
  -- if old_id != id then it is an insert from a split operation or copy
  old_id TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

SELECT AddGeometryColumn( 'segments' , 'geom' , 2056 , 'LINESTRING' , 'XYZ', 1);
SELECT CreateSpatialIndex( 'segments' , 'geom' );

DROP TABLE IF EXISTS routes;
CREATE TABLE routes (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

-- initali the geometry can be NULL, geometry will be managed by trigger
SELECT AddGeometryColumn( 'routes' , 'geom' , 2056 , 'MULTILINESTRING' , 'XYZ', 0);
SELECT CreateSpatialIndex( 'routes' , 'geom' );

DROP TABLE IF EXISTS route_segments;
CREATE TABLE route_segments (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,

  route_id TEXT NOT NULL,
  segment_id TEXT NOT NULL,
  
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT,

  --each segement can only be used once in a route
  UNIQUE(route_id, segment_id),

  CONSTRAINT route_segments_route_id_fk
    FOREIGN KEY(route_id) 
    REFERENCES routes(id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE
    DEFERRABLE INITIALLY DEFERRED,

  CONSTRAINT route_segments_segment_id_fk
      FOREIGN KEY(segment_id)
      REFERENCES segments(id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
      DEFERRABLE INITIALLY DEFERRED
);

CREATE UNIQUE INDEX route_segments_idx ON route_segments(route_id, segment_id);
