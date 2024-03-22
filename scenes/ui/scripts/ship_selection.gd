class_name ShipSelectionUI
extends CanvasLayer

@onready var pivot: Control = %Pivot
@onready var selection: TextureRect = %Selection

var _selected_ship: Spaceship:
	set(value):
		_selected_ship = value
		selection.visible = _selected_ship != null

func _ready():
	process_priority = 999
	selection.visible = false
	MainState.player_target_updated.connect(_target_updated)

func _process(_delta):
	if not selection.visible or _selected_ship == null: return
	var viewport = Vector2(get_viewport().get_size()) * 0.5
	var position = _selected_ship.canvas_position - viewport
	position = Vector2(
		min(abs(position.x * min(abs(viewport.y / position.y), 1.0)), viewport.x) * sign(position.x),
		min(abs(position.y * min(abs(viewport.x / position.x), 1.0)), viewport.y) * sign(position.y)
	)
	pivot.position = position + viewport
	pivot.scale = 1.5 * get_viewport().get_camera_2d().zoom

func _target_updated(target: Spaceship):
	_selected_ship = target
