class_name ShipFlightModelData
extends Resource

const MASS_MIN := 0.01
const INERTIA_MULTIPLYER: float = 2500.0
const DODGE_MIN := 10.0
const DODGE_DURATION_MIN := 0.05
const DODGE_SLOWING_MULT := 4.0
const DODGE_COOLDOWN_MIN := 0.2

signal mass_changed(value: float)
signal inertia_changed(value: float)
signal speed_changed(value: float)
signal boost_changed(value: float)
signal strafe_changed(value: float)
signal turn_changed(value: float)
signal dodge_changed(value: float)
signal dodge_duration_changed(value: float)
signal dodge_cooldown_changed(value: float)

@export_range(MASS_MIN, 1000.0) var mass: float = 1.0: set = _set_mass
@export_range(0.0, 50000.0) var speed: float = 2000.0: set = _set_speed
@export_range(0.0, 10000.0) var boost_base: float = 0.5: set = _update_boost
@export_range(0.0, 10000.0) var strafe_base: float = 100.0: set = _update_strafe
@export_range(0.0, 15.0) var turn_base: float = 1.0: set = _update_turn
## Dodge shoudl be used as strafe multiplyer
@export_range(DODGE_MIN, 1000.0) var dodge_base: float = 15.0: set = _update_dodge
@export_range(DODGE_DURATION_MIN, 1.0) var dodge_duration: float = 0.1: set = _update_dodge_duration
@export_range(DODGE_COOLDOWN_MIN, 5.0) var dodge_cooldown: float = 0.5: set = _update_dodge_cooldown

## angular momentum
var inertia: float
## boost acceleration
var boost: float
## strafe acceleration
var strafe: float
## Dodge acceleration
var dodge: float
## Dodge stop acceleration
var dodge_stop: float
## dodge deacceleration duration
var dodge_stop_duration: float
var turn: float # rotation acceleration
var speed_sq: float

var ship: Spaceship

var _mass_inv: float
var _inertia_inv: float

func init() -> void:
	_mass_inv = 1.0 / mass
	inertia = mass * INERTIA_MULTIPLYER
	_inertia_inv = 1.0 / inertia
	if is_instance_valid(ship):
		ship.mass = mass
		ship.inertia = inertia
	mass_changed.emit(mass)
	inertia_changed.emit(inertia)
	_update_boost(boost_base)
	_update_strafe(strafe_base)
	_update_dodge(dodge_base)
	_update_dodge_duration(dodge_duration)
	_update_turn(turn_base)

func _set_mass(new: float) -> void:
	mass = maxf(MASS_MIN, new)
	init()

func _set_speed(new: float) -> void:
	speed = maxf(0.0, new)
	speed_sq = speed * speed
	speed_changed.emit(speed)

func _update_boost(new: float) -> void:
	boost_base = maxf(0.0, new)
	boost = boost_base * _mass_inv
	boost_changed.emit(boost)

func _update_strafe(new: float) -> void:
	strafe_base = maxf(0.0, new)
	strafe = strafe_base * _mass_inv
	strafe_changed.emit(strafe)

func _update_turn(new: float) -> void:
	turn_base = maxf(0.0, new)
	turn = turn_base * _mass_inv
	turn_changed.emit(turn)

func _update_dodge(new: float) -> void:
	dodge_base = maxf(DODGE_MIN, new)
	dodge = strafe * dodge_base
	dodge_stop = strafe * dodge_base * 0.9 / DODGE_SLOWING_MULT
	dodge_changed.emit(dodge)

func _update_dodge_duration(new: float) -> void:
	dodge_duration = maxf(DODGE_DURATION_MIN, new)
	dodge_stop_duration = dodge_duration * DODGE_SLOWING_MULT
	dodge_duration_changed.emit(dodge_duration)

func _update_dodge_cooldown(new: float) -> void:
	dodge_cooldown = maxf(DODGE_COOLDOWN_MIN, new)
	dodge_cooldown_changed.emit(dodge_cooldown)
