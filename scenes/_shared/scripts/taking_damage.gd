class_name TakingDamage
extends Area2D

signal damaged(value: Damage)
signal destroyed()

@export var is_main_hp: bool = false
@export_range(0, 1000000) var hp_max: = 1000.0:
	set(value):
		hp_max = value if value > 0.0 else 0.0 
		reset()
@export var keep_on_destroy: bool = false
# FIXME: use this internal hit effect on taking damage
@export var _hit_effect_scene: PackedScene
@export var _damaged_effect_scene: PackedScene
@export_range(0, 1) var _damaged_effect_threshold: float = 0.3
@export var _destroy_effect_scene: PackedScene

@onready var parent: Node2D = get_parent()

var hp: float
var hp_percentage: float:
	get: return hp / hp_max

var linear_velocity: Vector2:
	get:
		if parent is RigidBody2D\
			or parent is KineticBody:
			return parent.linear_velocity
		return Vector2.ZERO

var is_dead: bool:
	get: return is_zero_approx(hp)

var _damaged_effect: DamageEffect

var parent_visual_node: Node2D:
	get:
		return parent.extrapolator if parent is RigidBody2D else parent

func _ready() -> void:
	monitoring = false
	collision_layer = 3
	hp = hp_max

func set_health(value: float) -> void:
	hp_max = value

func setup_polygon(health: float, polygon_data: PackedVector2Array) -> void:
	set_health(health)
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = polygon_data
	add_child(polygon)

func damage(_damage: Damage, effect: BulletHitEffect = null) -> void:
	hp = max(0.0, hp - _damage.amount)
	damaged.emit(_damage)
	_apply_impulse(_damage)
	_apply_hit_effetcs(_damage, effect)
	_handle_damage_effect()
	_handle_death()

func reset() -> void:
	hp = hp_max
	_get_damaged_effect().intensity = 0.0

func _apply_impulse(_damage: Damage) -> void:
	if parent is RigidBody2D: parent.apply_central_impulse(_damage.impulse)

func _apply_hit_effetcs(_damage: Damage, effect: BulletHitEffect = null) -> void:
	if is_instance_valid(effect):
		effect.position = (_damage.position - global_position).rotated(-global_rotation)
		parent_visual_node.add_child(effect)

func _handle_damage_effect() -> void:
	var intensity: float = clamp(1.0 - hp / (hp_max * _damaged_effect_threshold), 0, 1)
	if intensity > 0.0:
		_get_damaged_effect().intensity = intensity

func _handle_death() -> void:
	if is_main_hp and is_dead:
		destroyed.emit()
		_handle_death_effect()
		# HACK: create debris instead
		if keep_on_destroy:
			# FIXME: Condition "p_child->data.parent != this" is true.
			if parent.get_parent() == WorldGridManager.instance.world_root:
				WorldGridManager.instance.world_root.remove_child(parent)
		else:
			parent.queue_free()

func _get_damaged_effect() -> DamageEffect:
	if not is_instance_valid(_damaged_effect):
		_damaged_effect = _damaged_effect_scene.instantiate()
		parent_visual_node.add_child(_damaged_effect)
	return _damaged_effect

func _handle_death_effect() -> void:
	var effect: ShipDestroyEffect = _destroy_effect_scene.instantiate()
	effect.position = parent.global_position
	effect.linear_velocity = linear_velocity
	WorldGridManager.instance.world_root.add_child(effect)
