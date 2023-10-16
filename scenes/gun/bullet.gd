class_name Bullet
extends RigidBody2D

@onready var timer = %Timer

func start(lifetime: float):
	timer.timeout.connect(_self_destroy)
	timer.start(lifetime)

func _self_destroy():
	queue_free()
