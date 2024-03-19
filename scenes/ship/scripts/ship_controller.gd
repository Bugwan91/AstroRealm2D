class_name FlightController
extends Node

const ANGULAR_THRESHOLD := 0.01
const DRAG := 0.01

@export var move_world := false

var ship: Spaceship:
	set(value):
		ship = value
		flight_model = ship.data.flight_model

var flight_model: ShipFlightModelData
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
	#_apply_drag(state)

func _apply_controls(state: PhysicsDirectBodyState2D):
	if not is_instance_valid(inputs): return
	MyDebug.info("stop", inputs.stop)
	_stop(state)
	_strafe(state)
	_rotate(state)
	_boost(state)

func _apply_impulse(state: PhysicsDirectBodyState2D):
	if _impulses.is_zero_approx(): return
	state.apply_central_impulse(_impulses)
	_impulses = Vector2.ZERO

#func _apply_drag(state: PhysicsDirectBodyState2D):
	#var absolute_v := ship.absolute_velocity
	#var speed := absolute_v.length()
	#var delta_speed = speed - flight_model.speed
	#TODO: implement drag if needed
	#if delta_speed > 0.001:
		#_add_linear_velocity(state, (DRAG * delta_speed * absolute_v / speed))

func _stop(state: PhysicsDirectBodyState2D):
	if not inputs.stop: return
	var stop_vector := -ship.absolute_velocity.rotated(-ship.rotation).normalized()
	# TODO: clamp stop strafe input to not overshoot
	inputs.strafe = (inputs.strafe + stop_vector).normalized()

func _strafe(state: PhysicsDirectBodyState2D):
	var str_input := inputs.strafe.rotated(ship.rotation)
	if str_input.x == 0.0 and str_input.y == 0.0: return
	var str_target := str_input * flight_model.speed
	var delta := str_target - ship.absolute_velocity
	var delta_l := delta.length()
	var delta_n = delta / delta_l
	var strafe_mult: float = smoothstep(0.0, 1.0, delta_l / flight_model.speed)
	var result_v: Vector2 = delta_n * strafe_mult * flight_model.strafe * state.step
	_add_linear_velocity(state, result_v)

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

func _add_linear_velocity(state: PhysicsDirectBodyState2D, velocity: Vector2):
	if move_world:
		FloatingOrigin.add_velocity(-velocity)
	else:
		state.linear_velocity += velocity
