class_name AIShipInput
extends ShipInput

@export var player: ShipRigidBody
@export var agressive := false
@export var keep_distance := 500.0

@onready var ship: ShipRigidBody = get_parent()

func _ready():
	ship.flight_assistant.target_body = player
	ship.battle_assistant.target = player
	ship.flight_assistant.is_follow = true
	ship.flight_assistant.follow_distance = keep_distance
	ship.battle_assistant._is_auto_aim = true
	ship.battle_assistant.is_auto_shoot = agressive

var _strafe := Vector2.ZERO

func _process(_delta):
	if (player.position - ship.position).length() < 0.9 * keep_distance:
		if _strafe.y == 0:
			_strafe.y = (randf() - 0.5) * 5
	else:
		_strafe = Vector2.ZERO
	strafe.emit(_strafe)
