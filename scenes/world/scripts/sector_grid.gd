class_name SectorGrid
extends Node

const TICK_TIME := 0.015

@export var sector_size: int = 500:
	set(value):
		sector_size = value
		_sector_size_inv = 1.0 / value
@export var world_cell_size: int = 100
@export var active_offset: int = 1:
	set(value):
		active_offset = value
		_update_total_offset()
@export var freeze_offset: int = 2:
	set(value):
		freeze_offset = value
		_update_total_offset()
@export_range(0.01, 2.0) var sector_update_delta: float = 0.2
@export_range(0.01, 1.0) var world_update_delta: float = 0.05

@export_category("Content")
@export var content_manager: SectorContentManager

@export_category("Debug")
@export var debug := false

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
var _freeze_offset: int
var _total_offset: int

func _ready() -> void:
	cells_per_sector = sector_size / world_cell_size
	_sector_size_inv = 1.0 / sector_size
	world_grid.cell_size = world_cell_size
	world_grid.update_delta = world_update_delta
	_update_total_offset()
	MainState.sector_grid = self
	content_manager.init(sector_size)

func _physics_process(delta: float):
	_collected_delta += delta
	if _collected_delta > sector_update_delta:
		_current_sector = get_sector_position(player_position)
		update_sectors()
		_collected_delta = 0.0
		if debug: draw_debug()
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
		sectors[sector].update()
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
	for x in range(-_total_offset, _total_offset + 1):
		for y in range(-_total_offset, _total_offset + 1):
			var offset := Vector2(x, y)
			var sector_pos = _current_sector + offset
			load_or_update_sector(sector_pos, offset)
			if not _sectors_to_update.has(sector_pos):
				_sectors_to_update.append(sector_pos)
	for sector_pos in sectors.keys():
		if not _sectors_to_update.has(sector_pos) and not _sectors_to_unload.has(sector_pos):
			_sectors_to_unload.append(sector_pos)

func _get_sector_status(offset: Vector2) -> Sector.Status:
	var _offset := maxi(absi(offset.x), absi(offset.y))
	if _offset <= active_offset:
		return Sector.Status.ACTIVE
	elif _offset <= _freeze_offset:
		return Sector.Status.FREEZED
	else:
		return Sector.Status.UNLOADING

func load_or_update_sector(sector_position: Vector2, offset: Vector2):
	var sector: Sector
	if not sector_position in sectors:
		sector = Sector.new()
		sector.init(sector_position, offset, content_manager)
		sectors[sector_position] = sector
	else:
		sector = sectors[sector_position]
	sector.update_status(_get_sector_status(offset), offset)

func unload_sector(sector_position: Vector2):
	sectors[sector_position].unload()
	sectors.erase(sector_position)

func draw_debug():
	var items := 0
	for cell in MainState.world_grid.grid:
		items += MainState.world_grid.grid[cell].size()
	for pos in sectors:
		sectors[pos].draw_debug(sector_update_delta)

func _update_total_offset():
	_freeze_offset = active_offset + freeze_offset
	_total_offset = _freeze_offset + 1
	_update_batch_value()

func _update_batch_value():
	var total_sectors := _total_offset * 2.0 + 1.0
	total_sectors *= total_sectors
	var ticks := sector_update_delta / TICK_TIME
	_update_batch = total_sectors / ticks + 1
