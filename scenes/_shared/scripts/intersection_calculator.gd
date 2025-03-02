class_name InterceptionCalculator
extends Object

static func simple_interception(
	shooter_position: Vector2,
	shooter_velocity: Vector2,
	target_position: Vector2,
	target_velocity: Vector2,
	projectile_speed: float
	) -> Vector2:
	var D := target_position - shooter_position
	var V_rel := shooter_velocity - target_velocity
	
	var a := V_rel.dot(V_rel) - projectile_speed * projectile_speed
	var b := -2.0 * D.dot(V_rel)
	var c := D.dot(D)
	
	var t_min := INF
	
	# Handle cases where a is approximately zero (avoid division by zero)
	if abs(a) < 1e-6:
		if abs(b) < 1e-6:
			return D if D.length_squared() > 0 else Vector2.ZERO
		else:
			var t := -c / b
			if t > 0:
				t_min = t
	else:
		var discriminant := b * b - 4.0 * a * c
		if discriminant < 0:
			return D
		
		var sqrt_disc := sqrt(discriminant)
		var t1 := (-b + sqrt_disc) / (2.0 * a)
		var t2 := (-b - sqrt_disc) / (2.0 * a)
		
		if t1 > 0:
			t_min = t1
		if t2 > 0 and t2 < t_min:
			t_min = t2
	
	if t_min == INF:
		return D
	
	var interseption_delta_p := (D - V_rel * t_min) / (projectile_speed * t_min)
	return interseption_delta_p

static func interception(
	shooter_position: Vector2,
	shooter_velocity: Vector2,
	target_position: Vector2,
	target_velocity: Vector2,
	target_acceleration: Vector2,
	projectile_speed: float,
	estimated_time: float = 0.0,
	tolerance: float = 1.0,
	max_iterations: int = 10
) -> Vector2:
	var delta_p := target_position - shooter_position
	var delta_v := target_velocity - shooter_velocity
	var a := 0.5 * target_acceleration
	
	# Initial guess from constant-velocity solution
	var t := (delta_p).length() / projectile_speed if estimated_time == 0.0 else estimated_time
	
	for i in max_iterations:
		# Calculate target position at time t
		var target_pos_t := delta_p + delta_v * t + a * t * t
		var distance := target_pos_t.length()
		
		# Calculate f(t) = projectile_speed * t - distance
		var f := projectile_speed * t - distance
		if abs(f) < tolerance:
			break
		
		# Calculate derivative f'(t)
		var velocity_term := delta_v + 2.0 * a * t
		var df := projectile_speed - (target_pos_t.dot(velocity_term)) / distance
		
		# Newton-Raphson update
		t -= f / df if abs(df) > 1e-6 else 0.0  # Avoid division by zero
	
	var interseption_delta_p := delta_p + delta_v * t + a * t * t
	return interseption_delta_p
