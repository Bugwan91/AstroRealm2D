class_name RadarViewport
extends SubViewport

var radar: Radar

var _items := {}

func _ready():
	MainState.radar_updated.connect(_radar_updated)

func _physics_process(_delta):
	if not is_instance_valid(radar): return
	for item in _items:
		_items[item].position = Vector2.ONE * 256.0 + item.position * 256.0 / radar.radius
		_items[item].rotation = item.rotation

func _radar_updated(value: Radar):
	_items.clear()
	radar = value
	radar.body_entered.connect(_radar_entered)
	radar.body_exited.connect(_radar_exited)

func _radar_entered(item):
	var point = Sprite2D.new()
	point.texture = item.radar_icon
	point.modulate = item.radar_color
	point.scale = Vector2.ONE * 0.3
	point.position = Vector2.ONE * 256.0 + item.position * 256.0 / radar.radius
	point.rotation = item.rotation
	_items[item] = point
	add_child(point)

func _radar_exited(item):
	remove_child(_items[item])
	_items.erase(item)
