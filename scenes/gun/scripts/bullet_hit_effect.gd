class_name BulletHitEffect
extends Node2D

@onready var timer = %Timer
@onready var particles: GPUParticles2D = %GPUParticles2D

var linear_velocity := Vector2.ZERO

func _ready():
	FloatingOrigin.add(self)
	timer.timeout.connect(_self_destroy)
	timer.start()

func _process(delta):
	position += linear_velocity * delta

func update_material(material: ParticleProcessMaterial):
	particles.process_material = material


func _self_destroy():
	queue_free()
