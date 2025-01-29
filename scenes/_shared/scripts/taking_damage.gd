class_name TakingDamage
extends Area2D

signal damaged(value: Damage)
signal destroyed()

@export var health: Health
@export var keep_on_destroy: bool = false
# FIXME: use this internal hit effect on taking damage
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

func _ready() -> void:
	monitoring = false
	collision_layer = 3

func setup_health(value: float) -> void:
	health.max_health = value

func setup_polygon(hp: Health, polygon_data: PackedVector2Array) -> void:
	health = hp
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = polygon_data
	add_child(polygon)

func damage(_damage: Damage, effect: BulletHitEffect = null) -> void:
	if not is_instance_valid(health): return
	damaged.emit(damage)
	health.damage(_damage.amount)
	_apply_impulse(_damage)
	_apply_hit_effetcs(_damage, effect)
	_handle_damage_effect()
	_handle_death()

func reset() -> void:
	health.reset()
	_get_damage_effect().intensity = 0.0

func _apply_impulse(_damage: Damage) -> void:
	if parent is RigidBody2D: parent.apply_central_impulse(_damage.impulse)

func _apply_hit_effetcs(_damage: Damage, effect: BulletHitEffect = null) -> void:
	if is_instance_valid(effect):
		effect.position = (_damage.position - global_position).rotated(-global_rotation)
		parent_visual_node.add_child(effect)

func _handle_damage_effect() -> void:
	var intensity: float = clamp(1.0 - health.health / (health.max_health * _damaged_effect_threshold), 0, 1)
	if intensity > 0.0:
		_get_damage_effect().intensity = intensity

func _handle_death() -> void:
	if health.is_dead:
		destroyed.emit()
		_handle_death_effect()
		# HACK: create debris instead
		if keep_on_destroy:
			# FIXME: Condition "p_child->data.parent != this" is true.
			if parent.get_parent() == WorldGridManager.instance.world_root:
				WorldGridManager.instance.world_root.remove_child(parent)
		else:
			parent.queue_free()

func _get_damage_effect() -> DamageEffect:
	if not is_instance_valid(_damaged_effect):
		_damaged_effect = _damaged_effect_scene.instantiate()
		parent_visual_node.add_child(_damaged_effect)
	return _damaged_effect

func _handle_death_effect() -> void:
	var effect: ShipDestroyEffect = _destroy_effect_scene.instantiate()
	effect.position = parent.global_position
	effect.linear_velocity = linear_velocity
	WorldGridManager.instance.world_root.add_child(effect)
