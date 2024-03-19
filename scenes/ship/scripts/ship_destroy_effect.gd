class_name ShipDestroyEffect
extends Node2D

@onready var smoke: GPUParticles2D = %Smoke
@onready var fire = %Fire
@onready var sparcles = %Sparcles
@onready var explosion_audio = %ExplosionAudio

# TODO replace with VelocityComponent
var linear_velocity := Vector2.ZERO

func _ready():
	smoke.emitting = true
	fire.emitting = true
	sparcles.emitting = true
	explosion_audio.play()
	smoke.finished.connect(_destroy)

func _process(delta):
	position += linear_velocity * delta

func _destroy():
	queue_free()
