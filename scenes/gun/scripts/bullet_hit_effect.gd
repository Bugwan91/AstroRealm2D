class_name BulletHitEffect
extends Node2D

@onready var point_light_2d = %PointLight2D
@onready var timer = %Timer

var velocity := Vector2.ZERO

func _ready():
	timer.timeout.connect(_self_destroy)
	timer.start()

func _physics_process(delta):
	position += velocity * delta

func _self_destroy():
	queue_free()
