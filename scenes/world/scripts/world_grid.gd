class_name WorldGrid
extends Node

const FREEZE_DELTA := 0.2
const VIEWPORT_EXTRA_MARGIN := 256.0

var root: Node2D: set = _connect_root

var cell_size: int = 500:
	set(value):
		cell_size = value
		_cell_size_inv = 1.0 / value

var cells: Dictionary[Vector2, Array] = {}

var player_position: Vector2

#var freeze_rb_manager: FreezeRigidBodyManager

var is_debug := false
var debug_offset := 4
var debug_color := Color.GREEN

var _cell_size_inv: float
var _player_cell: Vector2
var _viewport: Viewport

var _viewport_rect: Rect2
var _viewport_margin: Vector2

var _freezed_items: Dictionary[int, Array] = {}
var _max_freeze_ticks: int
var _current_freeze_tick: int = 0:
	set(value):
		_current_freeze_tick = value if value < _max_freeze_ticks else 0

static func create(root: Node2D, cell_size: float) -> WorldGrid:
	var grid := WorldGrid.new()
	grid.root = root
	grid.cell_size = cell_size
	return grid

func _ready() -> void:
	process_physics_priority = -998
	_viewport = get_viewport()
	_viewport_margin = 2.0 * (cell_size + VIEWPORT_EXTRA_MARGIN) * Vector2.ONE
	_init_freezed_dictionary()

func _physics_process(_delta: float) -> void:
	_player_cell = _get_cell_position(player_position)
	_update_viewport_rect()
	if is_debug: draw_debug()
	_update_freezed()

func _update_freezed() -> void:
	for item in _freezed_items[_current_freeze_tick] as Array[GridItem]:
		item.freeze_process(FREEZE_DELTA)
	_current_freeze_tick += 1

# HACK: Not used so far, but can be better for optimisation reasons.
func _clear_cells() -> void:
	var copy := cells
	for cell in cells:
		if cells[cell].is_empty():
			copy.erase(cell)
	cells = copy

func _connect_root(node: Node2D) -> void:
	if is_instance_valid(root):
		root.child_entered_tree.disconnect(_new_item_added)
	root = node
	root.child_entered_tree.connect(_new_item_added)
	for item in root.get_children():
		_new_item_added(item)

func _new_item_added(node: Node2D) -> void:
	var grid_item := GridItem.new()
	grid_item.body = node
	grid_item.order = generate_item_process_order()
	node.add_child(grid_item)

func add_or_update(item: GridItem, force: bool = false) -> Vector2:
	_handle_freezing(item)
	var old_cell := item.cell
	var new_cell := _get_cell_position(item.global_position)
	if old_cell != new_cell or force:
		# Remove from old cell
		if cells.has(old_cell) and cells[old_cell].has(item):
			cells[old_cell].erase(item)
			if cells[old_cell].is_empty():
				cells.erase(old_cell)
		# Add to new cell
		if not cells.has(new_cell):
			cells[new_cell] = []
		cells[new_cell].append(item)
	return new_cell

func _handle_freezing(item: GridItem) -> void:
	item.freeze = not _viewport_rect.has_point(item.global_position)
	if item.freeze:
		if item not in _freezed_items[item.order]:
			_freezed_items[item.order].append(item)
	elif item in _freezed_items[item.order]:
			_freezed_items[item.order].erase(item)

func remove(item: GridItem) -> void:
	var old_cell := item.cell
	if old_cell in cells and item in cells[old_cell]:
		cells[old_cell].erase(item)
		if cells[old_cell].is_empty():
			cells.erase(old_cell)
	if item in _freezed_items[item.order]:
		_freezed_items[item.order].erase(item)

func get_nearby(position: Vector2, offset: int = 2, v: Vector2 = Vector2.ZERO) -> Array[Node2D]:
	var cell := _get_cell_position(position)
	var cell_v := _get_cell_position(v)
	var nearby_items: Array[Node2D] = []
	for x_offset in range(min(-offset, cell_v.x), max(offset, cell_v.x) + 1):
		for y_offset in range(min(-offset, cell_v.y), max(offset, cell_v.y) + 1):
			var neighbor_cell := cell + Vector2(x_offset, y_offset)
			if neighbor_cell in cells and not cells[neighbor_cell].is_empty():
				for item in cells[neighbor_cell] as Array[GridItem]:
					nearby_items.append(item.body)
	return nearby_items

func get_nearest(position: Vector2, offset: int = 1, v: Vector2 = Vector2.ZERO) -> Node2D:
	var nearest: Node2D = null
	var distance := INF
	for item in get_nearby(position, offset, v):
		var d := (item.global_position - position).length_squared()
		if d < distance:
			distance = d
			nearest = item
	return nearest

func get_items_in_cells(request_cells: Array[Vector2]) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for cell in request_cells:
		if cell in cells:
			for item in cells[cell] as Array[GridItem]:
				if is_instance_valid(item):
					result.append(item.body)
	return result

func generate_item_process_order() -> int:
	return randi_range(0, int(Engine.physics_ticks_per_second * FREEZE_DELTA - 1))

func _grid_items_to_node(items: Array[GridItem]) -> Array[Node2D]:
	var result: Array[Node2D] = []
	for item in items:
		result.append(item.body)
	return result

func _get_cell_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x * _cell_size_inv),
		floor(position.y * _cell_size_inv)
	)

func _update_viewport_rect() -> void:
	# HACK: should not depends on mainState.camera_controller
	var center := MainState.camera_controller.get_screen_center_position()
	var size := _viewport.get_visible_rect().size / MainState.camera_controller.zoom_min + _viewport_margin
	var pos := center - 0.5 * size
	_viewport_rect = Rect2(pos, size)

func _init_freezed_dictionary() -> void:
	_max_freeze_ticks = floori(Engine.physics_ticks_per_second * FREEZE_DELTA)
	for i in range(0, _max_freeze_ticks):
		_freezed_items[i] = []

func draw_debug() -> void:
	for x_offset in range(1-debug_offset, 1+debug_offset):
		for y_offset in range(1-debug_offset, 1+debug_offset):
			var neighbor_cell := _player_cell + Vector2(x_offset, y_offset)
			if neighbor_cell in cells and not cells[neighbor_cell].is_empty():
				DebugDraw2d.rect(
					neighbor_cell * cell_size + Vector2.ONE * cell_size * 0.5,
					Vector2.ONE * cell_size,
					debug_color, 2, 0.033)
	DebugDraw2d.rect(
		_viewport_rect.get_center(),
		_viewport_rect.size,
		Color.PURPLE, 2, 0.033)
