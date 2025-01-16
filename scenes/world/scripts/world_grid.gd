class_name WorldGrid
extends Node

@export var cell_size: int = 500:
	set(value):
		cell_size = value
		_cell_size_inv = 1.0 / value
@export_range(0.01, 2.0) var update_delta: float = 0.05
@export var meta_name: String = "grid_position"

@export_category("Debug")
@export var debug := false
@export var debug_offset := 4
@export var debug_color := Color.GREEN

var grid: Dictionary[Vector2, Array]
var player_position: Vector2

var _cell_size_inv: float
var _collected_delta := 0.0
var _should_update := false
var _player_cell: Vector2

func _ready() -> void:
	MainState.world_grid = self

func _physics_process(delta: float) -> void:
	_collected_delta += delta
	_should_update = _collected_delta > update_delta
	if _should_update:
		_player_cell = _get_cell_position(player_position)
		_collected_delta = 0.0
		if debug: draw_debug()

func add_or_update(item: Node2D, force: bool = false):
	if _should_update or force:
		var old_cell = item.get_meta(meta_name)
		var new_cell := _get_cell_position(item.global_position)
		if old_cell != new_cell:
			# Remove from old cell
			if old_cell in grid and item in grid[old_cell]:
				grid[old_cell].erase(item)
			# Add to new cell
			if new_cell not in grid:
				grid[new_cell] = []
			grid[new_cell].append(item)
			# Update metadate
			item.set_meta(meta_name, new_cell)

func remove(item: Node2D):
	var old_cell = item.get_meta(meta_name)
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
		floor(position.x * _cell_size_inv),
		floor(position.y * _cell_size_inv)
	)

func draw_debug():
	var nearby_items: Array[Node2D] = []
	for x_offset in range(1-debug_offset, 1+debug_offset):
		for y_offset in range(1-debug_offset, 1+debug_offset):
			var neighbor_cell := _player_cell + Vector2(x_offset, y_offset)
			if neighbor_cell in grid and not grid[neighbor_cell].is_empty():
				DebugDraw2d.rect(
					neighbor_cell * cell_size + Vector2.ONE * cell_size * 0.5,
					Vector2.ONE * cell_size,
					debug_color, 2, update_delta + 0.01)
