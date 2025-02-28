class_name Backgroung
extends Node2D

var _layers: Array[BackgroundLayer]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for layer in get_children():
		if layer is BackgroundLayer:
			_layers.append(layer)
	_setup_z_indexes_for_layers()
	CameraController.instance.updated.connect(_on_camera_updated)

func _on_camera_updated(pos: Vector2, zoom: float):
	position = pos

func _setup_z_indexes_for_layers() -> void:
	var dict: Dictionary [float, BackgroundLayer] = {}
	for layer in _layers:
		dict[layer.distance] = layer
	dict.sort()
	var i := 0
	for layer in dict:
		dict[layer].z_index = -i
		i += 1
