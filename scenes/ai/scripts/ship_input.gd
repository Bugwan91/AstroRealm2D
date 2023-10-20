class_name AIShipInput
extends ShipInput

@export var ship: ShipRigidBody
@export var player: ShipRigidBody

func _ready():
	ship.flight_assistant.target_body = player
	ship.battle_assistant.target = player
	ship.flight_assistant.enabled = true
	ship.flight_assistant._is_follow = true
	ship.battle_assistant._is_auto_aim = true
	ship.battle_assistant.is_auto_shoot = true
	player.set_target(ship)

func _process(_delta):
	fire.emit(true)
