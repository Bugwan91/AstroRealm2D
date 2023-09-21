extends Label

@onready var _main_state = get_node("/root/MainState")

func _ready():
	text = "Acceleration"

func _process(delta):
	text = "A: " + str(_main_state.ship_acceleration).pad_decimals(0)
