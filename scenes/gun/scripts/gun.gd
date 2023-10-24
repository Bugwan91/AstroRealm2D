class_name Gun
extends Node2D

signal shoot_recoil(force: float)

@export var bullet_scene: PackedScene
@export_range(0, 40) var fire_rate := 10.0
@export_range(0, 5000) var range := 1000.0
@export_range(0, 5000) var bullet_speed := 500.0
@export_range(0, 100) var recoil := 1.0

@onready var _charge_timer = %ChargeTimer
@onready var _sound = %Sound
@onready var _world_node = get_node("/root/Main")
@onready var bullet_lifetime = range / bullet_speed

var position_extrapolator: PositionExtrapolation
var velocity := Vector2.ZERO

var _is_firing := false
var _is_charging := false

func _ready():
	_charge_timer.wait_time = 1.0 / fire_rate
	_charge_timer.timeout.connect(_charge_done)

func _process(_delta):
	_shoot()

func connect_inputs(inputs: ShipInput):
	inputs.fire.connect(_on_fire_input)

func _shoot():
	if _is_firing and not _is_charging:
		_spawn_bullet()
		_charge_start()
		_sound.play()
		shoot_recoil.emit(recoil)

func _charge_start():
	_is_charging = true
	_charge_timer.start()

func _charge_done():
	_is_charging = false
	_charge_timer.stop()

func _spawn_bullet():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.position = position_extrapolator.smooth_position + position.rotated(position_extrapolator.global_rotation)
	bullet.rotation = position_extrapolator.smooth_rotation + rotation
	bullet.linear_velocity = velocity
	bullet.impulse = recoil
	bullet.speed = bullet_speed
	_world_node.add_child(bullet)
	bullet.start(bullet_lifetime)


func _on_fire_input(value: bool):
	_is_firing = value
