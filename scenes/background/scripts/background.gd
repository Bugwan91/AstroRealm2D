class_name Backgroung
extends Node2D

#@export var items: Array[BackgroundObject]

@onready var layers_container: CanvasLayer = %Layers

var _camera: Camera2D
var _layers: Array[BackgroundLayer]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_camera = get_viewport().get_camera_2d()
	for layer in layers_container.get_children():
		if layer is BackgroundLayer:
			_layers.append(layer)
	_setup_z_indexes_for_layers()

func _process(_delta: float) -> void:
	var shift := _camera.position
	for layer in _layers:
		layer.shift(shift, _camera.zoom)

func _setup_z_indexes_for_layers() -> void:
	var dict: Dictionary [float, BackgroundLayer] = {}
	for layer in _layers:
		dict[layer.distance] = layer
	dict.sort()
	var i := 0
	for layer in dict:
		dict[layer].z_index = -i
		i += 1
