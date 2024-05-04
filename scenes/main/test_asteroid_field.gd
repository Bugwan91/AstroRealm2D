extends Node

@export var body_scene: PackedScene
@export_range(1, 1000) var max_count := 1
@export var bounds: Vector2 = Vector2(10000.0, 10000.0)

var _bodies: Array[FloatingOriginBody]

func _process(_delta: float):
	_spawn()
	_handle_bounds()
	MyDebug.info("bodies", _bodies.size())

func _spawn():
	if _bodies.size() < max_count:
		var new_body := body_scene.instantiate() as FloatingOriginBody
		new_body.position = Vector2(randf_range(-bounds.x, bounds.x), randf_range(-bounds.y, bounds.y))
		new_body._velocity = Vector2(randf_range(-1000.0, 1000.0), randf_range(-1000.0, 1000.0))
		_bodies.append(new_body)
		MainState.main_scene.add_child(new_body)

func _handle_bounds():
	for body in _bodies:
		if abs(body.absolute_position.x) > bounds.x:
			body._velocity.x = -body._velocity.x
		if abs(body.absolute_position.y) > bounds.y:
			body._velocity.y = -body._velocity.y
