class_name TakingDamage
extends Area2D

@export var health: Health
@export var _hit_effect_scene: PackedScene
@export var _damaged_effect_scene: PackedScene
@export_range(0, 1) var _damaged_effect_threshold: float = 0.3
@export var _destroy_effect_scene: PackedScene

@onready var _parent: Node2D = get_parent()

var _damaged_effect: DamageEffect

func _ready():
	monitoring = false
	collision_layer = 3

func setup_health(value: float):
	health.max_health = value

func setup_polygon(hp: Health, polygon_data: PackedVector2Array):
	health = hp
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = polygon_data
	add_child(polygon)

func damage(damage: Damage, effect: BulletHitEffect):
	if not is_instance_valid(health): return
	health.damage(damage.amount)
	_apply_impulse(damage)
	_apply_hit_effetcs(damage, effect)
	_handle_damage_effect()
	_handle_death()

func _apply_impulse(damage: Damage):
	if _parent is RigidBody2D: _parent.apply_impulse(damage.impulse, damage.position)

func _apply_hit_effetcs(damage: Damage, effect: BulletHitEffect):
	effect.position = damage.position
	effect.velocity = _get_velocity()
	MainState.main_scene.add_child(effect)

func _handle_damage_effect():
	var intensity = clamp(1.0 - health.health / (health.max_health * _damaged_effect_threshold), 0, 1)
	if intensity > 0.0:
		_get_damage_effect().intensity = intensity

func _get_velocity() -> Vector2:
	if _parent is RigidBody2D: return _parent.linear_velocity
	if _parent is KineticBody: return _parent.velocity
	return Vector2.ZERO

func _handle_death():
	if health.is_dead:
		_handle_death_effect()
		# TODO: create debris instead
		_parent.queue_free()

func _get_damage_effect():
	if not is_instance_valid(_damaged_effect):
		_damaged_effect = _damaged_effect_scene.instantiate()
		add_child(_damaged_effect)
	return _damaged_effect

func _handle_death_effect():
	var effect: ShipDestroyEffect = _destroy_effect_scene.instantiate()
	effect.position = _parent.global_position
	effect.velocity = _get_velocity()
	MainState.main_scene.add_child(effect)
