class_name AsteroidField
extends SectorContentManager

@export var _asteroid_scene: PackedScene
## asteroids per 1000x1000 units
@export_range(1, 20) var density: float = 5.0
@export_range(0.1, 0.9) var size_variation := 0.5
@export_range(0.0, 1.0) var speed_variation := 0.5
@export_range(0.0, 500.0) var speed := 250
@export_range(0.0, PI) var rotation := 0.5

var _asteroids_in_use: Array[Asteroid]
var _asteroids_pool: Array[Asteroid]

var _sector_size: float
var _relative_density: float
var _i_number: int
var _extra_item: float

func init(sector_size: float):
	_sector_size = sector_size
	_relative_density = density * _sector_size * _sector_size * 0.0000001
	_i_number = floori(_relative_density)
	_extra_item = _relative_density - _i_number

func load_content(sector: Vector2):
	var start := sector * _sector_size
	var end := start + Vector2.ONE * _sector_size
	if _extra_item > randf():
		_spawn(start, end)
	for i in _i_number:
		_spawn(start, end)

func _spawn(start: Vector2, end: Vector2):
	var asteroid = _get_asteroid()
	asteroid.position = Vector2(
		randf_range(start.x, end.x),
		randf_range(start.y, end.y)
	)
	MainState.main_scene.add_child(asteroid)
	asteroid.init(
		randf_range(1.0 - size_variation, 1.0 + size_variation),
		speed,
		speed_variation,
		rotation,
		speed_variation)

func unload_content(items: Array[Node2D]):
	for item in items:
		if item is Asteroid:
			_on_asteroid_destroyed(item)
			MainState.main_scene.remove_child(item)

func _get_asteroid() -> Asteroid:
	var asteroid: Asteroid
	if _asteroids_pool.is_empty():
		asteroid = _asteroid_scene.instantiate()
		asteroid.tree_exiting.connect(func():
			_on_asteroid_destroyed(asteroid)
		)
	else:
		asteroid = _asteroids_pool.pop_front()
	_asteroids_in_use.append(asteroid)
	return asteroid

func _on_asteroid_destroyed(asteroid: Asteroid):
	if asteroid in _asteroids_in_use:
		_asteroids_in_use.erase(asteroid)
	if asteroid not in _asteroids_pool:
		_asteroids_pool.append(asteroid)
