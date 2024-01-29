@tool
class_name HullBakerResource
extends ViewBakerResource

@export var cockpit_slot: Vector2
# TODO: Why not PackedVector2Array
# or PointsArrayResource for more flexibility of engines positions
@export var engine_slots: Array[Vector2]
@export var thrusters: PointsArrayResource
@export var weapon_slots: PointsArrayResource

func get_engines_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	for engine in engine_slots:
		points.append(engine - Vector2(0, -32))
	return points
