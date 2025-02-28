class_name NPCShip
extends Spaceship

@onready var inputs: AIShipInput = %NPCShipInput
@onready var bt_player: BTPlayerShip = %BTPlayer

func _ready() -> void:
	super._ready()
	inputs.controlled_ship = self
	bt_player.controlled_ship = self
	setup_blackboard(bt_player.blackboard)
	MainState.player_ship_spawned.connect(bt_player.on_player_spawned)
