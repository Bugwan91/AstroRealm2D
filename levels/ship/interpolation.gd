extends Node2D
class_name PositionInterpolation

@export var enabled: bool = false
@export var target: RigidBody2D
var last_tick: float = 0

func _ready():
	last_tick = Time.get_unix_time_from_system()

func _process(_delta):
	var delta = Time.get_unix_time_from_system()
	rotation = target.rotation + target.angular_velocity * (delta - last_tick)
	position = target.position + target.linear_velocity * (delta - last_tick)

func _physics_process(_delta):
	last_tick = Time.get_unix_time_from_system()
