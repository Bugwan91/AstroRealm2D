class_name BulletHitEffect
extends Node2D

@onready var point_light_2d = %PointLight2D
@onready var timer = %Timer

var linear_velocity := Vector2.ZERO

func _ready():
	add_to_group("shiftable")
	timer.timeout.connect(_self_destroy)
	timer.start()

func _process(delta):
	pass
	position += linear_velocity * delta

func _self_destroy():
	queue_free()
