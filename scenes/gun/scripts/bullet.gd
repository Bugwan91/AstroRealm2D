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
var _damage := 10.0

func _ready():
	FloatingOrigin.add(self)
	linear_velocity += transform.x * speed

func _process(delta):
	position += linear_velocity * delta

func _physics_process(delta):
	ray.target_position.y = speed * delta + 8.0
	_collide()

func update_material(mat: ParticleProcessMaterial, hit_mat: ParticleProcessMaterial):
	particles.process_material = mat
	hit_material = hit_mat

func start(lifetime: float):
	timer.timeout.connect(_self_destroy)
	timer.start(lifetime)

func _collide():
	if ray.is_colliding():
		_on_hit(ray.get_collider())
		_self_destroy()

func _on_hit(target):
	var damageTaker = target.get_node("TakingDamage") as TakingDamage
	if is_instance_valid(damageTaker):
		damageTaker.damage(_create_damage())
	var hit_effect = hit_effect_scene.instantiate() as BulletHitEffect
	hit_effect.position = ray.get_collision_point()
	hit_effect.linear_velocity = target.real_velocity
	get_parent().add_child(hit_effect)
	hit_effect.update_material(hit_material)

func _self_destroy():
	queue_free()

func _create_damage() -> Damage:
	var damage = Damage.new()
	damage.amount = _damage
	damage.position = ray.get_collision_point()
	damage.impulse = transform.x * 10.0
	return damage
