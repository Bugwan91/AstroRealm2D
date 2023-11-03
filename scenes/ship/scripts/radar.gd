class_name Radar
extends Area2D

@export var radius: float

@onready var covering_shape = %CoveringShape

#TODO: store detected objects here
# use area entered and exited for updated detected objects list

func _ready():
	_set_radius()
	MainState.player_radar = self

func _set_radius(value: float = 10000.0):
	radius = value
	covering_shape.shape.radius = radius

