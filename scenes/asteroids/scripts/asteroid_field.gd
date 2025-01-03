extends Node2D

@export_range(0, 100) var count: int = 10
@export var dimensions: Vector2 = Vector2(10000, 10000)
@export var _asteroid_scene: PackedScene

var _asteroids: Array[RigidBody]

func spawn():
	for i in count:
		var asteroid: RigidBody = _asteroid_scene.instantiate()
		asteroid.position = Vector2(
			randf_range(0, dimensions.x) - dimensions.x * 0.5,
			randf_range(0, dimensions.y) - dimensions.y * 0.5
		)
		_asteroids.append(asteroid)
		MainState.main_scene.add_child(asteroid)
