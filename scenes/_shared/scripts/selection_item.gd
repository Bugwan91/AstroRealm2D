class_name SelectionItem
extends Area2D

var item: Node2D

func _ready():
	input_event.connect(_selected)
	item = get_parent()

func _selected(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		MainState.player_target = self

func canvas_position() -> Vector2:
	return get_global_transform_with_canvas().origin
