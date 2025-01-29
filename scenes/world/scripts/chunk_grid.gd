class_name ChunkGrid
extends Node

var chunk_size: int = 5000:
	set(value):
		chunk_size = value
		_chunk_size_inv = 1.0 / value
# TODO: chunk_size should contain whole numbers of cells
var cell_size: float
var active_offset: int = 3:
	set(value):
		active_offset = value
		_update_batch_value()
var update_delta: float = 0.5
var content_managers: Array[ChunkContentManager] = []

var is_debug := false

var chunks: Dictionary[Vector2, Chunk] = {}
var cells_per_chunk: int
var player_position: Vector2

var _current_chunk: Vector2
var _collected_delta := 0.0
var _chunks_to_update: Array[Vector2] = []
var _chunks_to_unload: Array[Vector2] = []
var _update_batch: int = 1
var _chunk_size_inv: float
var _total_offset: int

func _ready() -> void:
	process_physics_priority = -998
	cells_per_chunk = int(chunk_size / cell_size)
	_chunk_size_inv = 1.0 / chunk_size
	_update_batch_value()
	_init_content_managers()

func _init_content_managers() -> void:
	for manager in content_managers:
		manager.init(chunk_size)

func _physics_process(delta: float) -> void:
	_collected_delta += delta
	if _collected_delta > update_delta:
		_current_chunk = get_chunk_position(player_position)
		update_chunks()
		_collected_delta = 0.0
		if is_debug: draw_debug()
	_unload_prepared_chunks()
	_update_prepared_chunks()
	# FIXME: Should be removed
	MyDebug.list({
		"pool": content_managers[0]._asteroids_pool.size(),
		"in_use": content_managers[0]._asteroids_in_use.size()
	})

func _unload_prepared_chunks() -> void:
	var i := 0
	var copy := _chunks_to_unload
	for chunk in copy:
		unload_chunk(chunk)
		_chunks_to_unload.erase(chunk)
		i += 1
		if i > _update_batch:
			return

func _update_prepared_chunks() -> void:
	var i := 0
	var copy := _chunks_to_update
	for chunk in copy:
		if chunks[chunk].update(): i += 1
		_chunks_to_update.erase(chunk)
		if i > _update_batch:
			return

func get_chunk_position(position: Vector2) -> Vector2:
	return Vector2(
		floor(position.x * _chunk_size_inv),
		floor(position.y * _chunk_size_inv)
	)

func update_chunks() -> void:
	# extra 1 in range as 0,0 - actual positive position
	var chunks_to_keep: Array[Vector2] = []
	for x in range(-_total_offset, _total_offset + 1):
		for y in range(-_total_offset, _total_offset + 1):
			var offset := Vector2(x, y)
			var chunk_pos := _current_chunk + offset
			load_or_update_chunk(chunk_pos, offset)
			chunks_to_keep.append(chunk_pos)
	for chunk_pos in chunks.keys() as Array[Vector2]:
		if not chunks_to_keep.has(chunk_pos)\
		and not _chunks_to_unload.has(chunk_pos):
			chunks[chunk_pos].status = Chunk.Status.DELETING
			_chunks_to_unload.append(chunk_pos)

func load_or_update_chunk(chunk_position: Vector2, offset: Vector2) -> void:
	var chunk: Chunk
	if not chunk_position in chunks:
		chunk = Chunk.new()
		chunk.init(chunk_position, chunk_size, cells_per_chunk, offset, content_managers)
		chunks[chunk_position] = chunk
		if not _chunks_to_update.has(chunk_position):
			_chunks_to_update.append(chunk_position)
	else:
		chunk = chunks[chunk_position]
	chunk.update_status(_get_chunk_status(offset), offset)
	if chunk.need_to_load() and not _chunks_to_update.has(chunk_position):
		_chunks_to_update.append(chunk_position)

func _get_chunk_status(offset: Vector2) -> Chunk.Status:
	var offset_max := maxi(absi(int(offset.x)), absi(int(offset.y)))
	if offset_max <= active_offset:
		return Chunk.Status.ACTIVE
	elif offset_max == active_offset + 1:
		return Chunk.Status.UNLOADING
	else:
		return Chunk.Status.DELETING

func unload_chunk(chunk_position: Vector2) -> void:
	chunks[chunk_position].unload()
	chunks.erase(chunk_position)

func draw_debug() -> void:
	for pos in chunks:
		chunks[pos].draw_debug(update_delta)

func _update_batch_value() -> void:
	_total_offset = active_offset + 1
	var total_chunks := _total_offset * 2.0 + 1.0
	total_chunks *= total_chunks
	var ticks := update_delta * Engine.physics_ticks_per_second
	_update_batch = int(total_chunks / ticks + 1)
