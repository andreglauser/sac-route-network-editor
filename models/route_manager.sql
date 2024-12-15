-- Handles assignment of segments to routes and vice versa
-- Modification of IDs is not allowed!
-- Refer to: https://www.sqlite.org/lang_createtrigger.html


/*
TRIGGERS OF SEGMENTS
*/
DROP TRIGGER IF EXISTS segments_insert_edit;
CREATE TRIGGER segments_insert_edit 
AFTER INSERT ON segments
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  -- Insert existing relation of segment to route if segment is created by a split operation
  INSERT INTO route_segments (
    id,
    route_id, 
    segment_id, 
    created_at, 
    created_by) 
    SELECT 
      CreateUUID(),
      rs.route_id, 
      NEW.id, 
      NEW.created_at, 
      NEW.created_by
    FROM route_segments rs
    WHERE NEW.id != NEW.old_id AND rs.segment_id = NEW.old_id;

  -- Updating route_segments triggers update of route(geom)
  UPDATE route_segments 
    SET segment_id = NEW.id
  WHERE segment_id = NEW.id;
  -- update of route(geom) is handled by route_segments trigger

  -- synchronize old_id with id, so next eidting action can be detected
  UPDATE segments SET old_id = id
    WHERE id = NEW.id;
END;

-- Only execute trigger if action is relevant for route(geom) -> OF geom
-- This avoids circular triggers when updating attributes of segments
-- Also execute if id changes to update old_id
CREATE TRIGGER segments_update_edit 
AFTER UPDATE OF id, geom ON segments
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  -- Updating route_segments triggers update of route(geom)
  UPDATE route_segments
    SET segment_id = NEW.id
  WHERE segment_id IN (OLD.id, NEW.id);
  -- update of route(geom) is handled by route_segments trigger
  UPDATE segments SET old_id = id
    WHERE id IN (OLD.id, NEW.id);
END;

/*
TRIGGERS OF ROUTE_SEGMENTS
*/
CREATE TRIGGER route_segements_insert_edit 
AFTER INSERT ON route_segments
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE routes SET geom = (
    SELECT CastToMultiLinestring(ST_LineMerge(st_union(s.geom)))
    FROM route_segments rs 
    LEFT JOIN segments s ON rs.segment_id = s.id 
    WHERE rs.route_id = routes.id
  )
  WHERE id = NEW.route_id;
END;

-- Only execute trigger if action is relevant for route(geom) -> OF route_id, segment_id
-- This avoids circular triggers when updating attributes of route_segments
CREATE TRIGGER route_segements_update_edit 
AFTER UPDATE OF route_id, segment_id ON route_segments
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE routes SET geom = (
    SELECT CastToMultiLinestring(ST_LineMerge(st_union(s.geom)))
    FROM route_segments rs 
    LEFT JOIN segments s ON rs.segment_id = s.id 
    WHERE rs.route_id = routes.id
  )
  WHERE id IN (OLD.route_id, NEW.route_id);
END;

CREATE TRIGGER route_segements_delete_edit 
AFTER DELETE ON route_segments
WHEN (SELECT value FROM config WHERE key='execute_triggers')='true'
BEGIN
  UPDATE routes SET geom = (
    SELECT CastToMultiLinestring(ST_LineMerge(st_union(s.geom)))
    FROM route_segments rs 
    LEFT JOIN segments s ON rs.segment_id = s.id 
    WHERE rs.route_id = routes.id
  )
  WHERE id = OLD.route_id;
END;


-- AVOID TRIGGERS ON ROUTE, THEY CAN LEAD TO CIRCULAR TRIGGERS! 