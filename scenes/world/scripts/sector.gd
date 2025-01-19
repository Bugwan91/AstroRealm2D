class_name Sector
extends Node

const UNLOADING_DELTA := 0.5

enum Status {NONE, UNLOADING, ACTIVE, DELETING}

var grid_cells: Array[Vector2] = []
var position: Vector2
var status := Sector.Status.NONE:
	set(value):
		_previous_status = status
		status = value
var _previous_status := Sector.Status.NONE
var content_manager: SectorContentManager
var offset: Vector2

var _world: WorldGrid
var _sector_size: float
var _loaded := false

var _should_load := true
var _should_freeze := false
var _should_unfreeze := false
var _handled_items: Array[Node2D] = []

func init(sector_position: Vector2, offset: Vector2, content: SectorContentManager):
	position = sector_position
	offset = offset
	content_manager = content
	_world = MainState.world_grid
	_sector_size = MainState.sector_grid.sector_size
	grid_cells = _calculate_sector_cells()

func update_status(new_status: Status, new_offset: Vector2):
	offset = new_offset
	if status == new_status: return
	status = new_status

func need_to_load() -> bool:
	return (status == Status.ACTIVE and _previous_status == Status.UNLOADING)\
		or status == Status.UNLOADING

func update():
	if status == Status.DELETING:
		unload_content()
	elif status == Status.ACTIVE\
	and (_previous_status == Status.NONE or _previous_status == Status.UNLOADING):
		load_content()
	elif status == Status.UNLOADING:
		if _previous_status == Status.ACTIVE:
			unload_content()
		else:
			replace_content()
	_previous_status = status

func unload():
	content_manager.unload_content(_get_items())
	queue_free()

func load_content():
	if is_instance_valid(content_manager):
		content_manager.load_content(position)
		_loaded = true

func replace_content():
	var items := _get_items()
	if items.is_empty(): return
	content_manager.replace_content(items, _get_opposite_sector())

func _get_opposite_sector() -> Vector2:
	return -(2.0 * offset - offset.clamp(-Vector2.ONE, Vector2.ONE))

func unload_content():
	content_manager.unload_content(_get_items())

func _get_items() -> Array[GridItem]:
	var items: Array[GridItem] = []
	for cell in grid_cells:
		if cell in _world.grid:
			items.append_array(_world.grid[cell])
	return items

func draw_debug(duration: float):
	DebugDraw2d.rect(
		position * _sector_size + Vector2.ONE * _sector_size * 0.5,
		Vector2.ONE * _sector_size - Vector2(4,4),
		get_debug_color(), 2, duration + 0.01)

func get_debug_color() -> Color:
	match status:
		Sector.Status.DELETING: return Color.RED
		Sector.Status.UNLOADING: return Color.HOT_PINK
		Sector.Status.ACTIVE: return Color.GREEN_YELLOW
		_: return Color.PURPLE

func _calculate_sector_cells() -> Array[Vector2]:
	var cells_range := MainState.sector_grid.cells_per_sector
	var origin := position * cells_range
	var cells: Array[Vector2] = []
	for x in range(0, cells_range):
		for y in range(0, cells_range):
			cells.append(Vector2(
				origin.x + x,
				origin.y + y
			))
	return cells
