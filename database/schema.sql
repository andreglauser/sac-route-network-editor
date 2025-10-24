-- See base.sql for explination of basic attributes
SELECT load_extension('mod_spatialite');

DROP TABLE IF EXISTS route;
CREATE TABLE route (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  name TEXT,
  description TEXT,
  url TEXT,

  start_name TEXT,
  stop_name TEXT,

  -- SAC needs custom ids for the mapping with sa2020. Can be null if not part of sa2020
  -- Can be used to join with the export from the sa2020 API
  sac_id INTEGER UNIQUE,

  -- relation to skitourenguru
  sg_id INTEGER UNIQUE,
  sg_type INTEGER,
  sg_triage INTEGER,
  
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

  data_source TEXT 
    REFERENCES data_source(id) 
    ON UPDATE CASCADE 
    ON DELETE RESTRICT, 
  direction TEXT 
    REFERENCES direction(id) 
    ON UPDATE CASCADE 
    ON DELETE RESTRICT,
  symbol_placement TEXT 
    REFERENCES symbol_placement(id) 
    ON UPDATE CASCADE 
    ON DELETE RESTRICT,

  -- not a value catalog because of the ease of use
  -- m:n would not be practicle to add and query with qgis
  snowshoe BOOLEAN,
  skitour BOOLEAN,

  increased_caution BOOLEAN, 
  increased_caution_reason TEXT, 
  climbed_on_foot BOOLEAN,

  publish_sac BOOLEAN, --true/false
  publish_swisstopo BOOLEAN, --true/false
  publish_bafu BOOLEAN, --true/false
  publish_not_allowed BOOLEAN, --true/false
  publish_draft BOOLEAN, --true/false
  -- Managed by default values on update. Defined by SAC
  update_status INTEGER, -- -2,-1,1,2,3,4,5


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
  
  name TEXT,
  route_id TEXT NOT NULL,
  position INTEGER,
  description TEXT,

  -- SAC needs custom ids for the mapping with sa2020. Can be null if not part of sa2020
  -- Can be used to join with the export from the sa2020 API
  sac_id INTEGER UNIQUE,

  edit_recaluclate_segments INTEGER DEFAULT 0,
  
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
CREATE INDEX section_route_id_idx ON section(route_id);
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
