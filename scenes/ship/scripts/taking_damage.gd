class_name TakingDamage
extends Node

@onready var health: Health = get_node("../Health")

func damage(damage: Damage):
	if is_instance_valid(health):
		health.damage(damage.amount)
		owner.had_hit.emit(damage.impulse)
