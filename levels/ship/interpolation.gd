@tool
class_name PositionInterpolation
extends Node2D

@export var enabled: bool = true
var _target: RigidBody2D
var _last_tick: float = 0

func _ready():
	_target = get_parent() as RigidBody2D
	_last_tick = Time.get_unix_time_from_system()

func _process(_delta):
	if Engine.is_editor_hint(): return
	var delta = Time.get_unix_time_from_system()
	rotation = _target.angular_velocity * (delta - _last_tick)
	position = _target.linear_velocity.rotated(-_target.rotation) * (delta - _last_tick)

func _physics_process(_delta):
	if Engine.is_editor_hint(): return
	_last_tick = Time.get_unix_time_from_system()

func _get_configuration_warnings():
	var warnings: Array[String] = []
	if not (is_instance_valid(_target) and _target is RigidBody2D):
		warnings.append("Expect a RigidBody2D as parent node")
	return warnings
