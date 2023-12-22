@tool
class_name PointsArrayResource
extends Resource

@export var points: Array[PointResource]:
	set(data):
		for index in range(0, data.size()):
			if data[index] == null:
				data[index] = PointResource.new()
		points = data
		emit_changed()

func position(index: int) -> Vector2:
	return points[index].position


func rotation(index: int) -> float:
	return points[index].rotation


func move(index: int, position: Vector2):
	if points == null: return
	points[index].move(position)
	emit_changed()


func rotate(index: int, rotation: float):
	if points == null: return
	points[index].rotate_point(rotation)
	emit_changed()

func rotated(rotation: float) -> Array[PointResource]:
	var result_points: Array[PointResource] = []
	for point in points:
		result_points.append(point.rotated(rotation))
	return result_points

func merge(new_points: PointsArrayResource):
	if new_points == null or new_points.points == null: return
	points.append_array(new_points.points)

func is_empty() -> bool:
	return points.is_empty()
