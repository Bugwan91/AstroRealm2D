class_name BulletHitEffect
extends KineticBody

@export var color: Color
@export var duration := 0.2

@onready var _particles: GPUParticles2D = %GPUParticles2D
@onready var _light: PointLight2D = %Light
@onready var _sound: AudioStreamPlayer2D = %Sound

var _time:= 0.0
var _start_light_energy: float
var _sound_finished := false

func _ready() -> void:
	_particles.process_material = _particles.process_material.duplicate()
	_particles.process_material.color = color * 6.0
	_particles.emitting = true
	_light.color = color
	_start_light_energy = _light.energy
	_sound.pitch_scale = randf_range(0.9, 1.1)
	_sound.finished.connect(_end_sound)

func _process(delta: float) -> void:
	_time += delta
	if _time < duration:
		_light.energy = lerpf(
			_light.energy,
			0.0,
			delta * _start_light_energy / duration)
	else:
		_end()

func _end_sound() -> void:
	_sound_finished = true
	_end()

func _end() -> void:
	if _time >= duration and _sound_finished:
		queue_free()
