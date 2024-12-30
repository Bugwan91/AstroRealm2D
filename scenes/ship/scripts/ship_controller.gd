class_name FlightController
extends Node

const ANGULAR_THRESHOLD := 0.01
const STOP_THRESHOLD := 1.0
const DRAG := 0.01

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model

var flight_model: ShipFlightModelData
var inputs: ShipInputData

func setup(spaceship: Spaceship):
	ship = spaceship

func integrate_forces(state: PhysicsDirectBodyState2D):
	if not is_instance_valid(inputs): return
	_stop(state)
	_strafe(state)
	_rotate(state)
	_boost(state)
	
func _stop(state: PhysicsDirectBodyState2D):
	if not inputs.stop: return
	var d := ship.speed
	var stop_vector := -ship.linear_velocity.normalized()
	var f := _calculate_strafe_force(stop_vector).length()
	var stop_d := f * state.inverse_mass * state.step
	if d < stop_d:
		ship.linear_velocity = Vector2.ZERO
	else:
		# CAUTION Will work only for inputs 0 or 1, no .2, .3, .5...
		inputs.strafe += inputs.strafe + (stop_vector).rotated(-ship.rotation)

func _strafe(state: PhysicsDirectBodyState2D):
	if inputs.strafe.is_zero_approx(): return
	var str_input := inputs.strafe.rotated(ship.rotation)
	ship.apply_force(_calculate_strafe_force(str_input))

func _calculate_strafe_force(input: Vector2) -> Vector2:
	var target_v := input * flight_model.speed
	var delta_v := target_v - ship.linear_velocity
	var delta_v_l := delta_v.length()
	var delta_dir = delta_v / delta_v_l
	var strafe_mult := delta_v_l / flight_model.speed
	strafe_mult = smoothstep(0.0, 0.2, strafe_mult)
	return delta_dir * strafe_mult * flight_model.strafe

func _rotate(state: PhysicsDirectBodyState2D):
	var d := ship.transform.x.angle_to(inputs.target_point - ship.position)
	if abs(d) < ANGULAR_THRESHOLD and abs(ship.angular_velocity) < ANGULAR_THRESHOLD:
		ship.angular_velocity = 0.0
		return
	var a := flight_model.turn * state.step
	var vt := 0.5 * (sqrt(a * (a + 8.0 * absf(d))) - a) * signf(d) / state.step
	# TODO: reimplemet this with apply_torque()
	ship.angular_velocity = vt

func _boost(state: PhysicsDirectBodyState2D):
	pass
