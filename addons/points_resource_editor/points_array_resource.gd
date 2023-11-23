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
	points[index].rotate(rotation)
	emit_changed()
