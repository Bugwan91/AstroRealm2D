class_name DamageEffect
extends Node2D

@export var ship: ShipRigidBody
@export_range(0, 1) var show_damage_hp := 0.3
@export var fire_speed_multiplyer := 0.2
@export var fire: GPUParticles2D
@export var smoke: GPUParticles2D

@onready var health: Health = get_node("../../Health")

var intensity := 0.0: set = _set_intensity

var _fire_material: ParticleProcessMaterial
var _smoke_material: ParticleProcessMaterial

func _ready():
	_fire_material = fire.process_material.duplicate()
	fire.process_material = _fire_material
	_smoke_material = smoke.process_material.duplicate()
	smoke.process_material = _smoke_material
	intensity = 0.0
	if is_instance_valid(health):
		health.damaged.connect(_on_damage)

func _process(_delta):
	if intensity == 0.0: return
	global_rotation = 0.0
	var v = ship.real_velocity
	var speed = v.length()
	var direction = Vector3(
		-v.x / speed,
		-v.y / speed,
		0.0
	)
	_fire_material.set("direction", direction)
	_fire_material.set("initial_velocity_min", speed * fire_speed_multiplyer * 0.5)
	_fire_material.set("initial_velocity_max", speed * fire_speed_multiplyer)
	_smoke_material.set("direction", direction)
	_smoke_material.set("initial_velocity_min", speed)
	_smoke_material.set("initial_velocity_max", speed)

func _set_intensity(value: float):
	intensity = value
	if intensity > 0.0:
		fire.emitting = true
		fire.amount_ratio = intensity
		smoke.emitting = true
		smoke.amount_ratio = intensity
	else:
		fire.emitting = false
		smoke.emitting = false

func _on_damage(hp: float, max_hp: float):
	intensity = clamp(1.0 - hp / (max_hp * show_damage_hp), 0, 1)
