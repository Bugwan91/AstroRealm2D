class_name SectorGrid
extends Node

@export var sector_size: int = 5000:
	set(value):
		sector_size = value
		_sector_size_inv = 1.0 / value
@export var world_cell_size: int = 500
@export var active_offset: int = 3:
	set(value):
		active_offset = value
		_update_batch_value()
@export_range(0.01, 2.0) var sector_update_delta: float = 0.5

@export_category("Content")
@export var content_manager: SectorContentManager

@export_category("Debug")
@export var debug_sector := false
@export var debug_grid := false

@onready var world_grid: WorldGrid = %WorldGrid

var sectors: Dictionary[Vector2, Sector] = {}
var cells_per_sector: int
var player_position: Vector2

var _current_sector: Vector2
var _collected_delta := 0.0
var _sectors_to_update: Array[Vector2] = []
var _sectors_to_unload: Array[Vector2] = []
var _update_batch: int = 1
var _sector_size_inv: float
var _total_offset: int

func _ready() -> void:
	cells_per_sector = sector_size / world_cell_size
	_sector_size_inv = 1.0 / sector_size
	world_grid.cell_size = world_cell_size
	world_grid.debug = debug_grid
	_update_batch_value()
	MainState.sector_grid = self
	content_manager.init(sector_size)

func _physics_process(delta: float):
	_collected_delta += delta
	if _collected_delta > sector_update_delta:
		_current_sector = get_sector_position(player_position)
		update_sectors()
		_collected_delta = 0.0
		if debug_sector: draw_debug()
	_unload_prepared_sectors()
	_update_prepared_sectors()
	MyDebug.list({
		"pool": content_manager._asteroids_pool.size(),
		"in_use": content_manager._asteroids_in_use.size()
	})

func _unload_prepared_sectors():
	var i := 0
	var copy = _sectors_to_unload
	for sector in copy:
		unload_sector(sector)
		_sectors_to_unload.erase(sector)
		i += 1
		if i > _update_batch:
			return

func _update_prepared_sectors():
	var i := 0
	var copy = _sectors_to_update
	for sector in copy:
		if sectors[sector].update(): i += 1
		_sectors_to_update.erase(sector)
		if i > _update_batch:
			return

func get_sector_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x * _sector_size_inv),
		floor(position.y * _sector_size_inv)
	)

func update_sectors():
	# extra 1 in range as 0,0 - actual positive position
	var sectors_to_keep: Array[Vector2] = []
	for x in range(-_total_offset, _total_offset + 1):
		for y in range(-_total_offset, _total_offset + 1):
			var offset := Vector2(x, y)
			var sector_pos = _current_sector + offset
			load_or_update_sector(sector_pos, offset)
			sectors_to_keep.append(sector_pos)
	for sector_pos in sectors.keys():
		if not sectors_to_keep.has(sector_pos)\
		and not _sectors_to_unload.has(sector_pos):
			sectors[sector_pos].status = Sector.Status.DELETING
			_sectors_to_unload.append(sector_pos)

func load_or_update_sector(sector_position: Vector2, offset: Vector2):
	var sector: Sector
	if not sector_position in sectors:
		sector = Sector.new()
		sector.init(sector_position, offset, content_manager)
		sectors[sector_position] = sector
		if not _sectors_to_update.has(sector_position):
			_sectors_to_update.append(sector_position)
	else:
		sector = sectors[sector_position]
	sector.update_status(_get_sector_status(offset), offset)
	if sector.need_to_load() and not _sectors_to_update.has(sector_position):
		_sectors_to_update.append(sector_position)

func _get_sector_status(offset: Vector2) -> Sector.Status:
	var offset_max := maxi(absi(offset.x), absi(offset.y))
	if offset_max <= active_offset:
		return Sector.Status.ACTIVE
	elif offset_max == active_offset + 1:
		return Sector.Status.UNLOADING
	else:
		return Sector.Status.DELETING

func unload_sector(sector_position: Vector2):
	sectors[sector_position].unload()
	sectors.erase(sector_position)

func draw_debug():
	var items := 0
	for cell in MainState.world_grid.grid:
		items += MainState.world_grid.grid[cell].size()
	for pos in sectors:
		sectors[pos].draw_debug(sector_update_delta)

func _update_batch_value():
	_total_offset = active_offset + 1
	var total_sectors := _total_offset * 2.0 + 1.0
	total_sectors *= total_sectors
	var ticks := sector_update_delta * Engine.physics_ticks_per_second
	_update_batch = total_sectors / ticks + 1
