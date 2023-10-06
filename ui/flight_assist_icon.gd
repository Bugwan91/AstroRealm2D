extends TextureRect

@onready var _main_state = get_node("/root/MainState")

func _ready():
	visible = false

func _process(_delta):
	visible = _main_state.flight_assist
