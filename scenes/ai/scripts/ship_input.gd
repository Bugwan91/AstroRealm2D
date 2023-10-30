class_name AIShipInput
extends ShipInput

@export var agressive := false
@export var keep_distance := 500.0

@onready var ship: ShipRigidBody = get_parent()
var player: ShipRigidBody

func _ready():
	MainState.player_ship_updated.connect(_on_update_player_ship)

func _process(_delta):
	ship.flight_assistant.is_follow = true
	ship.flight_assistant.follow_distance = keep_distance
	ship.battle_assistant._is_auto_aim = true
	ship.battle_assistant.is_auto_shoot = agressive

func _on_update_player_ship(player_ship: ShipRigidBody):
	player = player_ship
	ship.flight_assistant.target = player
	ship.battle_assistant.target = player
