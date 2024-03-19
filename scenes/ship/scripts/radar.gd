class_name Radar
extends Area2D

@export var radius: float: set = _set_radius

@onready var covering_shape: CollisionShape2D = %CoveringShape

#TODO: store detected objects here
# use area entered and exited for updated detected objects list

func _ready():
	_set_radius()
	monitorable = false
	collision_layer = 8
	collision_mask = 8
	MainState.player_radar = self

func _set_radius(value: float = 10000.0):
	radius = value
	covering_shape.shape.radius = radius

