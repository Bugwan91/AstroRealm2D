class_name BTPlayerShip
extends BTPlayer

@export var controlled_ship: Spaceship
var _target: Spaceship

func on_player_spawned(value: Spaceship) -> void:
	_target = value
	if is_instance_valid(_target):
		blackboard.set_parent(_target.get_blackboard())
	else:
		blackboard.set_parent(null)
