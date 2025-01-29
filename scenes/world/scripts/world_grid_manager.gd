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
	_create_grid_system()
	_create_chunks_system()
	WorldGridManager.instance = self
	tree_exiting.connect(_on_destroy)

func _create_grid_system() -> void:
	grid = WorldGrid.new()
	grid.root = world_root
	grid.cell_size = world_cell_size
	grid.is_debug = draw_debug_grid
	grid.debug_offset = grid_debug_offset
	add_child(grid)

func _create_chunks_system() -> void:
	chunks = ChunkGrid.new()
	chunks.active_offset = active_offset
	chunks.chunk_size = chunk_size
	chunks.cell_size = world_cell_size
	chunks.content_managers = content_managers
	chunks.is_debug = draw_debug_chunk
	add_child(chunks)

func _set_player_position(value: Vector2) -> void:
	player_position = value
	chunks.player_position = player_position
	grid.player_position = player_position

func _physics_process(_delta: float) -> void:
	player_position = player.global_position if is_instance_valid(player) else Vector2.ZERO

func _on_destroy() -> void:
	WorldGridManager.instance = null
