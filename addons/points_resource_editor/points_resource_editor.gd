@tool
extends EditorPlugin

const CURSOR_THRESHOLD := 6.0

const POINT_RADIUS := 6.0

const POINT_COLOR := Color(1.0, 1.0, 0.0, 0.5)

const POINT_HOVER_COLOR := Color(1.0, 1.0, 1.0)

const ARROW_COLOR := Color(1.0, 0.5, 0.0, 0.5)


var _editable: PointsArrayResource
var _transform_to_view: Transform2D
var _transform_to_base: Transform2D
var _cursor: Vector2
var _index: int = -1

var _is_dragging := false
var _drag_from: Vector2
var _drag_to: Vector2

var _is_rotating := false
var _rotate_from: float
var _rotate_to: float


func _edit(object):
	_editable = object
	if not is_instance_valid(_editable):
		_index = -1
		_is_dragging = false
		_is_rotating = false


func _handles(object):
	return object is PointsArrayResource


func _make_visible(visible: bool):
	update_overlays()


func _forward_canvas_draw_over_viewport(overlay: Control):
	if not is_instance_valid(_editable):
		return
	_update_transforms()
	for index in range(0, _editable.points.size()):
		_draw_arrow(overlay, index)
		_draw_point(overlay, index)


func _forward_canvas_gui_input(event) -> bool:
	if not is_instance_valid(_editable):
		return false
	var handled := _handle_mouse_move(event)\
		or _handle_left_click(event)\
		or _handle_right_click(event)
	if handled: update_overlays()
	return handled


func _handle_left_click(event) -> bool:
	if event is InputEventMouseButton\
			and event.button_index == MOUSE_BUTTON_LEFT:
		if _index != -1 and event.is_pressed():
			_start_drag()
			return true
		elif event.is_released():
			_end_drag()
			return true
	return false


func _handle_right_click(event) -> bool:
	if event is InputEventMouseButton\
			and event.button_index == MOUSE_BUTTON_RIGHT:
		if _index != -1 and event.is_pressed():
			_start_rotating()
			return true
		elif event.is_released():
			_stop_rotating()
			return true
	return false

func _handle_mouse_move(event) -> bool:
	if event is InputEventMouseMotion:
		_cursor = event.position
		if _is_dragging:
			_drag()
			return true
		elif _is_rotating:
			_rotate()
			return true
		else:
			var previous_index := _index
			_index = _hovered_index()
			return previous_index == _index
	return false


func _hovered_index() -> int:
	for index in range(0, _editable.points.size()):
		if (_cursor - _transform_to_view * _editable.position(index)).length() < CURSOR_THRESHOLD:
			return index
	return -1

func _start_drag():
	_is_dragging = true
	_drag_from = _editable.position(_index)

func _end_drag():
	_is_dragging = false
	_drag_to = (_transform_to_base * _cursor).round()
	if _drag_to != _drag_from:
		var undo := get_undo_redo()
		undo.create_action("Drag point")
		undo.add_do_method(_editable, "move", _index, _drag_to)
		undo.add_undo_method(_editable, "move", _index, _drag_from)
		undo.commit_action()

func _drag():
	_editable.move(_index, (_transform_to_base * _cursor).round())

func _start_rotating():
	_is_rotating = true
	_rotate_from = _editable.rotation(_index)

func _stop_rotating():
	_is_rotating = false
	_rotate_to = ((_transform_to_base * _cursor) - _editable.position(_index)).angle()
	_rotate_to += _transform_to_base.get_rotation()
	_rotate_to = roundf(rad_to_deg(_rotate_to))
	if _rotate_from != _rotate_to:
		var undo = get_undo_redo()
		undo.create_action("Rotate point")
		undo.add_do_method(_editable, "rotate", _index, _rotate_to)
		undo.add_undo_method(_editable, "rotate", _index, _rotate_from)
		undo.commit_action()

func _rotate():
	var rotation = ((_transform_to_base * _cursor) - _editable.position(_index)).angle()
	rotation += _transform_to_base.get_rotation()
	rotation = roundf(rad_to_deg(rotation))
	_editable.rotate(_index, rotation)

func _draw_point(overlay: Control, index: int):
	var position = _transform_to_view * _editable.position(index)
	overlay.draw_circle(position, POINT_RADIUS, POINT_COLOR)
	if index == _index:
		overlay.draw_circle(position, POINT_RADIUS - 1.0, POINT_HOVER_COLOR)
	if index == _index and _is_rotating:
		var rotation := _editable.rotation(index) + _transform_to_view.get_rotation()
		overlay.draw_string(overlay.get_theme_font("font"),\
			position + Vector2(-16.0, -16.0), str(rotation), 1, 64.0, 16, Color.RED)
	else:
		overlay.draw_string(overlay.get_theme_font("font"),\
			position + Vector2(-16.0, -16.0), str(index), 1, 64.0)


func _draw_arrow(overlay: Control, index: int):
	var position := _transform_to_view * _editable.position(index)
	var rotation := _editable.rotation(index) + _transform_to_view.get_rotation()
	rotation = deg_to_rad(rotation)
	var top := Vector2(32.0, 0.0).rotated(rotation) + position
	var left := Vector2(0.0, -6.0).rotated(rotation) + position
	var right := Vector2(0.0, 6.0).rotated(rotation) + position
	overlay.draw_colored_polygon(PackedVector2Array([top, right, left]), ARROW_COLOR)

## Get transform of parent node of the editable resource and updates transforms from/to view
func _update_transforms():
	var node: Node2D = _editable.get_local_scene() as Node2D
	var transform_viewport := node.get_viewport_transform()
	var transform_canvas := node.get_canvas_transform()
	var transform_local := node.transform
	_transform_to_view = transform_viewport * transform_canvas * transform_local
	_transform_to_base = _transform_to_view.affine_inverse()
