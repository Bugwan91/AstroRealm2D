class_name Sector
extends Node

const UNLOADING_DELTA := 0.5

enum Status {UNLOADING, FREEZED, ACTIVE}

var grid_cells: Array[Vector2] = []
var position: Vector2
var status: Sector.Status = 0
var _old_status: Sector.Status = 0
var content_manager: SectorContentManager
var oposite_sector: Sector = null

var _world: WorldGrid
var _sector_size: float
var _loaded := false

func init(sector_position: Vector2, content: SectorContentManager):
	position = sector_position
	content_manager = content
	_world = MainState.world_grid
	_sector_size = MainState.sector_grid.sector_size
	grid_cells = _calculate_sector_cells()
	_old_status = Status.UNLOADING

func update_status(new: Status):
	if status == new: return
	var _old_status := status
	status = new

func update():
	if status == Status.UNLOADING:
		unload_content()
	elif _old_status == Status.UNLOADING and not _loaded:
		load_content()
	if status == Status.FREEZED:
		freeze()
	elif status == Status.ACTIVE:
		activate()

func unload():
	content_manager.unload_content(_get_items())
	queue_free()

func load_content():
	if is_instance_valid(content_manager):
		content_manager.load_content(position)
		_loaded = true

func unload_content():
	#TODO: turn asteroids back instead of removing them
	content_manager.unload_content(_get_items())

func freeze():
	for item in _get_items():
		if item is StaticRigidBody:
			item.freeze_body()

func activate():
	for item in _get_items():
		if item is StaticRigidBody:
			item.unfreeze_body()

func _get_items() -> Array[Node2D]:
	var items: Array[Node2D] = []
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
		Sector.Status.UNLOADING: return Color.RED
		Sector.Status.FREEZED: return Color.DODGER_BLUE
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
