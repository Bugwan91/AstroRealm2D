class_name PositionExtrapolation
extends Node2D

@export var enabled := true

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
	process_priority = -999
	_last_tick = Time.get_unix_time_from_system()

func _process(_delta):
	if not enabled: return
	var delta = Time.get_unix_time_from_system()
	if "angular_velocity" in owner:
		rotation = owner.angular_velocity * (delta - _last_tick)
	position = owner.linear_velocity.rotated(-owner.rotation) * (delta - _last_tick)

func _physics_process(_delta):
	if not enabled: return
	_last_tick = Time.get_unix_time_from_system()
