class_name Asteroid
extends StaticRigidBody

@export_range(0.1, 10.0) var size: float
@export var health: float = 500.0
@export var _base_mass := 5.0
@export var variants: Array[CanvasTexture]

@onready var _view: Sprite2D = %View
@onready var _collider: CollisionShape2D = %CollisionShape2D
@onready var _damage_collider: CollisionShape2D = %DamageCollisionShape2D
@onready var _taking_damage: TakingDamage = %TakingDamage
@onready var _radar: RadarItem = %RadarItem

var _base_radius := 64.0

var is_in_world := false

func _ready() -> void:
	super._ready()
	var shape := CircleShape2D.new()
	_collider.shape = shape
	_damage_collider.shape = shape
	_set_variant()

func _set_variant():
	_view.texture = variants.pick_random()

func init(
	size: float,
	vel: Vector2,
	speed: float,
	spd_variation: float,
	rot: float,
	rot_variation: float):
		reset()
		mass = _base_mass * size * size
		radius = size * _base_radius
		_collider.shape.radius = radius
		_damage_collider.shape.radius = radius
		_view.scale = Vector2(size, size)
		_taking_damage.setup_health(health * size)
		_radar.init_shape(radius)
		_radar.icon.setup_scale(size)
		var size_inv := 1.0 / size
		linear_velocity = vel + _rand_velocity(speed, spd_variation, size_inv)
		_l_v = linear_velocity
		angular_velocity = _rand_rotation(rot, rot_variation, size_inv)
		_a_v = angular_velocity

func reset():
	_radar.reset()
	_taking_damage.reset()

func _rand_velocity(speed: float, variation: float, size_inv: float) -> Vector2:
	return  (speed * size_inv * randf_range(1.0 - variation, 1.0 + variation) * Vector2.ONE).rotated(randf_range(-PI, PI))

func _rand_rotation(speed: float, variation: float, size_inv: float) -> float:
	return speed * size_inv * randf_range(-(1.0 + variation), 1.0 + variation)
	
