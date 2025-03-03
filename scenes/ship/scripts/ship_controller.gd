class_name FlightController
extends Node

const ANGULAR_THRESHOLD := 0.01
const STOP_THRESHOLD := 1.0
const DRAG := 0.5 # Not needs yet, but should thi be a global constant?
const STRAFE_LOW_SPEED_BONUS := 4.0

signal dodging(value: bool)

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model
		_closee_navigator.radius = ship.radius

var flight_model: ShipFlightModelData
var input_reader: ShipInput:
	set(value):
		if is_instance_valid(value):
			input_reader = value
			inputs = input_reader.data
var inputs: ShipInputData

@onready var _closee_navigator: CloseNavigator = %CloseNavigator

var current_strafe_thrust: float:
	get():
		return flight_model.strafe * _strafe_bonus\
			if is_instance_valid(flight_model)\
			else 0.0

var _dodging := false:
	set(value):
		_dodging = value
		dodging.emit(_dodging)
var _dodge_acceleration := false
var _dodge_time := 0.0
var _dodge_vector := Vector2(1.0, 0.0)

var _strafe_buildup := Vector2.ZERO
var _strafe_bonus := 1.0

func setup(spaceship: Spaceship) -> void:
	ship = spaceship
	_closee_navigator.enabled = not ship.is_player()
	flight_model.init()

func _ready() -> void:
	# _physics_process() should be called after BTPlayer or user controls
	process_physics_priority = 100

func _physics_process(delta: float) -> void:
	if not is_instance_valid(inputs): return
	_dodge(delta)
	var avoid_strafe := _closee_navigator.update_course(
		delta,
		ship.position,
		ship.linear_velocity) * 2.0
	inputs.strafe += avoid_strafe if inputs.use_absolute else avoid_strafe.rotated(-ship.rotation)
	_update_strafe_bonus()
	_stop(delta)
	_strafe()
	_rotate(delta)
	_boost()
	_drag()

func _update_strafe_bonus() -> void:
	if flight_model.strafe_start_bonus == 0.0: return
	_strafe_buildup += inputs.strafe * 0.1
	var l := _strafe_buildup.length()
	if l > 1.0:
		_strafe_buildup /= l
	_strafe_bonus = 1.0 + flight_model.strafe_start_bonus * (1.0 - clampf(_strafe_buildup.dot(inputs.strafe), 0.0, 1.0))
	_strafe_buildup *= 0.9

func _stop(delta: float) -> void:
	if not inputs.stop or inputs.dodge: return
	var stop_vector := -ship.linear_velocity.normalized()
	var step_distance := flight_model.strafe * delta
	if ship.speed < step_distance:
		ship.linear_velocity = Vector2.ZERO
	else:
		# CAUTION Probably it's not sync safe, as inputs.strafe also updates in ShipInput
		# But probably it doesn't mater as long as strafe input doesn't changing every frame
		inputs.strafe += 2.0 * (stop_vector if inputs.use_absolute else stop_vector.rotated(-ship.rotation))

func _dodge(delta: float) -> void:
	if inputs.dodge and not _dodging and abs(inputs.strafe.y) > 1e-4:
		_dodging = true
		_dodge_acceleration = true
		inputs.dodge = false
		_dodge_time = 0.0
		var y := 1.0 if inputs.strafe.y > 0 else -1.0
		_dodge_vector = Vector2(0.0, y).rotated(ship.rotation) # update to allow dodging within absolute coorditates
	inputs.dodge = false
	if _dodging:
		if _dodge_acceleration:
			_dodge_time += delta
			ship.apply_central_force(_dodge_vector * flight_model.dodge)
			if _dodge_time > flight_model.dodge_duration:
				_dodge_time = 0.0
				_dodge_acceleration = false
		else:
			ship.apply_central_force(-_dodge_vector * flight_model.dodge_stop)
			_dodge_time += delta
			if _dodge_time > flight_model.dodge_stop_duration:
				_dodging = false
				_dodge_time = 0.0

func _strafe() -> void:
	if inputs.strafe.is_zero_approx(): return
	#var str_inp := inputs.strafe
	#str_inp.x = str_inp.x if str_inp.x > 0. else str_inp.x * 0.2
	# penalty for strafing backwards
	# need playtesting
	# also it requires better logic with extra rotation for better avoiding collisions
	var str_input := inputs.strafe if inputs.use_absolute else inputs.strafe.rotated(ship.rotation) # Ralative
	#var str_input := inputs.strafe.rotated(-0.5*PI) # Absolute
	str_input *= _strafe_bonus #str_input * _strafe_bonus()
	# TODO: precalculate strafe_force in flight_model
	ship.apply_central_force(str_input * flight_model.strafe * ship.mass)

func _rotate(delta: float) -> void:
	var angle := ship.transform.x.angle_to(input_reader.update_target_point() - ship.position)
	var d := absf(angle)
	if d < ANGULAR_THRESHOLD and abs(ship.angular_velocity) < ANGULAR_THRESHOLD:
		ship.angular_velocity = 0.0
		return
	var a := flight_model.turn * delta * delta
	var n := floorf((sqrt(a*a + 8*a*d) - a) / (2*a))
	var wt := signf(angle) * (d/(n+1.0) + 0.5*a*n)
	var w := ship.angular_velocity * delta
	var control := clampf((wt - w) / a, -1., 1.)
	ship.apply_torque(control * flight_model.turn * ship.inertia)

func _boost() -> void:
	if not inputs.boost: return
	var boost := inputs.boost * flight_model.boost * ship.transform.x
	ship.apply_central_force(boost)

func _drag() -> void:
	if _dodge_acceleration: return
	var speed := ship.linear_velocity.length()
	var extra_speed := speed - flight_model.speed
	if extra_speed > 0.0:
		var stop_force := extra_speed * DRAG * -ship.linear_velocity.normalized()
		ship.apply_central_force(stop_force * ship.mass)
	if speed < 300.0:
		ship.apply_central_force(-ship.linear_velocity.normalized() * 10.0)
