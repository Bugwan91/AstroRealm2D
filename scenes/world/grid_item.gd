class_name GridItem
extends Node

@export var _extra_time_shift := 0.1

var _body: Node2D
var _last_update_delta := 0.0

func _ready() -> void:
	_body = get_parent()
	_body.tree_exiting.connect(_remove_from_grid)

func _physics_process(delta: float) -> void:
	_update_local(delta)

func _get_velocity() -> Vector2:
	if _body is RigidBody or _body is KineticBody:
		return _body.linear_velocity
	return Vector2.ZERO

func _remove_from_grid():
	MainState.local_grid.remove(_body)

func _update_local(delta: float):
	_last_update_delta += delta
	if _last_update_delta > MainState.local_grid.DELTA:
		MainState.local_grid.add_or_update(_body, _get_velocity() * _extra_time_shift)
		_last_update_delta = 0.0
