class_name WorldPartitionSystem
extends Node

@export var CELL_SIZE: int = 500
@export_range(0.01, 2.0) var DELTA: float
@export var META_NAME: String = "grid_position"

@export_category("Debug")
@export var debug := false
@export var debug_offset := 4
@export var debug_color := Color.GREEN

var local: Dictionary[Vector2, Array]
var player_cell: Vector2

var _delta_update := 0.0
var _should_update := false

func _physics_process(delta: float) -> void:
	_delta_update += delta
	_should_update = _delta_update > DELTA
	if _should_update:
		_delta_update = 0.0
	if debug: draw_debug()

func set_player_position(position: Vector2):
	player_cell = _get_cell_position(position)

func add_or_update(item: Node2D, force: bool = false):
	if _should_update or force:
		var old_cell = item.get_meta(META_NAME)
		var new_cell := _get_cell_position(item.global_position)
		if old_cell != new_cell:
			# Remove from old cell
			if old_cell in local and item in local[old_cell]:
				local[old_cell].erase(item)
			# Add to new cell
			if new_cell not in local:
				local[new_cell] = []
			local[new_cell].append(item)
			# Update metadate
			item.set_meta(META_NAME, new_cell)

func remove(item: Node2D):
	var old_cell = item.get_meta(META_NAME)
	if old_cell in local and item in local[old_cell]:
		local[old_cell].erase(item)

func get_nearby(position: Vector2, offset: int = 4) -> Array[Node2D]:
	var cell := _get_cell_position(position)
	var nearby_items: Array[Node2D] = []
	for x_offset in range(1-offset, 1+offset):
		for y_offset in range(1-offset, 1+offset):
			var neighbor_cell := cell + Vector2(x_offset, y_offset)
			if neighbor_cell in local and not local[neighbor_cell].is_empty():
				nearby_items.append_array(local[neighbor_cell])
	return nearby_items

func _get_cell_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x / CELL_SIZE),
		floor(position.y / CELL_SIZE)
	)

func draw_debug():
	var nearby_items: Array[Node2D] = []
	for x_offset in range(1-debug_offset, 1+debug_offset):
		for y_offset in range(1-debug_offset, 1+debug_offset):
			var neighbor_cell := player_cell + Vector2(x_offset, y_offset)
			if neighbor_cell in local and not local[neighbor_cell].is_empty():
				DebugDraw2d.rect(
					neighbor_cell * CELL_SIZE + Vector2.ONE * CELL_SIZE * 0.5,
					Vector2.ONE * CELL_SIZE,
					debug_color, 2)
