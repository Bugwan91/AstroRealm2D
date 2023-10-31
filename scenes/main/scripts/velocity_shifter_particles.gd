class_name VelocityShifterParticles
extends Node2D

@export var speed_multiplyer := 1.0
@export var speed_delta := 0.1
@export var particle: GPUParticles2D

var _material: ParticleProcessMaterial

func _ready():
	_material = particle.process_material.duplicate()
	particle.process_material = _material

func _process(_delta):
	global_rotation = 0.0
	var speed = FloatingOrigin.velocity.length()
	var direction = Vector3(
		-FloatingOrigin.velocity.x / speed,
		-FloatingOrigin.velocity.y / speed,
		0.0
	)
	speed = speed * speed_multiplyer
	_material.set("direction", direction)
	_material.set("initial_velocity_min", speed * (1.0 - speed_delta))
	_material.set("initial_velocity_max", speed * (1.0 + speed_delta))
