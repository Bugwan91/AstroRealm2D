class_name AIShipInput
extends ShipInput

@export var agressive := false
@export var keep_distance := 500.0

var _ship: Spaceship
var _target: Spaceship


func init(ship: Spaceship):
	_ship = ship
	_ship.dead.connect(_on_dead)
	MainState.player_ship_updated.connect(update_target_ship)
	_ship.flight_assistant.is_turn_enabled = false


func update_target_ship(target_ship: Spaceship):
	_target = target_ship
	if not is_instance_valid(_target):
		_ship.flight_assistant.is_follow = false
		_ship.battle_assistant._is_auto_aim = false
		return
	_ship.flight_assistant.target = _target
	_ship.battle_assistant.target = _target
	_ship.flight_assistant.is_follow = true
	_ship.flight_assistant.is_turn_enabled = true
	_ship.flight_assistant.follow_distance = keep_distance
	_ship.battle_assistant._is_auto_aim = true
	_ship.battle_assistant.is_auto_shoot = agressive

func _on_dead(_pass):
	MainState.player_ship_updated.disconnect(update_target_ship)
