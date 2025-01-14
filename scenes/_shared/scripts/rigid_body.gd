class_name RigidBody
extends RigidBody2D

@export var radius := 64.0

var tick_acceleration: Vector2

var _last_velocity: Vector2
var _last_grid_update_delta := 0.0
var _debug_color: Color = Color.from_hsv(randf(), 0.9, 0.8)

var speed: float:
	get:
		return linear_velocity.length()

func _ready() -> void:
	add_child(GridItem.new())

## Always call in the end of overriding method
func _physics_process(delta: float):
	tick_acceleration = (linear_velocity - _last_velocity)
	_last_velocity = linear_velocity

func delta_v(target_v: Vector2) -> Vector2:
	return target_v - linear_velocity
