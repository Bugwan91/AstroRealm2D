class_name AIShipInput
extends ShipInput

@export var agressive := false
@export var keep_distance := 500.0

var _ship: ShipRigidBody
var _player: ShipRigidBody


func init(ship: ShipRigidBody):
	_ship = ship
	MainState.player_ship_updated.connect(_on_update_player_ship)
	_ship.flight_assistant.is_turn_enabled = false


func _on_update_player_ship(player_ship: ShipRigidBody):
	_player = player_ship
	if not is_instance_valid(_player):
		_ship.flight_assistant.is_follow = false
		_ship.battle_assistant._is_auto_aim = false
		return
	_ship.flight_assistant.target = _player
	_ship.battle_assistant.target = _player
	_ship.flight_assistant.is_follow = true
	_ship.flight_assistant.is_turn_enabled = true
	_ship.flight_assistant.follow_distance = keep_distance
	_ship.battle_assistant._is_auto_aim = true
	_ship.battle_assistant.is_auto_shoot = agressive

