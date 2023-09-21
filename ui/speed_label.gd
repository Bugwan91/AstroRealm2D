extends Label

@onready var _main_state = get_node("/root/MainState")

func _ready():
	text = "Speed"

func _process(delta):
	text = "Spd: " + str(_main_state.ship_speed).pad_decimals(0)
