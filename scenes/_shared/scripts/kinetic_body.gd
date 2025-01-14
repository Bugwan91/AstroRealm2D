class_name KineticBody
extends Node2D

@export var linear_velocity := Vector2.ZERO
@export var radius := 64.0

var _last_grid_update_delta := 0.0

var speed: float:
	get: return linear_velocity.length()

func _ready() -> void:
	add_child(GridItem.new())

## IMPORTANT: should call it from child
func _physics_process(delta: float):
	position += linear_velocity * delta
