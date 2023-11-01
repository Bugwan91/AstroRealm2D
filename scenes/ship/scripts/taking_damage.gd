class_name TakingDamage
extends Node

var health: Health

func damage(damage: Damage):
	if is_instance_valid(health):
		health.damage(damage.amount)
		owner.got_hit.emit(damage.impulse)
