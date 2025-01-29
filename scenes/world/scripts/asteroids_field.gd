class_name AsteroidField
extends ChunkContentManager

@export var _asteroid_scene: PackedScene
## asteroids per 1000x1000 units
@export_range(0, 3) var density: float = 0.5
@export_range(0.1, 0.9) var size_variation := 0.5
@export_range(0.0, 1.0) var speed_variation := 0.5
@export_range(0.0, 3000.0) var speed := 250
@export_range(0.0, PI) var rotation := 0.5
@export var base_velocity: Vector2

var _asteroids_in_use: Array[Asteroid]
var _asteroids_pool: Array[Asteroid]

var _chunk_size: float
var _relative_density: float
var _i_number: int
var _extra_item: float

func init(chunk_size: float) -> void:
	_chunk_size = chunk_size
	_relative_density = density * _chunk_size * _chunk_size * 0.000001
	_i_number = floori(_relative_density)
	_extra_item = _relative_density - _i_number

func load_content(chunk: Vector2) -> void:
	var start := chunk * _chunk_size
	var end := start + Vector2.ONE * _chunk_size
	if _extra_item > randf():
		_spawn(start, end)
	for i in _i_number:
		_spawn(start, end)

func replace_content(items: Array[Node2D], offset: Vector2) -> void:
	var shift := offset * _chunk_size
	for item in items:
		if item is Asteroid:
			item.reset()
			item.position += shift

func unload_content(items: Array[Node2D]) -> void:
	for item in items:
		if item is Asteroid:
			# FIXME: Condition "p_child->data.parent != this" is true.
			if item.get_parent() == WorldGridManager.instance.world_root:
				WorldGridManager.instance.world_root.remove_child(item)

func _spawn(start: Vector2, end: Vector2) -> void:
	var asteroid := _get_asteroid()
	asteroid.position = Vector2(
		randf_range(start.x, end.x),
		randf_range(start.y, end.y)
	)
	WorldGridManager.instance.world_root.add_child(asteroid)
	asteroid.init(
		randf_range(1.0 - size_variation, 1.0 + size_variation),
		base_velocity,
		speed,
		speed_variation,
		rotation,
		speed_variation)

func _get_asteroid() -> Asteroid:
	var asteroid: Asteroid
	if _asteroids_pool.is_empty():
		asteroid = _asteroid_scene.instantiate()
		asteroid.tree_exiting.connect(_on_asteroid_destroyed.bind(asteroid))
	else:
		asteroid = _asteroids_pool.pop_front()
	_asteroids_in_use.append(asteroid)
	return asteroid

func _on_asteroid_destroyed(asteroid: Asteroid) -> void:
	if asteroid in _asteroids_in_use:
		_asteroids_in_use.erase(asteroid)
	if asteroid not in _asteroids_pool:
		_asteroids_pool.append(asteroid)
