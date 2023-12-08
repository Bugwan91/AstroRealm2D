class_name Backgroung
extends Node2D

@onready var layers_container = %Layers

var _camera: Camera2D
var _layers: Array[BackgroundLayer]

func _ready():
	_camera = get_viewport().get_camera_2d()
	for layer in layers_container.get_children():
		if layer is BackgroundLayer:
			_layers.append(layer)

func _process(_delta):
	var shift = FloatingOrigin.absolute_position(_camera)
	for layer in _layers:
		layer.shift(shift, _camera.zoom)

