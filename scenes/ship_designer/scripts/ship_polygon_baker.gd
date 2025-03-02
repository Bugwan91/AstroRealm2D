class_name ShipPolygonBaker
extends Node

var _hull := PackedVector2Array()
var _hull_pivot: Vector2
var _hull_ext := PackedVector2Array()
var _hull_ext_pivot: Vector2

var _hull_thrusters: PointsArrayResource
var _hull_ext_thrusters: PointsArrayResource
var _main_weapons: PointsArrayResource
var _secondary_weapons: PointsArrayResource

var polygon: PackedVector2Array
var thrusters: Array[PointResource]
var main_weapons: Array[PointResource]
var secondary_weapons: Array[PointResource]

func bake() -> void:
	polygon = _rotate_polygon(merge_polygons(), 0.5 * PI)
	thrusters = _override_thrusters().rotated(0.5 * PI)
	main_weapons = _main_weapons.rotated(0.5 * PI)
	# FIXME: should take into accont the pivot point
	if is_instance_valid(_secondary_weapons):
		secondary_weapons = _secondary_weapons.rotated(0.5 * PI)

func merge_polygons() -> PackedVector2Array:
	if _hull.is_empty(): return _hull
	var poly := Geometry2D.merge_polygons(_hull, _hull_ext)[0]
	return poly

func update(type: ShipBlueprint.Type, data: ViewBakerResource) -> void:
	match type:
		ShipBlueprint.Type.HULL: _update_hull(data)
		ShipBlueprint.Type.HULL_EXT: _update_hull_ext(data)

func _update_hull(hull: HullBakerResource) -> void:
	if hull == null: return
	_hull_pivot = hull.pivot_point
	_hull = _shift_polygon(hull.polygon.data, hull.pivot_point) 
	_hull_thrusters = hull.thrusters
	_main_weapons = hull.weapon_slots

func _update_hull_ext(hull: HullBakerResource) -> void:
	if hull == null:
		_hull_ext = PackedVector2Array()
		_hull_ext_pivot = Vector2.ZERO
		_hull_ext_thrusters = null
		_secondary_weapons = null
	else:
		_hull_ext_pivot = hull.pivot_point
		_hull_ext = _shift_polygon(hull.polygon.data, hull.pivot_point)
		_hull_ext_thrusters = hull.thrusters
		_secondary_weapons = hull.weapon_slots

func _override_thrusters() -> PointsArrayResource:
	if _hull_ext_thrusters == null: return _hull_thrusters
	var overrided_thrusters := PointsArrayResource.new()
	for thruster in _hull_thrusters.points as Array[ThrusterPositionsResource]:
		var next := thruster
		for override_thruster in _hull_ext_thrusters.points:
			if thruster.is_match(override_thruster):
				next = override_thruster
				break
		overrided_thrusters.points.append(next)
	return overrided_thrusters

func _shift_polygon(_polygon: PackedVector2Array, shift: Vector2) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in _polygon:
		points.append(point + shift)
	return points

# FIXME: Need to implement and use this as currently point positions are incorrect when pivot_point is not (0,0)
#func _shift_points(points: PointsArrayResource, shift: Vector2) -> PointsArrayResource:
	#pass

func _rotate_polygon(_polygon: PackedVector2Array, rotation: float) -> PackedVector2Array:
	var points := PackedVector2Array()
	for point in _polygon:
		points.append(point.rotated(rotation))
	return points
