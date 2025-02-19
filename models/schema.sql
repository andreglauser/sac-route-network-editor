-- See base.sql for explination of basic attributes
SELECT load_extension('mod_spatialite');

DROP TABLE IF EXISTS route;
CREATE TABLE route (
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
SELECT AddGeometryColumn( 'route' , 'geom' , 2056 , 'MULTILINESTRING' , 'XYZ', 0);
SELECT CreateSpatialIndex( 'route' , 'geom' );

DROP TABLE IF EXISTS segment;
CREATE TABLE segment (
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

SELECT AddGeometryColumn( 'segment' , 'geom' , 2056 , 'LINESTRING' , 'XYZ', 1);
SELECT CreateSpatialIndex( 'segment' , 'geom' );

DROP TABLE IF EXISTS section;
CREATE TABLE section (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  route_id TEXT NOT NULL,
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT,

  CONSTRAINT section_route_id_fk
    FOREIGN KEY(route_id) 
    REFERENCES route(id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE
    DEFERRABLE INITIALLY DEFERRED
);

-- initali the geometry can be NULL, geometry will be managed by trigger
SELECT AddGeometryColumn( 'section' , 'geom' , 2056 , 'MULTILINESTRING' , 'XYZ', 0);
SELECT CreateSpatialIndex( 'section' , 'geom' );

DROP TABLE IF EXISTS section_segment;
CREATE TABLE section_segment (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,

  section_id TEXT NOT NULL,
  segment_id TEXT NOT NULL,
  
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT,

  --each segement can only be used once in a section
  UNIQUE(section_id, segment_id),

  CONSTRAINT section_segment_section_id_fk
    FOREIGN KEY(section_id) 
    REFERENCES section(id)
    ON UPDATE CASCADE 
    ON DELETE CASCADE
    DEFERRABLE INITIALLY DEFERRED,

  CONSTRAINT section_segment_segment_id_fk
      FOREIGN KEY(segment_id)
      REFERENCES segment(id)
      ON UPDATE CASCADE
      ON DELETE RESTRICT
      DEFERRABLE INITIALLY DEFERRED
);

CREATE UNIQUE INDEX section_segment_idx ON section_segment(section_id, segment_id);
