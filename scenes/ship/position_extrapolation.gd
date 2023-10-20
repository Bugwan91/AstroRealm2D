class_name PositionExtrapolation
extends Node2D

var _last_tick: float = 0

func _ready():
	_last_tick = Time.get_unix_time_from_system()

func _process(_delta):
	var delta = Time.get_unix_time_from_system()
	rotation = owner.angular_velocity * (delta - _last_tick)
	position = owner.linear_velocity.rotated(-owner.rotation) * (delta - _last_tick)

func _physics_process(_delta):
	_last_tick = Time.get_unix_time_from_system()
