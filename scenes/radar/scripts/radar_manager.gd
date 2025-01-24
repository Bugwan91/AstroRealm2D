class_name RadarManager
extends Node

signal radar_changed(radar: Radar)
signal selected(item: RadarItem)

var radar: Radar: set = _connect_radar
var radar_view: RadarViewport: set = _connect_view

var _view_scale: float
var _selected_item: RadarItem: set = _set_selected
var _default_selection_icon: RadarIcon = RadarIcon.create(
	load("res://scenes/radar/_res/icons/selection_icon.tres"))

func update_icons():
	if not is_instance_valid(radar): return
	for item in radar._items:
		_update_icon_position(item, item.icon)
		_update_selected_icon(item)

func is_selected(item: RadarItem) -> bool:
	return item == _selected_item

func _connect_radar(value: Radar):
	radar = value
	if radar == null:
		radar_view.visible = false
		return
	radar_view.visible = true
	radar.radius_updated.connect(_update_view_scale)
	radar.detected.connect(_on_detect)
	radar.undetected.connect(_on_exit)
	radar.selected.connect(_on_select)
	radar.unselected.connect(_on_unselect)
	radar.tree_exiting.connect(_on_radar_destroy)
	radar_changed.emit(value)
	_update_view_scale()

func _connect_view(value: RadarViewport):
	radar_view = value
	_update_view_scale()

func _on_detect(item: RadarItem):
	radar_view.add_icon(item.icon)

func _on_exit(item: RadarItem):
	radar_view.remove_icon(item.icon)
	reselect(item)

func _on_select(item: RadarItem):
	reselect(_selected_item, item)

func _on_unselect(item: RadarItem):
	reselect(item)

func _update_icon_position(item: RadarItem, icon: RadarIcon):
	icon.update(
		item.global_position - radar.global_position,
		item.global_rotation,
		radar_view.radius,
		_view_scale,
		0.1)
		#radar_view._scale)

func _update_view_scale():
	if is_instance_valid(radar) and is_instance_valid(radar_view):
		_view_scale = radar_view.radius / radar.radius

func _set_selected(item: RadarItem = null):
	_selected_item = item
	selected.emit(item)

func reselect(item: RadarItem = null, new_item: RadarItem = null):
	if item == _selected_item: item = null
	if item == null: _reselect_current(new_item)

func _reselect_current(item: RadarItem = null):
	_remove_selected_icon(_selected_item)
	_selected_item = item
	if is_instance_valid(_selected_item):
		_add_selected_icon(_selected_item)

func _get_selection_icon(item: RadarItem) -> RadarIcon:
	if is_instance_valid(item):
		if is_instance_valid(item.selected_icon):
			return item.selected_icon
		else:
			return _default_selection_icon
	return null

func _add_selected_icon(item: RadarItem):
	var icon := _get_selection_icon(item)
	if is_instance_valid(icon):
		radar_view.add_icon(icon)

func _remove_selected_icon(item: RadarItem):
	var icon := _get_selection_icon(item)
	if is_instance_valid(icon):
		radar_view.remove_icon(icon)

func _update_selected_icon(item: RadarItem):
	if not item == _selected_item: return
	var icon := _get_selection_icon(item)
	if is_instance_valid(icon):
		_update_icon_position(item, icon)

func _on_radar_destroy():
	reselect()
	radar_view.reset()
	radar = null
