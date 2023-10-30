class_name Gun
extends Node2D

signal shoot_recoil(force: float)

@export var bullet_scene: PackedScene
@export_range(0, 40) var fire_rate := 10.0
@export_range(0, 5000) var range := 1000.0
@export_range(0, 10000) var bullet_speed := 500.0
@export_range(0, 100) var recoil := 1.0
@export_range(0, 10) var overheat := 1.0
@export_range(0, 10) var reload_time := 2.0
@export var marker: AssistantPointer

@onready var _charge_timer = %ChargeTimer
@onready var _sound = %Sound
@onready var _world_node = get_node("/root/Main")
@onready var reloading_timer: Timer = %ReloadingTimer

var velocity := Vector2.ZERO

var _is_firing := false
var _is_charging := false
var _is_reloading := false
var _firing_time := 0.0
#var _rel_effect: float

func _ready():
	_charge_timer.wait_time = 1.0 / fire_rate
	_charge_timer.timeout.connect(_charge_done)
	reloading_timer.wait_time = reload_time
	reloading_timer.timeout.connect(_on_reloaded)

func _process(delta):
	_update_marker()
	_shoot(delta)
	#_rel_effect = sqrt(1.0 - velocity.length() / FloatingOrigin.c)
	#_charge_timer.wait_time = 1.0 / (fire_rate * _rel_effect)
	#reloading_timer.wait_time = reload_time / _rel_effect

func connect_inputs(inputs: ShipInput):
	inputs.fire.connect(_on_fire_input)

func _shoot(delta: float):
	if _is_firing and not _is_reloading:
		
		if not _is_charging:
			_spawn_bullet()
			_charge_start()
			_sound.play()
			shoot_recoil.emit(recoil)
		if overheat == 0: return
		_firing_time += delta
		if _firing_time > overheat:
			_is_reloading = true
			reloading_timer.start()

func _charge_start():
	_is_charging = true
	_charge_timer.start()

func _charge_done():
	_is_charging = false
	_charge_timer.stop()

func _spawn_bullet():
	var bullet = bullet_scene.instantiate() as Bullet
	bullet.position = global_position
	bullet.rotation = global_rotation
	bullet.linear_velocity = velocity
	bullet.impulse = recoil
	bullet.speed = bullet_speed# * _rel_effect
	_world_node.add_child(bullet)
	bullet.start(range / bullet.speed)

func _update_marker():
	if is_instance_valid(marker):
		marker.update(global_transform.x * (range - 16.0), get_global_transform_with_canvas().origin)

func _on_fire_input(value: bool):
	_is_firing = value

func _on_reloaded():
	_is_reloading = false
	_firing_time = 0
