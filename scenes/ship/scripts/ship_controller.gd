class_name FlightController
extends Node

const ANGULAR_THRESHOLD := 0.01

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model

var flight_model: ShipFlightModelData
var controls := ShipControlData.new()
var inputs: ShipInputData

var _impulses := Vector2.ZERO

func setup(spaceship: Spaceship):
	ship = spaceship

func add_impulse(impulse: Vector2):
	add_impulse_absolute(impulse.rotated(-ship.rotation))

func add_impulse_absolute(impulse: Vector2):
	_impulses += impulse

func process(state: PhysicsDirectBodyState2D):
	_apply_controls(state)
	_apply_impulse(state)
	_apply_drag(state)

func _apply_controls(state: PhysicsDirectBodyState2D):
	if not is_instance_valid(inputs): return
	_strafe(state)
	_rotate(state)
	_boost(state)

func _apply_impulse(state: PhysicsDirectBodyState2D):
	if _impulses.is_zero_approx(): return
	state.apply_central_impulse(_impulses)
	_impulses = Vector2.ZERO

func _apply_drag(state: PhysicsDirectBodyState2D):
	var absolute_v := ship.absolute_velocity
	var delta_v = absolute_v.length() - flight_model.speed
	if delta_v > 0.001:
		state.apply_central_force(delta_v * flight_model.mass * -absolute_v.normalized())

func _strafe(state: PhysicsDirectBodyState2D):
	state.linear_velocity += inputs.strafe.rotated(ship.rotation)\
			* flight_model.strafe * state.step

func _rotate(state: PhysicsDirectBodyState2D):
	var d := state.transform.x.angle_to(inputs.target_point - state.transform.origin)
	if abs(d) < ANGULAR_THRESHOLD and abs(state.angular_velocity) < ANGULAR_THRESHOLD:
		state.angular_velocity = 0.0
		return
	var a := flight_model.turn * state.step
	var s := absf(d)
	var n := 0.5 * (sqrt(a * (a + 8.0 * s)) / a - 1.0)
	var vt := 0.5 * (sqrt(a * (a + 8.0 * s)) - a) * signf(d) / state.step
	state.angular_velocity = vt

func _boost(state: PhysicsDirectBodyState2D):
	pass
