class_name TakingDamage
extends Area2D

@export var health: Health

@onready var _parent: Node2D = get_parent()

func _ready():
	monitoring = false
	collision_layer = 3

func setup_polygon(hp: Health, polygon_data: PackedVector2Array):
	health = hp
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = polygon_data
	add_child(polygon)

func damage(damage: Damage, effect: BulletHitEffect):
	if not is_instance_valid(health): return
	var is_dead = is_zero_approx(health.damage(damage.amount))
	if _parent is RigidBody2D:
		(_parent as RigidBody2D).apply_central_impulse(damage.impulse) # TODO: fix
	_handle_hit_effetcs(damage, effect)
	if is_dead:
		_parent.queue_free()

func _handle_hit_effetcs(damage: Damage, hit_effect: BulletHitEffect):
	hit_effect.position = damage.position
	var velocity := Vector2.ZERO
	if _parent is RigidBody2D: hit_effect.velocity = _parent.linear_velocity
	if _parent is KineticBody: hit_effect.velocity = _parent.velocity
	MainState.main_scene.add_child(hit_effect)
