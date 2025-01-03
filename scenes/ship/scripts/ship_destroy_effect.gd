class_name ShipDestroyEffect
extends KineticBody

@onready var _smoke: GPUParticles2D = %Smoke
@onready var _fire = %Fire
@onready var _sparcles = %Sparcles
@onready var _explosion_audio = %ExplosionAudio

func _ready():
	_smoke.emitting = true
	_fire.emitting = true
	_sparcles.emitting = true
	_explosion_audio.play()
	_smoke.finished.connect(queue_free)
