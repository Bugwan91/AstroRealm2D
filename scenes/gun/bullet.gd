class_name Bullet
extends Node2D

@onready var timer: Timer = %Timer
@onready var ray: RayCast2D = %RayCast2D

@export var hit_effect_scene: PackedScene

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
		var hit_effect = hit_effect_scene.instantiate() as BulletHitEffect
		hit_effect.position = ray.get_collision_point()
		hit_effect.velocity = velocity
		get_parent().add_child(hit_effect)
		_self_destroy()

func _self_destroy():
	queue_free()
