class_name RigidBody
extends RigidBody2D

@export var radius := 64.0

var _debug_color: Color = Color.from_hsv(randf(), 1.0, 1.0)

var _collision_layer: int = 0
var _collision_mask: int = 0

var speed: float:
	get:
		return linear_velocity.length()

func _ready() -> void:
	add_child(GridItem.new())
	_collision_layer = collision_layer
	_collision_mask = _collision_mask

func disable_collisions():
	collision_layer = 0
	collision_mask = 0

func enable_collisions():
	collision_layer = _collision_layer
	collision_mask = _collision_mask

func delta_v(target_v: Vector2) -> Vector2:
	return target_v - linear_velocity
