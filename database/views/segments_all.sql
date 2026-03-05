-- Because a segment is part of multiple routes, it is necessary to register the geometry column of the view instead of the segment source table.
-- This is required to show the view correctly in QGIS without flickering (randomly appearing and disappearing segments) in the map
-- Because of this the spatial index on the segment table cannot be used for the view which can cause performance issues when the number of segments grows. 
-- If this becomes a problem, a "materialized view" can improve performance. But actually not implemented because it adds complexity and requires additional maintenance.
-- Another option could be to export the view on demand to a file.

CREATE VIEW segments_all AS
SELECT
  section_segment.fid as row_id,
  -- Route columns
  route.fid AS route_fid,
  route.id AS route_id,
  route.name AS route_name,
  route.description AS route_description,
  route.url AS route_url,
  route.sac_id AS route_sac_id,
  route.sg_id AS route_sg_id,
  route.sg_type AS route_sg_type,
  route.sg_triage AS route_sg_triage,
  route.created_at AS route_created_at,
  route.created_by AS route_created_by,
  route.updated_at AS route_updated_at,
  route.updated_by AS route_updated_by,
  route.geom AS route_geom,
  -- Section columns
  section.fid AS section_fid,
  section.id AS section_id,
  section.name AS section_name,
  section.route_id AS section_route_id,
  section.position AS section_position,
  section.description AS section_description,
  section.sac_id AS section_sac_id,
  section.edit_recaluclate_segments AS section_edit_recaluclate_segments,
  section.created_at AS section_created_at,
  section.created_by AS section_created_by,
  section.updated_at AS section_updated_at,
  section.updated_by AS section_updated_by,
  section.geom AS section_geom,
  -- Section_segment columns (no prefix requested)
  section_segment.fid,
  section_segment.id,
  section_segment.section_id,
  section_segment.segment_id,
  section_segment.name,
  section_segment.description,
  section_segment.created_at,
  section_segment.created_by,
  section_segment.updated_at,
  section_segment.updated_by,
  -- Segment columns
  segment.fid AS segment_fid,
  segment.id AS segment_id,
  segment.name AS segment_name,
  segment.description AS segment_description,
  segment.data_source AS segment_data_source,
  segment.direction AS segment_direction,
  segment.symbol_placement AS segment_symbol_placement,
  segment.snowshoe AS segment_snowshoe,
  segment.skitour AS segment_skitour,
  segment.increased_caution AS segment_increased_caution,
  segment.increased_caution_reason AS segment_increased_caution_reason,
  segment.climbed_on_foot AS segment_climbed_on_foot,
  segment.publish_sac AS segment_publish_sac,
  segment.publish_swisstopo AS segment_publish_swisstopo,
  segment.publish_bafu AS segment_publish_bafu,
  segment.publish_not_allowed AS segment_publish_not_allowed,
  segment.publish_draft AS segment_publish_draft,
  segment.update_status AS segment_update_status,
  segment.old_id AS segment_old_id,
  segment.created_at AS segment_created_at,
  segment.created_by AS segment_created_by,
  segment.updated_at AS segment_updated_at,
  segment.updated_by AS segment_updated_by,
  segment.geom AS segment_geom
FROM
  section_segment
JOIN section ON section_segment.section_id = section.id
JOIN route ON section.route_id = route.id
JOIN segment ON section_segment.segment_id = segment.id;

INSERT INTO views_geometry_columns
  (view_name, view_geometry, view_rowid, f_table_name, f_geometry_column, read_only)
VALUES 
  ('segments_all', 'segment_geom', 'row_id', 'segments_all', 'segment_geom', 1);