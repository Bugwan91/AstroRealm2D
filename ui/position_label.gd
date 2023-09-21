extends Label

@onready var _main_state = get_node("/root/MainState")

func _ready():
	text = "Position"

func _process(delta):
	text = "X: " + str(_main_state.ship_position.x).pad_decimals(0) + "\nY: " + str(_main_state.ship_position.y).pad_decimals(0)
