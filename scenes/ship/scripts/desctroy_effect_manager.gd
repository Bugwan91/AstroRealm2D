class_name DestroyEffectManager
extends Node2D

signal destroy

@export_range(0, 1) var show_damage_hp := 0.3
@export_range(0, 1) var time_to_destroy_min: float = 1.0
@export_range(0, 5) var time_to_destroy_max: float = 3.0
@export var _damage_effect_scene: PackedScene
@export var _pre_destroy_effect_scene: PackedScene
@export var _destroy_effect_scene: PackedScene

@onready var timer = %Timer

var ship: ShipRigidBody

var _damage_effect
var _pre_destroy_effect

func _ready():
	timer.wait_time = randf_range(time_to_destroy_min, time_to_destroy_max)
	timer.timeout.connect(_on_destroy)

func _physics_process(_delta):
	if is_instance_valid(_damage_effect):
		_damage_effect.velocity = ship.real_velocity

func connect_health(health: Health):
	health.damaged.connect(_on_take_damage)
	health.dying.connect(_on_die)

func _get_damage_effect():
	if not is_instance_valid(_damage_effect):
		_damage_effect = _damage_effect_scene.instantiate()
		add_child(_damage_effect)
	return _damage_effect

func _get_pre_destroy_effect():
	if not is_instance_valid(_pre_destroy_effect):
		_pre_destroy_effect = _pre_destroy_effect_scene.instantiate()
		add_child(_pre_destroy_effect)
	return _pre_destroy_effect

func _on_take_damage(hp, max_hp):
	var intensity = clamp(1.0 - hp / (max_hp * show_damage_hp), 0, 1)
	if intensity > 0.0:
		_get_damage_effect().intensity = intensity

func _on_die():
	_on_destroy()
	#_get_pre_destroy_effect()
	#timer.start()

func _on_destroy():
	#var effect = _destroy_effect_scene.instantiate()
	var effect = _pre_destroy_effect_scene.instantiate()
	effect.position = global_position
	MainState.world_node.add_child(effect)
	destroy.emit()

