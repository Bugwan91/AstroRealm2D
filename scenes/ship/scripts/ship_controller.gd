class_name FlightController
extends Node

const ANGULAR_THRESHOLD := 0.01
const STOP_THRESHOLD := 1.0
const DRAG := 0.5
const STRAFE_LOW_SPEED_BONUS := 2.0

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model

var flight_model: ShipFlightModelData
var inputs: ShipInput
var _input_data: ShipInputData

func setup(spaceship: Spaceship):
	ship = spaceship

func integrate_forces(state: PhysicsDirectBodyState2D):
	if not is_instance_valid(inputs): return
	_input_data = inputs.data
	_stop(state)
	_strafe(state)
	_rotate(state)
	_boost(state)
	_drag(state)
	
func _stop(state: PhysicsDirectBodyState2D):
	if not _input_data.stop: return
	var stop_vector := -ship.linear_velocity.normalized()
	var step_distance := flight_model.strafe * (1.0 + _strafe_bonus(state)) * state.step
	if ship.speed < step_distance:
		ship.linear_velocity = Vector2.ZERO
	else:
		# CAUTION Probably it's not sync safe, as inputs.data.strafe also updates in ShipInput
		# But probably it doesn't mater as long as strafe input diesn't changing every frame
		_input_data.strafe += 2.0 * (stop_vector).rotated(-ship.rotation)

func _strafe(state: PhysicsDirectBodyState2D):
	if _input_data.strafe.is_zero_approx(): return
	var str_input := _input_data.strafe.rotated(ship.rotation)
	str_input += str_input * _strafe_bonus(state)
	state.apply_central_force(str_input * flight_model.strafe)

func _strafe_bonus(state: PhysicsDirectBodyState2D) -> float:
	var s := state.linear_velocity.length()
	var d := minf(s / flight_model.speed, 1.0)
	return pow((1.0 - d), 2.0) * STRAFE_LOW_SPEED_BONUS

func _rotate(state: PhysicsDirectBodyState2D):
	var d := state.transform.x.angle_to(inputs.update_target_point() - state.transform.origin)
	if abs(d) < ANGULAR_THRESHOLD and abs(ship.angular_velocity) < ANGULAR_THRESHOLD:
		ship.angular_velocity = 0.0
		return
	var a := flight_model.turn * state.step
	var vt := 0.5 * (sqrt(a * (a + 8.0 * absf(d))) - a) * signf(d) / state.step
	# TODO: reimplemet this with apply_torque()
	ship.angular_velocity = vt

func _boost(state: PhysicsDirectBodyState2D):
	if not _input_data.boost: return
	var boost := _input_data.boost * flight_model.boost * state.transform.x
	state.apply_central_force(boost)

func _drag(state: PhysicsDirectBodyState2D):
	var extra_speed := state.linear_velocity.length_squared() - flight_model.speed_sq
	if extra_speed < 0.0: return
	var stop_force := sqrt(extra_speed) * DRAG * -state.linear_velocity.normalized()
	state.apply_central_force(stop_force)
