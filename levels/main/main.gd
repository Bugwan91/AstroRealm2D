extends Node2D

@export var ship_scene: PackedScene
@onready var player = %Player

func _ready():
	player.add_child(ship_scene.instantiate())
