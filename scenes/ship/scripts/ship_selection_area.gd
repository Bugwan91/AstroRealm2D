extends Area2D

@onready var _main_state: MainState = get_node("/root/MainState")

func _ready():
	input_event.connect(_selected)

func _selected(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		MainState.player_target = owner
