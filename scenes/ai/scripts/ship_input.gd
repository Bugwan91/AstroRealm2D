class_name AIShipInput
extends ShipInput

@export var agressive := false
@export var keep_distance := 500.0

var _ship: Spaceship
var _target: Spaceship


func init(ship: Spaceship):
	_ship = ship
	PlayerManager.instance.ship_spawned.connect(new_target_ship)
	PlayerManager.instance.ship_destroyed.connect(remove_target_ship)
	_ship.flight_assistant.is_turn_enabled = false

func new_target_ship(target_ship: Spaceship):
	_target = target_ship
	_ship.flight_assistant.target = _target
	_ship.battle_assistant.target = _target
	_ship.flight_assistant.is_follow = true
	_ship.flight_assistant.is_turn_enabled = true
	_ship.flight_assistant.follow_distance = keep_distance
	_ship.battle_assistant._is_auto_aim = true
	_ship.battle_assistant.is_auto_shoot = agressive

func remove_target_ship() -> void:
	_target = null
	_ship.flight_assistant.is_follow = false
	_ship.battle_assistant._is_auto_aim = false
