class_name Chunk
extends Node

enum Status {NONE, UNLOADING, ACTIVE, DELETING}
var status := Chunk.Status.NONE:
	set(value):
		_previous_status = status
		status = value

var content_managers: Array[ChunkContentManager] = []
var cells_per_chunk: int
var grid_cells: Array[Vector2] = []
var position: Vector2
var size: float
var offset: Vector2

var _previous_status := Chunk.Status.NONE
var _loaded := false
var _should_load := true
var _should_freeze := false
var _should_unfreeze := false
var _handled_items: Array[Node2D] = []

func init(
	chunk_position: Vector2,
	chunk_size: float,
	cells_in_chunk: int,
	offset: Vector2,
	new_content_managers: Array[ChunkContentManager]
	):
	position = chunk_position
	size = chunk_size
	cells_per_chunk = cells_in_chunk
	offset = offset
	content_managers = new_content_managers
	grid_cells = _calculate_chunk_cells()

func update_status(new_status: Status, new_offset: Vector2):
	offset = new_offset
	if status == new_status: return
	status = new_status

func need_to_load() -> bool:
	return (status == Status.ACTIVE and _previous_status == Status.UNLOADING)\
		or status == Status.UNLOADING

func update() -> bool:
	var updated := false
	if status == Status.DELETING:
		unload_content()
		updated = true
	elif status == Status.ACTIVE\
	and (_previous_status == Status.NONE or _previous_status == Status.UNLOADING):
		load_content()
		updated = true
	elif status == Status.UNLOADING:
		if _previous_status == Status.ACTIVE:
			unload_content()
			updated = true
		else:
			replace_content()
			updated = true
	_previous_status = status
	return updated

func unload():
	for manager in content_managers:
		manager.unload_content(_get_items())
	# HACK: check is there no bugs here. It should be not,
	# as chunks are abstract thing that are not a child of any node
	#queue_free()

func load_content():
	for manager in content_managers:
		manager.load_content(position)
	_loaded = true

func replace_content():
	var items := _get_items()
	if items.is_empty(): return
	for manager in content_managers:
		manager.replace_content(items, _get_opposite_chunk())

func unload_content():
	for manager in content_managers:
		manager.unload_content(_get_items())

func _get_items() -> Array[Node2D]:
	return WorldGridManager.instance.grid.get_items_in_cells(grid_cells)

func _get_opposite_chunk() -> Vector2:
	return -(2.0 * offset - offset.clamp(-Vector2.ONE, Vector2.ONE))

func _calculate_chunk_cells() -> Array[Vector2]:
	cells_per_chunk
	var origin := position * cells_per_chunk
	var cells: Array[Vector2] = []
	for x in range(0, cells_per_chunk):
		for y in range(0, cells_per_chunk):
			cells.append(Vector2(
				origin.x + x,
				origin.y + y
			))
	return cells

func draw_debug(duration: float):
	DebugDraw2d.rect(
		position * size + Vector2.ONE * size * 0.5,
		Vector2.ONE * size - Vector2(4,4),
		_get_debug_color(), 2, duration + 0.01)

func _get_debug_color() -> Color:
	match status:
		Chunk.Status.DELETING: return Color.RED
		Chunk.Status.UNLOADING: return Color.ORANGE
		Chunk.Status.ACTIVE: return Color.YELLOW
		_: return Color.PURPLE
