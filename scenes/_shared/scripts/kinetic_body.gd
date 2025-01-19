class_name KineticBody
extends Node2D

const FREEZE_DELTA := 0.5

@export var linear_velocity := Vector2.ZERO
@export var angular_velocity: float
@export var radius := 64.0
@export var freeze := false

var grid_item: GridItem

var _order: int
var _delta := 0.0

var speed: float:
	get: return linear_velocity.length()

func _ready() -> void:
	add_child(GridItem.new())
	_order = randi_range(1, Engine.physics_ticks_per_second * FREEZE_DELTA)
	_delta = _order / Engine.physics_ticks_per_second

## IMPORTANT: Should call it from child if overrided
func _process(delta: float):
	if not freeze:
		position += linear_velocity * delta
		rotation += angular_velocity * delta
	else:
		_delta += delta
		if _delta > FREEZE_DELTA:
			position += linear_velocity * _delta
			rotation += angular_velocity * _delta
			grid_item.update()
			_delta = 0.0

func get_posisition_step(delta: float) -> Vector2:
	return linear_velocity * delta if not freeze else linear_velocity * FREEZE_DELTA
