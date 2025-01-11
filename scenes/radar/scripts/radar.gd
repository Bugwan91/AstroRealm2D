class_name Radar
extends Area2D

signal radius_updated(new_radius: float)

signal detected(item: RadarItem)
signal undetected(item: RadarItem)

signal selected(item: RadarItem)
signal unselected(item: RadarItem)

@export var radius: float: set = _set_radius

@onready var covering_shape: CollisionShape2D = %CoveringShape

var _items: Array[RadarItem] = []

func _ready():
	monitorable = false
	collision_layer = 8
	collision_mask = 8
	area_entered.connect(_radar_entered)
	area_exited.connect(_radar_exited)
	_setup_shape()
	MainState.radar_manager.radar = self

func _set_radius(value: float = 10000.0):
	radius = value
	_setup_shape()
	radius_updated.emit(radius)

func _setup_shape():
	if is_instance_valid(covering_shape):
		covering_shape.shape.radius = radius

func _radar_entered(item: Area2D):
	if not item is RadarItem: return
	var itm := item as RadarItem
	_items.append(itm)
	itm.selected.connect(_on_select)
	itm.unselected.connect(_on_unselect)
	itm.destruction_handler = _radar_exited
	itm.connect_on_destroy()
	detected.emit(item)

func _radar_exited(item: Area2D):
	if not item is RadarItem: return
	var itm := item as RadarItem
	itm.selected.disconnect(_on_select)
	itm.unselected.disconnect(_on_unselect)
	itm.disconnect_on_destroy()
	_items.erase(item)
	undetected.emit(item)

func _on_select(item: RadarItem):
	selected.emit(item)

func _on_unselect(item: RadarItem):
	unselected.emit(item)
