class_name DamageEffect
extends FloatingOriginKinetic

@export var fire_speed_multiplyer := 0.2
@export var fire: GPUParticles2D
@export var smoke: GPUParticles2D

var intensity := 0.0: set = _set_intensity

var _fire_material: ParticleProcessMaterial
var _smoke_material: ParticleProcessMaterial

func _ready():
	_fire_material = fire.process_material.duplicate()
	fire.process_material = _fire_material
	_smoke_material = smoke.process_material.duplicate()
	smoke.process_material = _smoke_material
	intensity = 0.0

func _process(_delta):
	if intensity == 0.0: return
	global_rotation = 0.0
	var direction = Vector3(
		-absolute_velocity.x / speed,
		-absolute_velocity.y / speed,
		0.0
	)
	speed = clamp(speed, 0.0, 2000.0)
	_fire_material.set("direction", direction)
	_fire_material.set("spread", max(180.0 - speed, 6.0))
	_fire_material.set("initial_velocity_min", speed * fire_speed_multiplyer * 0.5)
	_fire_material.set("initial_velocity_max", speed * fire_speed_multiplyer + 100.0)
	_smoke_material.set("direction", direction)
	_smoke_material.set("spread", max(180.0 - speed, 2.0))
	_smoke_material.set("initial_velocity_min", speed)
	_smoke_material.set("initial_velocity_max", speed + 200.0)

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
