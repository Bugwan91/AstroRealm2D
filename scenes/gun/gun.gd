class_name Gun
extends Node2D

@export var parent: RigidBody2D
@export var bullet_scene: PackedScene
@export_range(0, 20) var fire_rate := 10.0
@export_range(0, 2000) var range := 500.0
@export_range(0, 5000) var bullet_speed := 200.0
@export_range(0, 100) var recoil := 0.5

@onready var _charge_timer = %ChargeTimer
@onready var sound = %Sound
@onready var _world_node = get_node("/root/Main")
@onready var bullet_lifetime = range / bullet_speed

var _is_firing := false
var _charging := false

func _ready():
	_charge_timer.wait_time = 1.0 / fire_rate
	_charge_timer.timeout.connect(_charge_done)

func _process(_delta):
	if _is_firing:
		fire()

func fire():
	if not _charging:
		_charge_start()
		_spawn_bullet()
		parent.apply_central_impulse(global_transform.x * -recoil)
		sound.play()

func start_fire():
	_is_firing = true

func stop_fire():
	_is_firing = false

func _charge_start():
	_charging = true
	_charge_timer.start()

func _charge_done():
	_charging = false

func _spawn_bullet():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.global_position = global_position
	bullet.global_rotation = global_rotation
	bullet.velocity = parent.linear_velocity
	bullet.impulse = recoil
	bullet.speed = bullet_speed
	_world_node.add_child(bullet)
	bullet.start(bullet_lifetime)
