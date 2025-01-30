class_name WorldGridManager
extends Node

@export var world_root: Node2D 

@export_category("Chunks")
@export var chunk_size: int = 5000
@export var active_offset: int = 3
@export_range(0.01, 2.0) var chunk_update_delta: float = 0.5

@export_category("World partition grid")
@export var world_cell_size: int = 500

@export_category("Content")
@export var content_managers: Array[ChunkContentManager]

@export_category("Debug")
@export var draw_debug_chunk := false
@export var draw_debug_grid := false
@export var grid_debug_offset := 4

static var instance: WorldGridManager

var chunks: ChunkGrid
var grid: WorldGrid

var player: Node2D
var player_position: Vector2: set = _set_player_position

func _ready() -> void:
	process_physics_priority = -1000
	WorldGridManager.instance = self
	tree_exiting.connect(_on_destroy)
	_create_grid_system()
	_create_chunks_system()

func init_load() -> void:
	player_position = Vector2.ZERO
	chunks.init_load()

func _create_grid_system() -> void:
	grid = WorldGrid.create(world_root, world_cell_size)
	grid.is_debug = draw_debug_grid
	grid.debug_offset = grid_debug_offset
	add_child(grid)

func _create_chunks_system() -> void:
	chunks = ChunkGrid.create(chunk_size, world_cell_size, active_offset, content_managers)
	chunks.is_debug = draw_debug_chunk
	add_child(chunks)

func _set_player_position(value: Vector2) -> void:
	player_position = value
	chunks.player_position = player_position
	grid.player_position = player_position

func _physics_process(_delta: float) -> void:
	if is_instance_valid(player):
		player_position = player.global_position

func _on_destroy() -> void:
	WorldGridManager.instance = null
