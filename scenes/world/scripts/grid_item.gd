class_name GridItem
extends Node

var _body: Node2D
@onready var _world: WorldGrid

func _ready() -> void:
	_body = get_parent()
	_body.tree_exiting.connect(_remove_from_grid)
	_update_world_grid()
	MainState.world_grid_updated.connect(_update_world_grid)

func _update_world_grid(grid: WorldGrid = MainState.world_grid):
	_world = grid
	_world.add_or_update(_body, true)

func _physics_process(_delta: float) -> void:
	_world.add_or_update(_body)

func _get_velocity() -> Vector2:
	if _body is RigidBody or _body is KineticBody:
		return _body.linear_velocity
	return Vector2.ZERO

func _remove_from_grid():
	_world.remove(_body)
