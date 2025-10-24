-- Handles assignment of segment to section and vice versa
-- Modification of IDs is not allowed!
-- Refer to: https://www.sqlite.org/lang_createtrigger.html


/*
TRIGGERS OF route to enable the possibility of 2 level route-creation
*/

CREATE TRIGGER route_insert_edit
AFTER INSERT ON route
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  -- Because existing editing help is triggered by section insertion
  -- a route can completely created if the route has exactly one section
  INSERT INTO section(
    id,
    route_id,
    geom,
    created_at,
    created_by)
  VALUES (
    CreateUUID(),
    NEW.id,
    NEW.geom,
    NEW.created_at, 
    NEW.created_by
  );
END;

/*
TRIGGERS OF segment
*/
DROP TRIGGER IF EXISTS segment_insert_edit;
CREATE TRIGGER segment_insert_edit 
AFTER INSERT ON segment
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  -- Insert existing relation of segment to section if segment is created by a split operation
  INSERT INTO section_segment (
    id,
    section_id, 
    segment_id,
    created_at, 
    created_by) 
    SELECT 
      CreateUUID(),
      rs.section_id, 
      NEW.id, 
      NEW.created_at, 
      NEW.created_by
    FROM section_segment rs
    WHERE NEW.id != NEW.old_id AND rs.segment_id = NEW.old_id;

  -- Updating section_segment triggers update of section(geom)
  UPDATE section_segment 
    SET segment_id = NEW.id
  WHERE segment_id = NEW.id;
  -- update of section(geom) is handled by section_segment trigger

  -- synchronize old_id with id, so next eidting action can be detected
  UPDATE segment SET old_id = id
    WHERE id = NEW.id;
END;

-- Only execute trigger if action is relevant for section(geom) -> OF geom
-- This avoids circular triggers when updating attributes of segment
-- Also execute if id changes to update old_id
CREATE TRIGGER segment_update_edit 
AFTER UPDATE OF id, geom ON segment
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  -- Updating section_segment triggers update of section(geom)
  UPDATE section_segment
    SET segment_id = NEW.id
  WHERE segment_id IN (OLD.id, NEW.id);
  -- update of section(geom) is handled by section_segment trigger
  UPDATE segment SET old_id = id
    WHERE id IN (OLD.id, NEW.id);
END;

/*
TRIGGERS OF section_segment to maintain section geometries
*/
CREATE TRIGGER section_segements_insert_edit 
AFTER INSERT ON section_segment
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE section SET geom = (
    SELECT CastToMultiLinestring(ST_LineMerge(st_union(s.geom)))
    FROM section_segment rs 
    LEFT JOIN segment s ON rs.segment_id = s.id 
    WHERE rs.section_id = section.id
  )
  WHERE id = NEW.section_id;
END;

-- Only execute trigger if action is relevant for section(geom) -> OF section_id, segment_id
-- This avoids circular triggers when updating attributes of section_segment
CREATE TRIGGER section_segements_update_edit 
AFTER UPDATE OF section_id, segment_id ON section_segment
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE section SET geom = (
    SELECT CastToMultiLinestring(ST_LineMerge(st_union(s.geom)))
    FROM section_segment rs 
    LEFT JOIN segment s ON rs.segment_id = s.id 
    WHERE rs.section_id = section.id
  )
  WHERE id IN (OLD.section_id, NEW.section_id);
END;

CREATE TRIGGER section_segements_delete_edit 
AFTER DELETE ON section_segment
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE section SET geom = (
    SELECT CastToMultiLinestring(ST_LineMerge(st_union(s.geom)))
    FROM section_segment rs 
    LEFT JOIN segment s ON rs.segment_id = s.id 
    WHERE rs.section_id = section.id
  )
  WHERE id = OLD.section_id;
END;


/*
TRIGGERS OF section to maintain route geometries
*/
-- Be carefull with triggers on section and route, they can lead to circular triggers!
CREATE TRIGGER section_insert_edit
AFTER INSERT ON section
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE route SET geom = (
    SELECT CastToMultiLinestring(st_union(section.geom))
	  FROM section
	  WHERE section.route_id = route.id)
  WHERE id = NEW.route_id;
END;

CREATE TRIGGER section_update_edit
AFTER UPDATE OF route_id, geom ON section
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE route SET geom = (
    SELECT CastToMultiLinestring(st_union(section.geom))
	  FROM section
	  WHERE section.route_id = route.id)
  WHERE id IN (NEW.route_id, OLD.route_id);
END;

CREATE TRIGGER section_delete_edit
AFTER DELETE ON section
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE route SET geom = (
    SELECT CastToMultiLinestring(st_union(section.geom))
	  FROM section
	  WHERE section.route_id = route.id)
  WHERE id IN (OLD.route_id);
END;

CREATE TRIGGER section_insert_segment_collector
AFTER INSERT ON section
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  INSERT INTO section_segment (
    id,
    section_id, 
    segment_id, 
    created_at, 
    created_by) 
  SELECT
    CreateUUID() as id,
    NEW.id as section_id,
    seg.id as segment_id,
    NEW.created_at, 
    NEW.created_by
  FROM segment seg 
  WHERE st_intersects(NEW.geom, seg.geom) AND 
    max(
      -- instersection results in a linestring collect the number of vertices
      coalesce(ST_NumPoints(st_intersection(NEW.geom, seg.geom)), 0),
      -- instersection results in a multipoint collect the number of single points
      coalesce(ST_NumGeometries(st_intersection(NEW.geom, seg.geom)), 0)
	  ) >= (SELECT CAST("value" as INTEGER) FROM config WHERE "key"='snap_vertices_count');
END;

CREATE TRIGGER section_update_segment_collector
AFTER UPDATE OF edit_recaluclate_segments ON section
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true' AND NEW.edit_recaluclate_segments = 1
BEGIN
  DELETE FROM section_segment WHERE section_id IN (OLD.id, NEW.id);
  INSERT INTO section_segment (
    id,
    section_id, 
    segment_id, 
    created_at, 
    created_by) 
  SELECT
    CreateUUID() as id,
    NEW.id as section_id,
    seg.id as segment_id,
    NEW.created_at, 
    NEW.created_by
  FROM segment seg 
  WHERE st_intersects(NEW.geom, seg.geom) AND 
    max(
      -- instersection results in a linestring collect the number of vertices
      coalesce(ST_NumPoints(st_intersection(NEW.geom, seg.geom)), 0),
      -- instersection results in a multipoint collect the number of single points
      coalesce(ST_NumGeometries(st_intersection(NEW.geom, seg.geom)), 0)
	  ) >= (SELECT CAST("value" as INTEGER) FROM config WHERE "key"='snap_vertices_count');
  
  UPDATE section SET edit_recaluclate_segments = 0 WHERE id IN (OLD.id, NEW.id);
END;