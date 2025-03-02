class_name ControlUnils
extends Object

const DISTANCE_THRESHOLD := 1.0
const VELOCITY_THRESHOLD := 1.0

static func match_velocity_control(dv: Vector2, a_tick: float) -> Vector2:
	var d_spd := dv.length()
	if d_spd < VELOCITY_THRESHOLD:
		return Vector2.ZERO
	var f := minf(1.0, d_spd / a_tick)
	return  f * (dv / d_spd)

static func get_stop_velocity(
	p_delta: Vector2,
	v_delta: Vector2,
	a: float,
	a_target: Vector2 = Vector2.ZERO
	) -> Vector2:
	var d_speed = v_delta.project(p_delta).length()
	var distance = p_delta.length()
	var dir_n = p_delta / distance
	if distance < DISTANCE_THRESHOLD and d_speed < VELOCITY_THRESHOLD:
		return Vector2.ZERO
	var a_total: Vector2 = a * dir_n + a_target
	var a_sum: float = a_total.project(p_delta).length()
	var v := sqrt(a_sum * distance * 0.66666666666) # 2/3
	return v * dir_n

static func get_stop_v_by_steps(
	p_delta: Vector2,
	a: float
) -> Vector2:
	return 0.5 * (sqrt(a * (1.0 + 8.0 * p_delta.length())) - a) * p_delta.normalized()
