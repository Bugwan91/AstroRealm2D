class_name ThrusterFlame
extends Node2D

const THRESHOLD := 0.01

@onready var sprite = %Sprite
@onready var smoke_effect = %SmokeEffect
@onready var flame_effect = %FlameEffect
@onready var sound = %Sound

var _max_volume := 0.0

func _ready():
	run_effect(0)
	run_sound(0)

func setup_sound(volume: float, pitch: float):
	_max_volume = volume
	pitch = pitch

func run(force: float):
	run_effect(force)
	run_sound(force)

func run_effect(force: float):
	if force < THRESHOLD:
		smoke_effect.emitting = false
		flame_effect.emitting = false
	else:
		modulate.a = force
		smoke_effect.emitting = true
		flame_effect.emitting = true

func run_sound(force: float):
	sound.volume_db = _max_volume - (40 - 40 * force)
	if force < THRESHOLD:
		sound.stop()
	elif not sound.playing:
		sound.play()
