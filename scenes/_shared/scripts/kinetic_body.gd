class_name KineticBody
extends Node2D

@export var linear_velocity := Vector2.ZERO
@export var angular_velocity: float
@export var radius := 64.0

var freeze := false:
	set(value):
		freeze = value
		set_process(not freeze)

var speed: float:
	get: return linear_velocity.length()

## IMPORTANT: Should call it from child if overrided
func _process(delta: float):
	position += linear_velocity * delta
	rotation += angular_velocity * delta

func freeze_process(delta: float):
	_process(delta)
