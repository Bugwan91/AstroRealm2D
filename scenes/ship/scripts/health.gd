class_name Health
extends Resource

signal damaged(health: float, max: float)
signal dying

@export_range(0, 1000000) var max_health: = 1000.0:
	set(value):
		max_health = value if value > 0.0 else 0.0 
		health = max_health

var health: float

func _ready():
	health = max_health

func damage(damage: float):
	health = max(0.0, health - damage)
	damaged.emit(health, max_health)
	if health <= 0.0:
		dying.emit()
