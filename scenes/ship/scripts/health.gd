class_name Health
extends Node

signal damaged(health: float, max: float)
signal dying

@export_range(0, 1000000) var max_health: = 1000.0

var health: float

func _ready():
	health = max_health

func damage(damage: float):
	health = max(0.0, health - damage)
	damaged.emit(health, max_health)
	if health <= 0.0:
		dying.emit()
