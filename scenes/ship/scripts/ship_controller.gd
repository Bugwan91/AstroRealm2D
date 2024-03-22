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

var _impulses := Vector2.ZERO

func setup(spaceship: Spaceship):
	ship = spaceship

func _physics_process(delta):
	process(delta)

func add_impulse(impulse: Vector2):
	add_impulse_absolute(impulse.rotated(-ship.rotation))

func add_impulse_absolute(impulse: Vector2):
	_impulses += impulse

func process(delta: float):
	_apply_controls(delta)
	_apply_impulse()
	#_apply_drag(state)

func _apply_controls(delta: float):
	if not is_instance_valid(inputs): return
	_stop(delta)
	_strafe(delta)
	_rotate(delta)
	_boost(delta)

func _apply_impulse():
	if _impulses.is_zero_approx(): return
	ship.apply_impulse(_impulses)
	_impulses = Vector2.ZERO

#TODO: implement drag if needed
#func _apply_drag(state: PhysicsDirectBodyState2D):
	#var absolute_v := ship.absolute_velocity
	#var speed := absolute_v.length()
	#var delta_speed = speed - flight_model.speed
	#if delta_speed > 0.001:
		#_add_linear_velocity(state, (DRAG * delta_speed * absolute_v / speed))

func _stop(delta: float):
	if not inputs.stop: return
	var speed := ship.absolute_velocity.length()
	if speed < STOP_THRESHOLD: return
	var stop_vector := -ship.absolute_velocity.rotated(-ship.rotation).normalized()
	var result_delta_v := _calculate_strafe_delta_v(stop_vector, delta)
	var result_delta_speed := result_delta_v.length()
	var limiter := speed / result_delta_speed
	limiter = clampf(limiter, 0.0, 1.0)
	inputs.strafe += stop_vector * limiter

func _strafe(delta: float):
	var str_input := inputs.strafe.rotated(ship.rotation)
	if str_input.is_zero_approx(): return
	ship.linear_velocity += _calculate_strafe_delta_v(str_input, delta)

func _calculate_strafe_delta_v(input: Vector2, delta: float) -> Vector2:
	var str_target := input * flight_model.speed
	var delta_v := str_target - ship.absolute_velocity
	var delta_l := delta_v.length()
	var delta_n = delta_v / delta_l
	var strafe_mult := delta_l / flight_model.speed
	strafe_mult = smoothstep(0.0, 1.0, strafe_mult)
	return delta_n * strafe_mult * flight_model.strafe * delta

func _rotate(delta: float):
	var d := ship.transform.x.angle_to(inputs.target_point - ship.position)
	if abs(d) < ANGULAR_THRESHOLD and abs(ship.angular_velocity) < ANGULAR_THRESHOLD:
		ship.angular_velocity = 0.0
		return
	var a := flight_model.turn * delta
	var s := absf(d)
	var n := 0.5 * (sqrt(a * (a + 8.0 * s)) / a - 1.0)
	var vt := 0.5 * (sqrt(a * (a + 8.0 * s)) - a) * signf(d) / delta
	ship.angular_velocity = vt

func _boost(delta: float):
	pass
