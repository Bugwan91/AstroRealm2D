# HACK: Refactoring: rename to SelectionItemUI
class_name ShipSelectionUI
extends CanvasLayer

@onready var pivot: Control = %Pivot
@onready var container: Control = %Container

const MIN_SIZE := 32.0
const PADDING := 16.0

var _selected_target: RadarItem:
	set(value):
		_selected_target = value
		container.visible = _selected_target != null

func _ready() -> void:
	process_priority = 999
	container.visible = false
	MainState.radar_manager.selected.connect(_target_updated)

func _process(_delta: float) -> void:
	if not is_instance_valid(_selected_target): container.visible = false
	if not container.visible: return
	var viewport := Vector2(get_viewport().get_size()) * 0.5
	var position := _selected_target.canvas_position - viewport
	position = Vector2(
		min(abs(position.x * min(abs(viewport.y / position.y), 1.0)), viewport.x) * sign(position.x),
		min(abs(position.y * min(abs(viewport.x / position.x), 1.0)), viewport.y) * sign(position.y)
	)
	pivot.position = position + viewport
	_update_size()

func _target_updated(target: RadarItem = null) -> void:
	_selected_target = target

func _update_size() -> void:
	var zoom := get_viewport().get_camera_2d().zoom.x
	var icon_size: float = max(MIN_SIZE, _selected_target.selection_size * zoom) + PADDING
	var size_v := Vector2(icon_size, icon_size)
	pivot.size = size_v
	container.size = size_v
	container.position = -0.5 * size_v
