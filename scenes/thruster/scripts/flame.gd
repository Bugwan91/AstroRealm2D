class_name ThrusterFlame
extends Node2D

const THRESHOLD := 0.01

@export var show_flame := true
@export var show_zoom := 0.1

@onready var _smoke_effect = %SmokeEffect
@onready var _flame_effect = %FlameEffect
@onready var _sound = %Sound
@onready var _light = %Light

var _max_volume := 0.0

func _ready():
	run_effect(0.0)
	run_sound(0.0)
	(get_viewport().get_camera_2d() as CameraController).zoomed.connect(_on_zoom)

func _on_zoom(zoom: float):
	visible = zoom > show_zoom

func setup_sound(volume: float, pitch: float):
	_max_volume = volume
	pitch = pitch

func run(force: float):
	run_effect(force)
	run_sound(force)

func run_effect(force: float):
	if force < THRESHOLD:
		_smoke_effect.emitting = false
		if show_flame:
			_light.visible = false
			_flame_effect.emitting = false
	else:
		modulate.a = force
		_smoke_effect.emitting = true
		if show_flame:
			_light.visible = true
			_light.energy = force
			_flame_effect.emitting = true

func run_sound(force: float):
	_sound.volume_db = _max_volume - (40 - 40 * force)
	if force < THRESHOLD:
		_sound.stop()
	elif not _sound.playing:
		_sound.play()
