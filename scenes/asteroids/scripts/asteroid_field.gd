extends Node2D

@export_range(0, 100) var count: int = 10
@export var dimensions: Vector2 = Vector2(10000, 10000)
@export var _asteroid_scene: PackedScene
@export_range(0, 0.5) var size_variation: float = 0.5

var _asteroids: Array[Asteroid]

func spawn():
	for i in count:
		var asteroid: Asteroid = _asteroid_scene.instantiate()
		asteroid.position = Vector2(
			randf_range(0, dimensions.x) - dimensions.x * 0.5,
			randf_range(0, dimensions.y) - dimensions.y * 0.5
		)
		asteroid.rotation = randf_range(-PI, PI)
		asteroid.size = randf_range(1.0 - size_variation, 1.0 + size_variation)
		_asteroids.append(asteroid)
		MainState.main_scene.add_child(asteroid)
