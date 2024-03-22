class_name ShipFlightModelData
extends Resource

const INERTIA_MULTIPLYER: float = 2500.0

signal mass_changed(new_mass: float)
signal inertia_changed(new_inertia: float)
signal speed_changed(new_speed: float)
signal boost_changed(new_boost: float)
signal strafe_changed(new_strafe: float)
signal turn_changed(new_turn: float)

@export_range(0.01, 1000.0) var mass: float = 1.0: set = _set_mass
@export_range(1.0, 50000.0) var speed: float = 2000.0: set = _set_speed
@export_range(0.0, 10.0) var boost_base: float = 0.5: set = _update_boost
@export_range(0.0, 10000.0) var strafe_base: float = 100.0: set = _update_strafe
@export_range(0.0, 15.0) var turn_base: float = 1.0: set = _update_turn

var inertia: float
var boost: float
var strafe: float
var turn: float

var ship: Spaceship

var _mass_inv: float
var _inertia_inv: float

func _set_mass(new_mass: float):
	mass = new_mass if new_mass > 0.0 else 0.0
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
	_update_turn(turn_base)

func _set_speed(new_speed: float):
	speed = new_speed if new_speed > 0.0 else 0.0
	speed_changed.emit(speed)

func _update_boost(new_boost: float):
	boost_base = new_boost if new_boost > 0.0 else 0.0
	boost = boost_base * _mass_inv
	boost_changed.emit(boost)

func _update_strafe(new_strafe: float):
	strafe_base = new_strafe if new_strafe > 0.0 else 0.0
	strafe = strafe_base * _mass_inv
	strafe_changed.emit(strafe)

func _update_turn(new_turn: float):
	turn_base = new_turn if new_turn > 0.0 else 0.0
	turn = turn_base * _mass_inv
	turn_changed.emit(turn)
