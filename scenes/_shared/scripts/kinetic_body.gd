class_name KineticBody
extends Node2D

@export var linear_velocity := Vector2.ZERO
@export var angular_velocity: float
@export var radius := 64.0
@export var update_interval := 0.0

var _delta := 0.0

var speed: float:
	get: return linear_velocity.length()

func _ready() -> void:
	add_child(GridItem.new())

## IMPORTANT: should call it from child
func _physics_process(delta: float):
	_delta += delta
	if _delta > update_interval:
		position += linear_velocity * _delta
		rotation += angular_velocity * _delta
		_delta = 0.0
