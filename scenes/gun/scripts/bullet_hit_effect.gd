class_name BulletHitEffect
extends Node2D

@export var color: Color

@onready var timer = %Timer
@onready var particles: GPUParticles2D = %GPUParticles2D
@onready var light = %Light

var linear_velocity := Vector2.ZERO

func _ready():
	particles.process_material = particles.process_material.duplicate()
	particles.process_material.color = color * 3.0
	light.color = color
	FloatingOrigin.add(self)
	timer.timeout.connect(_self_destroy)
	timer.start()

func _process(delta):
	position += linear_velocity * delta

func _self_destroy():
	queue_free()
