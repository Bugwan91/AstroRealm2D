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
	radar.area_entered.connect(_radar_entered)
	radar.area_exited.connect(_radar_exited)

func _radar_entered(item: Area2D):
	if not item is RadarItem: return
	_items.append(item)
	item.init()
	item.update(view_radius, radar.radius)
	add_child(item.icon)

func _radar_exited(item):
	if not item is RadarItem: return
	_items.erase(item)
	remove_child(item.icon)
	item.clear()
