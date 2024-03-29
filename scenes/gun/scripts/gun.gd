class_name Gun
extends Node2D

signal shoot_recoil(force: float)

@export var group: String
@export var bullet_scene: PackedScene
@export var bullet_color: Color = Color.RED
@export var accuracy: float = 0.05
@export_range(0, 60) var fire_rate := 10.0
@export_range(0, 5000) var range := 2000.0
@export_range(0, 10000) var bullet_speed := 3000.0
@export_range(0, 1000) var recoil := 20.0
@export_range(0, 1000) var heat_per_shoot := 5.0
@export var marker: AssistantPointer

@onready var _charge_timer: Timer = %ChargeTimer
@onready var _sound: AudioStreamPlayer2D = %Sound
@onready var reloading_timer: Timer = %ReloadingTimer
@onready var _shoot_point: Node2D = %ShootPoint
@onready var _heat = %Heat

@onready var view: WeaponView = %View
var emission = 0.0
var emission_reduction = 10.0

var velocity := Vector2.ZERO

var _is_firing := false
var _is_charging := false
var _is_reloading := false
var _firing_time := 0.0
var _bullet_lifetime: float

func _ready():
	_charge_timer.wait_time = 1.0 / fire_rate
	_charge_timer.timeout.connect(_charge_done)
	_bullet_lifetime = range / bullet_speed
	view.set_emission_color(bullet_color)

func on_fire_input(value: bool):
	_is_firing = value

func _process(delta):
	_shoot(delta)
	_update_marker()

func _shoot(delta: float):
	if _is_firing and not _heat.is_max():
		if not _is_charging:
			_spawn_bullet(delta)
			_charge_start()
			_sound.play()
		_firing_time += delta

func _charge_start():
	_is_charging = true
	_charge_timer.start()

func _charge_done():
	_is_charging = false
	_charge_timer.stop()

func _spawn_bullet(delta: float):
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.group = group
	var spear: float = accuracy * pow(2.0 * (randf() - 0.5), 2.0) * sign(randf() - 0.5)
	bullet.position = _shoot_point.global_position
	bullet.rotation = global_rotation + spear
	bullet.start_velocity = velocity.rotated(spear)
	shoot_recoil.emit(-transform.x.rotated(spear) * recoil)
	bullet.impulse = recoil
	bullet.bullet_speed = bullet_speed
	MainState.main_scene.add_child(bullet)
	bullet.update_material(bullet_color)
	bullet.start(_bullet_lifetime, delta)
	_heat.add_heat(heat_per_shoot)
	view.emit_max()

func _update_marker():
	if is_instance_valid(marker):
		marker.update(global_transform.x * (range - 16.0), get_global_transform_with_canvas().origin)

func _on_reloaded():
	_is_reloading = false
	_firing_time = 0
