extends Node2D

@export var ship_scene: PackedScene

func _ready():
	add_child(ship_scene.instantiate())
