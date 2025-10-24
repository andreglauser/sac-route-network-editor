SELECT load_extension('mod_spatialite');

-- Avoids warning about unsafe use of geometry functions
PRAGMA trusted_schema = 1;

INSERT INTO segment (
	id,
	created_at, 
	created_by, 
	updated_at, 
	updated_by,
	geom)
SELECT
	id AS id, 
	datetime('now') AS created_at, 
	datetime('now') AS created_by, 
	datetime('now') AS updated_at, 
	datetime('now') AS updated_by, 
	CastToXYZ(CastToLinestring(GEOMETRY)) AS geom
FROM import_segments;

INSERT INTO route(
	id, 
	name, 
	description, 
	created_at, 
	created_by, 
	updated_at, 
	updated_by)
SELECT
	id AS id,
	coalesce(start, '') || ' - '|| coalesce(stop, '') as name,
	segments as description,
	datetime('now') AS created_at, 
	datetime('now') AS created_by, 
	datetime('now') AS updated_at, 
	datetime('now') AS updated_by
FROM import_compositions;

INSERT INTO section(
	id, 
	route_id,
	name, 
	description, 
	created_at, 
	created_by, 
	updated_at, 
	updated_by)
SELECT
	id AS id,
	id AS route_id,
	coalesce(start, '') || ' - '|| coalesce(stop, '') as name,
	segments as description,
	datetime('now') AS created_at, 
	datetime('now') AS created_by, 
	datetime('now') AS updated_at, 
	datetime('now') AS updated_by
FROM import_compositions;

-- Split list of segment ids into individual rows
-- And insert into section_segment table
-- Geometries of sections and routes are computed on the fly during the insert
WITH RECURSIVE splitter(id, segment, rest) AS (
  SELECT
    id,
    substr(segments, 1, instr(segments, ',')-1) AS segment,
    substr(segments, instr(segments, ',')+1) AS rest
  FROM import_compositions
  UNION ALL
  SELECT
    id,
    CASE WHEN instr(rest, ',') > 0 
         THEN substr(rest, 1, instr(rest, ',')-1)
         ELSE rest END,
    CASE WHEN instr(rest, ',') > 0 
         THEN substr(rest, instr(rest, ',')+1)
         ELSE '' END
  FROM splitter
  WHERE rest != ''
)
INSERT INTO section_segment
(id, section_id, segment_id, created_at, created_by, updated_at, updated_by)
SELECT 
 	CreateUUID() as id,
	id as section_id, 
	trim(segment) AS segment_id,
	datetime('now') AS created_at, 
	datetime('now') AS created_by, 
	datetime('now') AS updated_at, 
	datetime('now') AS updated_by
FROM splitter
WHERE segment != '';