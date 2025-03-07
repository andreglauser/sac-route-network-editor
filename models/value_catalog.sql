DROP TABLE IF EXISTS data_source;
CREATE TABLE data_source (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

DROP TABLE IF EXISTS direction;
CREATE TABLE direction (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);

INSERT INTO direction 
  (id, name, description, created_at, created_by) 
VALUES 
  ('ascent', 'Abfahrt', '', datetime('now'), 'Migration'),
  ('ascent_descent', 'Aufstief & Abfahrt', '', datetime('now'), 'Migration'),
  ('descent', 'Abfahrt', '', datetime('now'), 'Migration'),
  ('traverse', 'Traverse', '', datetime('now'), 'Migration'),
  ('unknown', 'Unbekannt', '', datetime('now'), 'Migration')
;

DROP TABLE IF EXISTS symbol_placement;
CREATE TABLE symbol_placement (
  fid INTEGER PRIMARY KEY AUTOINCREMENT,
  id TEXT NOT NULL UNIQUE,
  
  name TEXT,
  description TEXT,
  
  created_at TEXT,
  created_by TEXT,
  updated_at TEXT,
  updated_by TEXT
);
INSERT INTO symbol_placement 
  (id, name, description, created_at, created_by) 
VALUES 
  ('start', 'Pfeil an Beginn', '', datetime('now'), 'Migration'),
  ('middle', 'Pfeil in Mitte', '', datetime('now'), 'Migration'),
  ('none', 'Kein Pfeil', '', datetime('now'), 'Migration')
;
