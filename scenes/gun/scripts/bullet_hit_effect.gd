class_name BulletHitEffect
extends KineticBody

@export var color: Color

@onready var _particles: GPUParticles2D = %GPUParticles2D
@onready var _light: PointLight2D = %Light
@onready var _sound: AudioStreamPlayer2D = %Sound

func _ready():
	_particles.process_material = _particles.process_material.duplicate()
	_particles.process_material.color = color * 6.0
	_particles.emitting = true
	_light.color = color
	_sound.pitch_scale = randf_range(0.9, 1.1)
	_sound.finished.connect(queue_free)
