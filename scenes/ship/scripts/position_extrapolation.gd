class_name PositionExtrapolation
extends Node2D

var _last_tick: float = 0
var canvas_position: Vector2:
	get:
		return get_global_transform_with_canvas().origin

var smooth_position: Vector2:
	get:
		return owner.position + position.rotated(owner.rotation)

var smooth_rotation: float:
	get:
		return owner.rotation + rotation

func _ready():
	_last_tick = Time.get_unix_time_from_system()

func _process(_delta):
	var delta = Time.get_unix_time_from_system()
	if "angular_velocity" in owner:
		rotation = owner.angular_velocity * (delta - _last_tick)
	position = owner.linear_velocity.rotated(-owner.rotation) * (delta - _last_tick) + Vector2.ZERO * 100.0

func _physics_process(_delta):
	_last_tick = Time.get_unix_time_from_system()
