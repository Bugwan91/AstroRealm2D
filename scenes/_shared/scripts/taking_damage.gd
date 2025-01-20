class_name TakingDamage
extends Area2D

@export var health: Health
@export var keep_on_destroy: bool = false
@export var _hit_effect_scene: PackedScene
@export var _damaged_effect_scene: PackedScene
@export_range(0, 1) var _damaged_effect_threshold: float = 0.3
@export var _destroy_effect_scene: PackedScene

@onready var parent: Node2D = get_parent()

var linear_velocity: Vector2:
	get:
		if parent is RigidBody2D\
			or parent is KineticBody:
			return parent.linear_velocity
		return Vector2.ZERO

var _damaged_effect: DamageEffect

var parent_visual_node: Node2D:
	get:
		return parent.extrapolator  if parent is RigidBody2D else parent

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

func reset():
	health.reset()
	_get_damage_effect().intensity = 0.0

func _apply_impulse(damage: Damage):
	if parent is RigidBody2D: parent.apply_central_impulse(damage.impulse)

func _apply_hit_effetcs(damage: Damage, effect: BulletHitEffect):
	effect.position = (damage.position - global_position).rotated(-global_rotation)
	parent_visual_node.add_child(effect)

func _handle_damage_effect():
	var intensity = clamp(1.0 - health.health / (health.max_health * _damaged_effect_threshold), 0, 1)
	if intensity > 0.0:
		_get_damage_effect().intensity = intensity

func _handle_death():
	if health.is_dead:
		_handle_death_effect()
		# HACK: create debris instead
		if keep_on_destroy:
			MainState.main_scene.remove_child(parent)
		else:
			parent.queue_free()

func _get_damage_effect():
	if not is_instance_valid(_damaged_effect):
		_damaged_effect = _damaged_effect_scene.instantiate()
		parent_visual_node.add_child(_damaged_effect)
	return _damaged_effect

func _handle_death_effect():
	var effect: ShipDestroyEffect = _destroy_effect_scene.instantiate()
	effect.position = parent.global_position
	effect.linear_velocity = linear_velocity
	MainState.main_scene.add_child(effect)
