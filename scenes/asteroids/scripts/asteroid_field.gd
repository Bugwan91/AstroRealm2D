extends Node2D

@export_range(0, 1000) var count: int = 10
@export var dimensions: Vector2 = Vector2(10000, 10000)
@export var _asteroid_scene: PackedScene
@export_range(0, 0.5) var size_variation: float = 0.5
@export_range(0, 5000) var speed_variation: float = 256.0
@export_range(0, PI) var angular_variation: float = 1
@export_range(0, 5) var update_interval: float = 0.5

var _asteroids: Array[Asteroid]
var _ac_delta := 0.0

func spawn():
	for i in count:
		var asteroid: Asteroid = _asteroid_scene.instantiate()
		asteroid.position = Vector2(
			randf_range(0, dimensions.x) - dimensions.x * 0.5,
			randf_range(0, dimensions.y) - dimensions.y * 0.5
		)
		asteroid.rotation = randf_range(-PI, PI)
		asteroid.size = randf_range(1.0 - size_variation, 1.0 + size_variation)
		asteroid.linear_velocity = Vector2(.0, randf_range(.0, speed_variation)).rotated(randf_range(-PI, PI))
		asteroid.angular_velocity = randf_range(.0, angular_variation * 2.0) - angular_variation
		_asteroids.append(asteroid)
		asteroid.tree_exiting.connect(func ():
			_asteroids.erase(asteroid)
		)
		MainState.main_scene.add_child(asteroid)

func _process(delta: float) -> void:
	_ac_delta += delta
	if _ac_delta > update_interval:
		_ac_delta = 0.0
		for asteroid in _asteroids:
			var vector := Vector2.ZERO
			if absf(asteroid.position.x) > dimensions.x * 0.5:
				vector.x = sign(position.x - asteroid.position.x) * speed_variation
			if absf(asteroid.position.y) > dimensions.y * 0.5:
				vector.y = sign(position.y - asteroid.position.y) * speed_variation
			if not vector.is_zero_approx():
				asteroid.apply_central_force(asteroid.mass * vector)
