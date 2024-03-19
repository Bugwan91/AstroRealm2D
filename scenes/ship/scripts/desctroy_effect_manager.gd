class_name DestroyEffectManager
extends Node2D

signal destroy

@export_range(0, 1) var show_damage_hp := 0.3
@export_range(0, 1) var time_to_destroy_min: float = 1.0
@export_range(0, 5) var time_to_destroy_max: float = 3.0
@export var _damage_effect_scene: PackedScene
@export var _destroy_effect_scene: PackedScene

var ship: Spaceship

var _damage_effect

func setup(spaceship: Spaceship):
	ship = spaceship
	connect_health(ship.health)

func _physics_process(_delta):
	if is_instance_valid(_damage_effect):
		_damage_effect.velocity = ship.absolute_velocity

func connect_health(health: Health):
	health.damaged.connect(_on_take_damage)
	health.dying.connect(_on_die)

func _get_damage_effect():
	if not is_instance_valid(_damage_effect):
		_damage_effect = _damage_effect_scene.instantiate()
		add_child(_damage_effect)
	return _damage_effect

func _on_take_damage(hp, max_hp):
	var intensity = clamp(1.0 - hp / (max_hp * show_damage_hp), 0, 1)
	if intensity > 0.0:
		_get_damage_effect().intensity = intensity

func _on_die():
	var effect: ShipDestroyEffect = _destroy_effect_scene.instantiate()
	effect.linear_velocity = ship.absolute_velocity
	effect.position = global_position
	MainState.main_scene.add_child(effect)
	destroy.emit()

