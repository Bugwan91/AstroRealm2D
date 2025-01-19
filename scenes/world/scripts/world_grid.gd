class_name WorldGrid
extends Node

const VIEWPORT_EXTRA_MARGIN := 100.0

@export var cell_size: int = 500:
	set(value):
		cell_size = value
		_cell_size_inv = 1.0 / value

@export_category("Debug")
@export var debug := false
@export var debug_offset := 4
@export var debug_color := Color.GREEN

var grid: Dictionary[Vector2, Array]
var player_position: Vector2

var _cell_size_inv: float
var _player_cell: Vector2
var _camera: Camera2D
var _viewport: Viewport

var _viewport_rect: Rect2
var _viewport_margin: Vector2

func _ready() -> void:
	process_physics_priority = -99
	MainState.world_grid = self
	_viewport = get_viewport()
	_camera = _viewport.get_camera_2d()
	_viewport_margin = 2.0 * (cell_size + VIEWPORT_EXTRA_MARGIN) * Vector2.ONE

func _physics_process(delta: float) -> void:
	_player_cell = _get_cell_position(player_position)
	_update_viewport_rect()
	if debug: draw_debug()

func add_or_update(item: GridItem, force: bool = false) -> Vector2:
	var old_cell = item.cell
	var new_cell := _get_cell_position(item.global_position)
	item.freeze_body(not _viewport_rect.has_point(item.global_position))
	if old_cell != new_cell or force:
		# Remove from old cell
		if grid.has(old_cell) and grid[old_cell].has(item):
			grid[old_cell].erase(item)
		# Add to new cell
		if not grid.has(new_cell):
			grid[new_cell] = []
		grid[new_cell].append(item)
	return new_cell

func remove(item: GridItem):
	var old_cell = item.cell
	if old_cell in grid and item in grid[old_cell]:
		grid[old_cell].erase(item)

func get_nearby(position: Vector2, offset: int = 4) -> Array[GridItem]:
	var cell := _get_cell_position(position)
	var nearby_items: Array[GridItem] = []
	for x_offset in range(1-offset, 1+offset):
		for y_offset in range(1-offset, 1+offset):
			var neighbor_cell := cell + Vector2(x_offset, y_offset)
			if neighbor_cell in grid and not grid[neighbor_cell].is_empty():
				nearby_items.append_array(grid[neighbor_cell])
	return nearby_items

func get_nearest(position: Vector2, offset: int = 2) -> GridItem:
	var nearest: GridItem = null
	var distance := INF
	for item in get_nearby(position, offset):
		var d := (item.global_position - position).length_squared()
		if d < distance:
			distance = d
			nearest = item
	return nearest

func _get_cell_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x * _cell_size_inv),
		floor(position.y * _cell_size_inv)
	)

func _update_viewport_rect():
	var center := _camera.get_screen_center_position()
	var size := _viewport.get_visible_rect().size / _camera.zoom + _viewport_margin
	var pos := center - 0.5 * size
	_viewport_rect = Rect2(pos, size)

func draw_debug():
	var nearby_items: Array[Node2D] = []
	for x_offset in range(1-debug_offset, 1+debug_offset):
		for y_offset in range(1-debug_offset, 1+debug_offset):
			var neighbor_cell := _player_cell + Vector2(x_offset, y_offset)
			if neighbor_cell in grid and not grid[neighbor_cell].is_empty():
				DebugDraw2d.rect(
					neighbor_cell * cell_size + Vector2.ONE * cell_size * 0.5,
					Vector2.ONE * cell_size,
					debug_color, 2, 0.033)
	DebugDraw2d.rect(
		_viewport_rect.get_center(),
		_viewport_rect.size,
		Color.PURPLE, 2, 0.033)
