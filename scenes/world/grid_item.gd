class_name GridItem
extends Node

var _body: Node2D
@onready var _world: WorldPartitionSystem = MainState.local_grid

func _ready() -> void:
	_body = get_parent()
	_body.tree_exiting.connect(_remove_from_grid)
	_world.add_or_update(_body, true)

func _physics_process(_delta: float) -> void:
	_world.add_or_update(_body)

func _get_velocity() -> Vector2:
	if _body is RigidBody or _body is KineticBody:
		return _body.linear_velocity
	return Vector2.ZERO

func _remove_from_grid():
	_world.remove(_body)
