extends Node2D
@export var active := true
@export_range(0, 1000) var count: int = 10
@export var dimensions: Vector2 = Vector2(10000, 10000)
@export var _asteroid_scene: PackedScene
@export_range(0, 0.5) var size_variation: float = 0.5
@export_range(0.01, 1000.0) var asteroid_mass: float = 5.0
@export_range(0, 5000) var speed_variation: float = 256.0
@export_range(0, PI) var angular_variation: float = 1
@export_range(0, 5) var update_interval: float = 0.5

var _asteroids: Array[Asteroid]
var _ac_delta := 0.0
var _desired_energy := 0.0
var _delta_energy := 0.0

func spawn():
	if not active: return
	for i in count:
		var size := randf_range(1.0 - size_variation, 1.0 + size_variation)
		var asteroid: Asteroid = _asteroid_scene.instantiate()
		asteroid.position = Vector2(
			randf_range(0, dimensions.x) - dimensions.x * 0.5,
			randf_range(0, dimensions.y) - dimensions.y * 0.5
		)
		asteroid.rotation = randf_range(-PI, PI)
		asteroid.size = size
		asteroid.mass = sqrt(size) * asteroid_mass
		asteroid.linear_velocity = Vector2(.0, randf_range(.0, speed_variation)).rotated(randf_range(-PI, PI))
		asteroid.angular_velocity = (randf_range(.0, angular_variation * 2.0) - angular_variation) / asteroid.size
		_asteroids.append(asteroid)
		asteroid.tree_exiting.connect(func ():
			_asteroids.erase(asteroid)
		)
		_desired_energy += asteroid.mass * asteroid.linear_velocity.length()
		MainState.main_scene.add_child(asteroid)

func _process(delta: float) -> void:
	if not active: return
	_ac_delta += delta
	if _ac_delta > update_interval:
		_add_energy()
		_get_asteroids_back()
		_ac_delta = 0.0

func _add_energy():
	var ke := 0.0
	for a in _asteroids:
		ke += a.linear_velocity.length() * a.mass
	_delta_energy = _desired_energy - ke
	MyDebug.info("del_energy", _delta_energy * 0.0001)
	MyDebug.info("act_energy", ke * 0.0001)
	MyDebug.info("des_energy", _desired_energy * 0.0001)

func _get_asteroids_back():
	for asteroid in _asteroids:
		var vector := asteroid.linear_velocity.normalized().rotated(randf_range(-1.5, 1.5)) if _delta_energy > 0 else Vector2.ZERO
		if absf(asteroid.position.x) > dimensions.x * 0.5:
			vector.x = sign(position.x - asteroid.position.x)
		if absf(asteroid.position.y) > dimensions.y * 0.5:
			vector.y = sign(position.y - asteroid.position.y)
		if not vector.is_zero_approx():
			asteroid.apply_central_force(asteroid.mass * speed_variation * vector)
