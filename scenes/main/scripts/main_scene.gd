class_name MainScene
extends Node2D

@onready var world: Node2D = %World
var ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")

func _ready() -> void:
	process_physics_priority = -1001
	MainState.world_root = world
	MainState.main_scene = self
	pause()

func _physics_process(delta: float) -> void:
	MainState.last_delta = delta

func pause(value: bool = true) -> void:
	get_tree().paused = value

func exit_game() -> void:
	get_tree().quit()
