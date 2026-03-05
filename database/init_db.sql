SELECT load_extension('mod_spatialite');

SELECT InitSpatialMetaData(TRUE);

DROP TABLE IF EXISTS config;
CREATE TABLE config (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,

  "key" TEXT UNIQUE,
  value TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

INSERT INTO config ("key", value, description, created_at, created_by) VALUES 
  ('version', '0.1', 'Version of the database schema', datetime('now'), 'system'),
  ('execute_triggers', 'true', 'Enable or disable triggers', datetime('now'), 'system'),
  ('snap_vertices_count', 3, 'Min. count of vertices to collect segments when digitalizing routes', datetime('now'), 'system'),
  -- for skitourenguru data: use srid 32632 for the spatial reference system, which corresponds to WGS 84 / UTM zone 32N 
  -- for SAC CAS data: use srid 2056 for the spatial reference system, which corresponds to CH1903+ / LV95
  ('spatial_reference_system', '2056', 'SRID for the spatial reference system used during creation of the database', datetime('now'), 'system');