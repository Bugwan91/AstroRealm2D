class_name AIDummyShipInput
extends ShipInput

@export var player: Spaceship
@export var agressive := false

@onready var ship: Spaceship = get_parent()

func _ready():
	ship.flight_assistant.target_body = player
	ship.battle_assistant.target = player
	ship.battle_assistant._is_auto_aim = true
	ship.battle_assistant.is_auto_shoot = agressive
	ship.flight_assistant.is_autopilot = true
	ship.flight_assistant.autopilot_speed = 12000.0
	ship.flight_assistant.is_autopilot_stop = false

func _physics_process(delta):
	var target_position = ship.battle_assistant.shoot_point
	if (player.position - ship.position).length() < 300:
		ship.flight_assistant.is_autopilot = false
		data.target = target_position
	else:
		ship.flight_assistant.is_autopilot = true
		data.autopilot_target = ship.position + FloatingOrigin.origin + target_position
	data.strafe = Vector2(0.0, 0.5)
