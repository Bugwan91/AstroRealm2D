class_name AIAllyShipInput
extends ShipInput

@export var player: ShipRigidBody
@export var agressive := false
@export var keep_distance := 500.0

@onready var ship: ShipRigidBody = get_parent()

func _ready():
	ship.flight_assistant.target_body = player
	ship.flight_assistant.is_follow = true
	ship.flight_assistant.follow_distance = keep_distance

var _strafe := Vector2.ZERO

func _process(_delta):
	ship.flight_assistant.direction = player.flight_assistant.direction
	ship.battle_assistant.gun._is_firing = player.battle_assistant.gun._is_firing
