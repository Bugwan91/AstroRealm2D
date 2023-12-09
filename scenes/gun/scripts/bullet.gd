class_name Bullet
extends Node2D

@export var hit_effect_scene: PackedScene
@export var _color: Color

@onready var timer: Timer = %Timer
@onready var ray: RayCast2D = %RayCast2D
@onready var sprite = %Sprite
@onready var light = %Light

var linear_velocity: Vector2 = Vector2.ZERO

var impulse := 0.0
var speed := 0.0
var _damage := 10.0

func _ready():
	linear_velocity += transform.x * speed

func _physics_process(delta):
	position += linear_velocity * delta
	ray.target_position.y = speed * delta
	_collide()

func update_material(color: Color):
	_color = color
	sprite.modulate = _color * 2.0
	light.color = _color

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
	hit_effect.linear_velocity = target.absolute_velocity
	hit_effect.color = _color
	MainState.world_node.add_child(hit_effect)

func _self_destroy():
	queue_free()

func _create_damage() -> Damage:
	var damage = Damage.new()
	damage.amount = _damage
	damage.position = ray.get_collision_point()
	damage.impulse = transform.x * impulse
	return damage
