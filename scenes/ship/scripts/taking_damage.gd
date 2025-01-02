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

func damage(damage: Damage):
	# TODO: fix this with correct implementation of ship physics
	if not is_instance_valid(health): return
	var is_dead = is_zero_approx(health.damage(damage.amount))
	if _parent is RigidBody2D:
		(_parent as RigidBody2D).apply_central_impulse(damage.impulse) # TODO: fix
	#body.got_hit.emit(damage.impulse)
	if is_dead:
		_parent.queue_free()
