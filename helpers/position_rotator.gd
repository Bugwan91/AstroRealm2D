extends Node2D

@export var speed := 1.0

func _physics_process(delta):
	position = position.rotated(speed * delta)
