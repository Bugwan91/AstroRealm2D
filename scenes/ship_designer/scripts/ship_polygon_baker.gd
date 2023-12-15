class_name ShipPolygonBaker
extends Node

var _hull := PackedVector2Array()
var _hull_ext := PackedVector2Array()
var _cockpit := PackedVector2Array()
var _engine := PackedVector2Array()
var _cockpit_position: Vector2
var _engine_positions: Array[Vector2]

var _thrusters: PointsArrayResource
var _engines: PackedVector2Array

var polygon: PackedVector2Array
var thrusters: Array[PointResource]
var engines: PackedVector2Array

func bake():
	polygon = _rotate_polygon(merge_polygons(), 0.5 * PI)
	thrusters = _thrusters.rotated(0.5 * PI)
	engines = _rotate_polygon(_engines, 0.5 * PI)

func merge_polygons() -> PackedVector2Array:
	if _hull.is_empty(): return _hull
	var poly = Geometry2D.merge_polygons(_hull, _hull_ext)[0]
	poly = Geometry2D.merge_polygons(poly, _shift_polygon(_cockpit, _cockpit_position))[0]
	for engine_position in _engine_positions:
		poly = Geometry2D.merge_polygons(poly, _shift_polygon(_engine, engine_position))[0]
	return poly

func update(type: ShipBlueprint.Type, value: ViewBakerResource):
	var poly = value.polygon.data if value != null else PackedVector2Array()
	match type:
		ShipBlueprint.Type.HULL: _update_hull(value)
		ShipBlueprint.Type.HULL_EXT: _hull_ext = poly
		ShipBlueprint.Type.COCKPIT: _cockpit = poly
		ShipBlueprint.Type.ENGINE: _engine = poly

func _update_hull(hull: HullBakerResource):
	if hull == null: return
	_hull = hull.polygon.data
	_cockpit_position = hull.cockpit_slot
	_engine_positions = hull.engine_slots
	_thrusters = hull.thrusters
	_engines = hull.get_engines_points()

func _shift_polygon(polygon: PackedVector2Array, shift: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in polygon:
		points.append(point + shift)
	return points

func _rotate_polygon(polygon: PackedVector2Array, rotation: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in polygon:
		points.append(point.rotated(rotation))
	return points
