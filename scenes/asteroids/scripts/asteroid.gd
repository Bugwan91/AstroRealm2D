class_name Asteroid
extends RigidBody

@export var size: float
@export var health: float = 500.0
@export var variants: Array[CanvasTexture]

@onready var _view: Sprite2D = %View
@onready var _collider: CollisionShape2D = %CollisionShape2D
@onready var _damage_collider: CollisionShape2D = %DamageCollisionShape2D
@onready var _taking_damage: TakingDamage = %TakingDamage
@onready var _radar_icon: RadarItem = %RadarItem

var _base_radius := 64
var _base_mass := 5.0

func _ready() -> void:
	mass = sqrt(size) * _base_mass
	_view.scale = Vector2(size, size)
	var shape := CircleShape2D.new()
	shape.radius = size * _base_radius
	_collider.shape = shape
	_damage_collider.shape = shape
	_taking_damage.setup_health(health * size)
	_radar_icon.icon_scale *= size
	_set_variant()

func _set_variant():
	_view.texture = variants.pick_random()
