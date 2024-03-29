class_name BulletHitEffect
extends FloatingOriginKinetic

@export var color: Color

@onready var particles: GPUParticles2D = %GPUParticles2D
@onready var light: PointLight2D = %Light
@onready var sound: AudioStreamPlayer2D = %Sound

func _ready():
	particles.process_material = particles.process_material.duplicate()
	particles.process_material.color = color * 6.0
	particles.emitting = true
	light.color = color
	sound.finished.connect(queue_free)
