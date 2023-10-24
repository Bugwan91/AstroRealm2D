class_name VelocityShifter
extends Node

func _process(_delta):
	owner.linear_velocity -= FloatingOrigin.velocity_delta
