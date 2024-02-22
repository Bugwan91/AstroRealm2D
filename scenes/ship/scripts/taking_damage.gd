class_name TakingDamage
extends Area2D

var health: Health

@onready var polygon: CollisionPolygon2D = %Polygon

func setup(_health: Health, polygon_data: PackedVector2Array):
	health = _health
	polygon.polygon = polygon_data

func check_group(group: String) -> bool:
	return owner.group == group

func damage(damage: Damage):
	if is_instance_valid(health):
		health.damage(damage.amount)
		owner._on_inpulse(damage.impulse)
		owner.got_hit.emit(damage.impulse)
