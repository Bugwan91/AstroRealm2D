class_name TakingDamage
extends Area2D

@export var health: Health

@onready var body: FloatingOriginBody = get_parent()

func _ready():
	monitoring = false

func setup_polygon(hp: Health, polygon_data: PackedVector2Array):
	health = hp
	var polygon := CollisionPolygon2D.new()
	polygon.polygon = polygon_data
	add_child(polygon)

func check_group(group: String) -> bool:
	return body.is_in_group(group)

func damage(damage: Damage):
	if is_instance_valid(health):
		health.damage(damage.amount)
		body.apply_impulse(damage.impulse)
		body.got_hit.emit(damage.impulse)
