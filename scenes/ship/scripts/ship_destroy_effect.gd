class_name ShipDestroyEffect
extends Node2D

@onready var smoke: GPUParticles2D = %Smoke
@onready var fire = %Fire
@onready var sparcles = %Sparcles

func _ready():
	FloatingOrigin.add(self)
	smoke.emitting = true
	fire.emitting = true
	sparcles.emitting = true
	smoke.finished.connect(_destroy)

func _destroy():
	queue_free()
