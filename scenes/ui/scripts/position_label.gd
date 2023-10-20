extends Label

@onready var _main_state = get_node("/root/MainState")

func _ready():
	text = "Position"

func _process(_delta):
	text = "x: " + str(_main_state.ship_position.x).pad_decimals(0) + "\ny: " + str(_main_state.ship_position.y).pad_decimals(0)
