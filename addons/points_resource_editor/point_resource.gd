@tool
class_name PointResource
extends Resource

@export var position: Vector2
@export_range(-180, 180) var rotation: float

var radian: float:
	get:
		return deg_to_rad(rotation)

func move(new_position: Vector2):
	position = new_position
	emit_changed()

func rotate_point(new_rotation: float):
	rotation = new_rotation
	emit_changed()

func rotated(new_rotation: float) -> PointResource:
	var point := PointResource.new()
	point.position = position.rotated(new_rotation)
	point.rotation = rotation + rad_to_deg(new_rotation)
	return point
