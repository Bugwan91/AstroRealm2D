@tool
class_name HullBakerResource
extends Resource

@export var view: ViewBakerResource

@export var cockpit_slot: Vector2
@export var engine_slots: Array[Vector2]
@export var thrusters: PointsArrayResource

func get_engines_points() -> PackedVector2Array:
	var points := PackedVector2Array()
	for engine in engine_slots:
		points.append(engine - Vector2(0, -32))
	return points
