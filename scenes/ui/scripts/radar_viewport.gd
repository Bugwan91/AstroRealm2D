class_name RadarViewport
extends Control

@export var view_radius := 256.0

var radar: Radar

var _items: Array[RadarItem] = []

func _ready():
	MainState.radar_updated.connect(_radar_updated)

func _physics_process(_delta):
	if not is_instance_valid(radar): return
	for item in _items:
		item.update(view_radius, radar.radius)

func _radar_updated(value: Radar):
	_items.clear()
	radar = value
	if not is_instance_valid(radar): return
	radar.body_entered.connect(_radar_entered)
	radar.body_exited.connect(_radar_exited)

func _radar_entered(detected_item: Node2D):
	var item: RadarItem = detected_item.get_node("RadarItem")
	if not is_instance_valid(item): return
	_items.append(item)
	item.init()
	item.update(view_radius, radar.radius)
	add_child(item.icon)

func _radar_exited(detected_item):
	var item: RadarItem = detected_item.get_node("RadarItem")
	if not is_instance_valid(item): return
	_items.erase(item)
	remove_child(item.icon)
	item.clear()
