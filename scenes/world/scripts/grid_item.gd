class_name GridItem
extends Node

var body: Node2D

var cell: Vector2
var order: int
var global_position: Vector2:
	get: return body.global_position

var freeze: bool: set = _set_freeze

func _ready() -> void:
	process_physics_priority = 100
	body = get_parent()
	if body is StaticRigidBody:
		body._init_velocity_hack()
	if body is StaticRigidBody or body is KineticBody:
		freeze = body.freeze
	_update_grid(true)

func _physics_process(_delta: float) -> void:
	_update_grid()

func freeze_process(delta: float):
	if not freeze: return
	if body is KineticBody:
		#body._process(delta)
		body.freeze_process(delta)
	if body is StaticRigidBody:
		body.freeze_process(delta)
	_update_grid()

func _update_grid(force: bool = false):
	cell = WorldGridManager.instance.grid.add_or_update(self)

func _set_freeze(value: bool):
	if freeze == value: return
	freeze = value
	set_physics_process(not freeze)
	if body is StaticRigidBody:
		body.freeze_body(freeze)
	elif body is KineticBody:
		body.freeze = freeze
