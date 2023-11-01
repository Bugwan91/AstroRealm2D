extends Node2D

@onready var initial = %Initial
@onready var smoke = %Smoke
@onready var fire = %Fire

func _ready():
	FloatingOrigin.add(self)
	initial.emitting = true
	smoke.emitting = true
	fire.emitting = true
	smoke.finished.connect(_destroy)

func _destroy():
	queue_free()
