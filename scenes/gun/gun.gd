class_name Gun
extends Node2D

@export var parent: RigidBody2D
@export var bullet_scene: PackedScene
@export_range(0, 10) var fire_rate := 10.0
@export_range(0, 1000) var range := 500.0
@export_range(0, 1000) var bullet_speed := 200.0

@onready var _charge_timer = %ChargeTimer
@onready var _world_node = get_node("/root/Main")
@onready var bullet_lifetime = range / bullet_speed

var _is_firing := false
var _charging := false

func _ready():
	_charge_timer.wait_time = 1.0 / fire_rate
	_charge_timer.timeout.connect(_charge_done)

func _process(delta):
	if _is_firing:
		fire()

func _input(event):
	if event.is_action_pressed("fire"):
		_is_firing = true
	elif event.is_action_released("fire"):
		_is_firing = false

func fire():
	if not _charging:
		_charge_start()
		_spawn_bullet()

func _charge_start():
	_charging = true
	_charge_timer.start()

func _charge_done():
	_charging = false

func _spawn_bullet():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	_world_node.add_child(bullet)
	bullet.linear_velocity = parent.linear_velocity + global_transform.x * bullet_speed
	bullet.start(bullet_lifetime)
