class_name Bullet
extends Node2D

@onready var timer: Timer = %Timer
@onready var ray: RayCast2D = %RayCast2D
@onready var particles: GPUParticles2D = %GPUParticles2D

@export var hit_effect_scene: PackedScene

var linear_velocity: Vector2 = Vector2.ZERO

var impulse := 0.0
var speed := 0.0
var hit_material: ParticleProcessMaterial

func _ready():
	FloatingOrigin.add(self)
	linear_velocity += transform.x * speed

func _process(delta):
	position += linear_velocity * delta

func _physics_process(delta):
	ray.target_position.y = speed * delta
	_collide()

func update_material(mat: ParticleProcessMaterial, hit_mat: ParticleProcessMaterial):
	particles.process_material = mat
	hit_material = hit_mat

func start(lifetime: float):
	timer.timeout.connect(_self_destroy)
	timer.start(lifetime)

func _collide():
	if ray.is_colliding():
		var hit_effect = hit_effect_scene.instantiate() as BulletHitEffect
		hit_effect.position = ray.get_collision_point()
		var target = ray.get_collider()
		if "linear_velocity" in target:
			hit_effect.linear_velocity = target.real_velocity
		get_parent().add_child(hit_effect)
		hit_effect.update_material(hit_material)
		_self_destroy()

func _self_destroy():
	queue_free()
