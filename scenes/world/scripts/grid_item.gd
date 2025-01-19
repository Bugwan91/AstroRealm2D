class_name GridItem
extends Node

var body: Node2D
@onready var _world: WorldGrid

var cell: Vector2
var global_position: Vector2:
	get: return body.global_position

var freeze: bool:
	set(value):
		if freeze == value: return
		freeze = value
		set_physics_process(not freeze)

func _ready() -> void:
	process_physics_priority = 99
	body = get_parent()
	if body is StaticRigidBody or body is KineticBody:
		body.grid_item = self
		freeze = body.freeze
	body.tree_exiting.connect(_remove_from_grid)
	_update_world_grid()
	MainState.world_grid_updated.connect(_update_world_grid)

func update(force: bool = false):
	cell = _world.add_or_update(self)

func freeze_body(value: bool):
	if freeze == value: return
	freeze = value
	if body is StaticRigidBody:
		body.freeze_body(value)
	elif body is KineticBody:
		body.freeze = value

func _physics_process(_delta: float) -> void:
	update()

func _update_world_grid(grid: WorldGrid = MainState.world_grid):
	_world = grid
	update(true)

func _get_velocity() -> Vector2:
	if body is RigidBody or body is KineticBody:
		return body.linear_velocity
	return Vector2.ZERO

func _remove_from_grid():
	_world.remove(self)
