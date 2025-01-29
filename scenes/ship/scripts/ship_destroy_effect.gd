class_name ShipDestroyEffect
extends KineticBody

@onready var _smoke: GPUParticles2D = %Smoke
@onready var _fire: GPUParticles2D = %Fire
@onready var _sparcles: GPUParticles2D = %Sparcles
@onready var _explosion_audio: AudioStreamPlayer2D = %ExplosionAudio

func _ready() -> void:
	_smoke.emitting = true
	_fire.emitting = true
	_sparcles.emitting = true
	_explosion_audio.play()
	_smoke.finished.connect(queue_free)
