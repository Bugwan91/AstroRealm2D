class_name DamageEffect
extends Node2D

@export var fire: GPUParticles2D
@export var smoke: GPUParticles2D

@export var intensity := 0.0: set = _set_intensity

var _fire_material: ParticleProcessMaterial
var _smoke_material: ParticleProcessMaterial

func _ready():
	_fire_material = fire.process_material.duplicate()
	fire.process_material = _fire_material
	_smoke_material = smoke.process_material.duplicate()
	smoke.process_material = _smoke_material
	#intensity = 0.0

func _set_intensity(value: float):
	intensity = value
	if intensity > 0.0:
		fire.emitting = true
		fire.amount_ratio = intensity
		smoke.emitting = true
		smoke.amount_ratio = intensity
		modulate.a = intensity
	else:
		fire.emitting = false
		smoke.emitting = false
