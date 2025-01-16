class_name Sector
extends Node

const UNLOADING_DELTA := 0.5

enum Status {ACTIVE, FREEZED, UNLOADING}

var grid_cells: Array[Vector2] = []
var position: Vector2
var status: Status

var _world: WorldGrid
var _sector_size: float

func init(sector_position: Vector2):
	position = sector_position
	_world = MainState.world_grid
	_sector_size = MainState.sector_grid.sector_size
	grid_cells = _calculate_sector_cells()

func update(new: Status):
	if status == new: return
	var old := status
	status = new

func unload():
	unload_content()
	queue_free()

func load_content():
	pass

func unload_content():
	for cell in grid_cells:
		if cell in _world.grid:
			var items := _world.grid[cell]

func freeze():
	for cell in grid_cells:
		if cell in _world.grid:
			var items := _world.grid[cell]

func activate():
	for cell in grid_cells:
		if cell in _world.grid:
			var items := _world.grid[cell]

func draw_debug(duration: float):
	DebugDraw2d.rect(
		position * _sector_size + Vector2.ONE * _sector_size * 0.5,
		Vector2.ONE * _sector_size - Vector2(4,4),
		get_debug_color(), 2, duration + 0.01)

func get_debug_color() -> Color:
	match status:
		Sector.Status.UNLOADING: return Color.YELLOW
		Sector.Status.FREEZED: return Color.DODGER_BLUE
		Sector.Status.ACTIVE: return Color.TOMATO
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
