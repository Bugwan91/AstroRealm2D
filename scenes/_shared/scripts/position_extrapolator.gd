class_name PositionExtrapolator
extends Node2D

@export var enabled := true:
	set(value):
		enabled = value
		set_process(is_active)

var freeze := false:
	set(value):
		freeze = value
		set_process(is_active)

var is_active: bool:
	get: return enabled and not freeze

var canvas_position: Vector2:
	get:
		return get_global_transform_with_canvas().origin

var smooth_position: Vector2:
	get:
		return _body.position + position.rotated(_body.rotation)

var smooth_rotation: float:
	get:
		return _body.rotation + rotation

var _body: RigidBody

func _ready():
	process_priority = -1000
	_body = get_parent() as RigidBody2D
	assert(is_instance_valid(_body), "Wrong parent for position extrapolation")
	_body.extrapolator = self
	set_process(is_active)

# HACK: There is Godot's Physics interpolation, but it works not perfect.
# Maybe I need to add camera as child to player's ship to fix it.
# Need to try it layter.
func _process(_delta) -> void:
	var delta := Engine.get_physics_interpolation_fraction() * MainState.last_delta
	rotation = _body.angular_velocity * delta
	position = _body.linear_velocity.rotated(-_body.rotation) * delta
