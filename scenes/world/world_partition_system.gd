class_name WorldPartitionSystem
extends Node

@export var CELL_SIZE: int
@export var META_NAME: String
@export_range(0.01, 2.0) var DELTA: float

var grid: Dictionary[Vector2, Array]

func add_or_update(item: Node2D, shift: Vector2 = Vector2.ZERO) -> Vector2:
	var old_cell = item.get_meta(META_NAME)
	var new_cell := _get_cell_position(item.global_position + shift)
	if old_cell != new_cell:
		# Remove from old cell
		if old_cell in grid and item in grid[old_cell]:
			grid[old_cell].erase(item)
		# Add to new cell
		if new_cell not in grid:
			grid[new_cell] = []
		grid[new_cell].append(item)
		# Update metadate
		item.set_meta(META_NAME, new_cell)
	return new_cell

func remove(item: Node2D):
	var old_cell = item.get_meta(META_NAME)
	if old_cell in grid and item in grid[old_cell]:
		grid[old_cell].erase(item)

func get_nearby(position: Vector2, offset: int = 4) -> Array[Node2D]:
	var cell := _get_cell_position(position)
	var nearby_items: Array[Node2D] = []
	for x_offset in range(1-offset, 1+offset):
		for y_offset in range(1-offset, 1+offset):
			var neighbor_cell := cell + Vector2(x_offset, y_offset)
			if neighbor_cell in grid and not grid[neighbor_cell].is_empty():
				nearby_items.append_array(grid[neighbor_cell])
	return nearby_items

func _get_cell_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x / CELL_SIZE),
		floor(position.y / CELL_SIZE)
	)

func draw_debug(position: Vector2, offset: int = 4):
	var cell := _get_cell_position(position)
	var nearby_items: Array[Node2D] = []
	for x_offset in range(1-offset, 1+offset):
		for y_offset in range(1-offset, 1+offset):
			var neighbor_cell := cell + Vector2(x_offset, y_offset)
			if neighbor_cell in grid and not grid[neighbor_cell].is_empty():
				DebugDraw2d.rect(
					neighbor_cell * CELL_SIZE + Vector2.ONE * CELL_SIZE * 0.5,
					Vector2.ONE * CELL_SIZE,
					Color.GREEN, 2, 0.2)
