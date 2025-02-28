class_name Gun
extends Node2D

signal shoot_recoil(force: float)
signal tranfser_heat(heat: float)

@export var bullet_scene: PackedScene

@export var marker: AssistantPointer

@export var recoil_max_shift := 10.0
@export var recoild_return_speed := 30.0

# TODO: remove
@export var shoot_dellay := 0.0

@onready var view: WeaponView = %View
@onready var _sound: AudioStreamPlayer2D = %Sound
@onready var _shoot_point: Node2D = %ShootPoint
@onready var _heat: Heat = %Heat
@onready var _flash: GPUParticles2D = %MuzzleFlash
@onready var _flash_light: PointLight2D = %MuzzleFlashLight
@onready var _line: Line2D = %Line2D

var config: WeaponRes
var origin: Spaceship

var emission: = 0.0
var emission_reduction: = 10.0

var enabled := true

var _is_firing := false
var _is_charging := false:
	get: return _charge_time_current > 0.0
var _is_reloading := false
var _firing_time := 0.0
var _projectile_lifetime: float
var _projectile_extra_lifetime: float

var _flast_intensity := 0.0:
	set(value):
		_flast_intensity = value
		var show := value > 0.0
		_flash_light.visible = show

var _charge_time := 1.0
var _charge_time_current := 0.0

func init(conf: WeaponRes):
	config = conf
	_charge_time = 1.0 / config.fire_rate
	_projectile_lifetime = config.effective_range / config.projectile_speed
	_projectile_extra_lifetime = config.extra_range / config.projectile_speed

func connect_radiator(radiator: Heat):
	pass

#func connect_generator(generator: Generator):
	#pass

func _ready() -> void:
	view.set_emission_color(config.color)
	_flash.modulate = config.color
	_flash_light.color = config.color
	_flash_light.energy = 0.0
	_line.add_point(_shoot_point.position)
	_line.add_point(_shoot_point.position + Vector2(config.effective_range + config.extra_range, 0.0))
	_line.modulate = config.color

func _process(delta: float) -> void:
	_shoot(delta)
	_update_marker()
	_flash_light.energy = _flast_intensity * 2.0
	if _flast_intensity > 0.0:
		_flast_intensity -= 15.0 * delta
	else:
		_flast_intensity = 0.0
	if view.position.x < 0.0:
		view.position.x += recoild_return_speed * delta
	if _is_charging and enabled:
		_charge_time_current -= delta

func _physics_process(delta: float) -> void:
	tranfser_heat.emit(_heat.transfer(delta))

func set_origin(ship: Spaceship):
	origin = ship

func fire(value: bool):
	_is_firing = value

func _shoot(delta: float) -> void:
	if enabled and _is_firing and not _heat.is_high():
		if not _is_charging:
			_spawn_bullet(delta)
			_charge_start()
			_sound.pitch_scale = randf_range(0.6, 0.8)
			_sound.play()
		_firing_time += delta

func _charge_start() -> void:
	_charge_time_current = _charge_time

func _spawn_bullet(_delta: float) -> void:
	var bullet := bullet_scene.instantiate() as Bullet
	bullet.origin = origin
	var spear: float = (config.accuracy + config.overheat_accuracy * _heat.temperature) * pow(2.0 * (randf() - 0.5), 2.0) * sign(randf() - 0.5)
	bullet.color = config.color
	bullet._damage = config.damage
	bullet.effective_lifetime = _projectile_lifetime
	bullet.extra_lifetime = _projectile_extra_lifetime
	bullet.position = _shoot_point.global_position
	bullet.rotation = _shoot_point.global_rotation + spear
	bullet.start_velocity = origin.linear_velocity
	shoot_recoil.emit(-transform.x.rotated(global_rotation + spear) * config.recoil_impulse)
	bullet.impulse = config.recoil_impulse
	bullet.relative_speed = config.projectile_speed
	WorldGridManager.instance.world_root.add_child(bullet)
	_heat.add_heat(config.heat_generation)
	view.emit_max()
	view.position.x = -recoil_max_shift
	_flash.emitting = true
	_flash.restart()
	_flast_intensity = 1.0

func _update_marker() -> void:
	pass
	#if is_instance_valid(marker):
		#marker.update(global_transform.x * (range - 16.0), get_global_transform_with_canvas().origin)

func _on_reloaded() -> void:
	_is_reloading = false
	_firing_time = 0
