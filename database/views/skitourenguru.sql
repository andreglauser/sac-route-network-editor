--sqlite

CREATE VIEW skitourenguru_segment AS
WITH filtered_segements AS (
  SELECT DISTINCT 
    section_segment.segment_id
  FROM section_segment section_segment
  JOIN section ON section_segment.section_id = section.id
  JOIN route ON section.route_id = route.id
  WHERE route.sg_id IS NOT NULL),
route_infos AS (
	SELECT 
		seg.id as segment_id,
		count(sg_id) as route_count,
		group_concat(DISTINCT r.sg_id) as route_ids
	FROM route r
	JOIN "section" sec ON sec.route_id = r.id
	JOIN section_segment ss ON ss.section_id = sec.id
	JOIN segment seg ON seg.id = ss.segment_id
	GROUP by seg.id
	ORDER BY sg_id)
SELECT
  -- row_id is required for stable display of features in QGIS
  segment.ROWID as row_id,
  segment.fid as id,
  round(st_length(geom), 2) as length,
  ri.route_ids as compositions,
  segment.geom as geom
FROM segment
LEFT JOIN route_infos ri ON ri.segment_id = segment.id
WHERE segment.id IN filtered_segements;


INSERT INTO views_geometry_columns
  (view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES 
  ('skitourenguru_segment', 'geom', 'row_id', 'segment', 'geom', 1);


CREATE VIEW skitourenguru_composition AS
WITH segement_info AS (
  SELECT 
    r.id as route_id,
    group_concat(seg.fid) as segements
  FROM section_segment ss 
  JOIN segment seg ON seg.id = ss.segment_id
  JOIN section sec ON sec.id = ss.section_id
  JOIN route r ON r.id = sec.route_id
  GROUP BY r.id)
SELECT
  -- row_id is required for stable display of features in QGIS
  r.ROWID as row_id,
  r.sg_id as id,
  si.segements as segments,
  r.start_name as start,
  r.stop_name as stop,
  NULL as adiff,
  NULL as sdd,
  NULL as wildlife,
  NULL as sri,
  r.geom as geom
FROM route r
JOIN segement_info si ON si.route_id = r.id
WHERE r.sg_id IS NOT NULL;

INSERT INTO views_geometry_columns
  (view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES 
  ('skitourenguru_composition', 'geom', 'row_id', 'route', 'geom', 1);
