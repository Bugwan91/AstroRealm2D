class_name SectorGrid
extends Node

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
@export_range(0.01, 2.0) var sector_update_delta: float = 0.1
@export_range(0.01, 1.0) var world_update_delta: float = 0.05

@export_category("Debug")
@export var debug := false

@onready var world_grid: WorldGrid = %WorldGrid

var sectors: Dictionary[Vector2, Sector] = {}
var cells_per_sector: int
var player_position: Vector2

var _current_sector: Vector2
var _collected_delta := 0.0
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

func _physics_process(delta: float):
	_collected_delta += delta
	if _collected_delta > sector_update_delta:
		_current_sector = get_sector_position(player_position)
		update_sectors()
		_collected_delta = 0.0
		if debug: draw_debug()

func get_sector_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x * _sector_size_inv),
		floor(position.y * _sector_size_inv)
	)

func update_sectors():
	var sectors_to_keep: Array[Vector2] = []
	# extra 1 in range as 0,0 - actual positive position
	for x in range(-_total_offset, _total_offset + 1):
		for y in range(-_total_offset, _total_offset + 1):
			var offset := Vector2(x, y)
			var sector_pos = _current_sector + offset
			load_or_update_sector(sector_pos, _get_sector_status(offset))
			sectors_to_keep.append(sector_pos)
	for sector_pos in sectors.keys():
		if not sectors_to_keep.has(sector_pos):
			unload_sector(sector_pos)

func _get_sector_status(offset: Vector2) -> Sector.Status:
	var _offset := maxi(absi(offset.x), absi(offset.y))
	if _offset <= active_offset:
		return Sector.Status.ACTIVE
	elif _offset <= _freeze_offset:
		return Sector.Status.FREEZED
	else:
		return Sector.Status.UNLOADING

func load_or_update_sector(sector_position: Vector2, status: Sector.Status):
	var sector: Sector
	if not sector_position in sectors:
		sector = Sector.new()
		sector.init(sector_position)
		sectors[sector_position] = sector
	else:
		sector = sectors[sector_position]
	sector.update(status)

func unload_sector(sector_position: Vector2):
	sectors[sector_position].unload()
	sectors.erase(sector_position)

func draw_debug():
	for pos in sectors:
		sectors[pos].draw_debug(sector_update_delta)

func _update_total_offset():
	_freeze_offset = active_offset + freeze_offset
	_total_offset = _freeze_offset + 1
