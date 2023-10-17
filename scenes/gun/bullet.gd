class_name Bullet
extends Node2D

@onready var timer: Timer = %Timer
@onready var ray: RayCast2D = %RayCast2D
@onready var hit_particles = $GPUParticles2D

@export var hit_effect: PackedScene

var velocity: Vector2 = Vector2.ZERO

var impulse := 0.0
var speed := 0.0

func _ready():
	velocity += global_transform.x * speed

func _physics_process(delta):
	_collide()
	position += velocity * delta
	ray.target_position.y = speed * delta

func start(lifetime: float):
	timer.timeout.connect(_self_destroy)
	timer.start(lifetime)

func _collide():
	if ray.is_colliding():
		var hit = hit_effect.instantiate() as BulletHitEffect
		hit.position = ray.get_collision_point()
		hit.velocity = velocity
		get_parent().add_child(hit)
		_self_destroy()

func _self_destroy():
	queue_free()

func _check_collision(delta: float):
	pass
	#ray.
