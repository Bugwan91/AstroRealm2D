@tool
class_name HullBakerResource
extends ViewBakerResource

#TODO inverse this dependency
signal parent_changed(parent: HullBakerResource)

@export var parent: HullBakerResource:
	set(value):
		parent = value
		parent_changed.emit(parent)

# TODO: Why not PackedVector2Array
# or PointsArrayResource for more flexibility of engines positions
@export var engine_slots: Array[Vector2]

@export var thrusters: PointsArrayResource
@export var weapon_slots: PointsArrayResource

@export_range(0.001, 10000.0) var mass := 1.0

func get_engines_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	for engine in engine_slots:
		points.append(engine - Vector2(0, -32))
	return points
