@tool
class_name Vector2ArrayResource
extends Resource

@export var data: PackedVector2Array

var active_index: int = -1

var active_vertex: Vector2:
	get:
		return data[active_index]


func init_polygon():
	if data.is_empty():
		data = PackedVector2Array([Vector2(32.0, 0.0), Vector2(-32.0, 32.0), Vector2(-32.0, -32.0)])


func add(index: int, vertex: Vector2):
	data.insert(index, vertex)
	active_index = index
	emit_changed()


func remove(index: int):
	data.remove_at(index)
	active_index = -1
	emit_changed()


func update(index: int, vertex: Vector2):
	data.set(index, vertex)
	emit_changed()


func rotate(rotation: float):
	var points: Array[Vector2] = []
	for point in data:
		points.append(point.rotated(rotation))
	data = PackedVector2Array(points)
	emit_changed()
