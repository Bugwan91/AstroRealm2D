extends Node2D
class_name PositionInterpolation

@export var enabled: bool = false
var rb: RigidBody2D
var last_tick: float = 0

func _ready():
	rb = owner
	last_tick = Time.get_unix_time_from_system()

func _process(_delta):
	var delta = Time.get_unix_time_from_system()
	rotation = rb.angular_velocity * (delta - last_tick)
	position = rb.linear_velocity.rotated(-rb.rotation) * (delta - last_tick)

func _physics_process(_delta):
	last_tick = Time.get_unix_time_from_system()
