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
	p: Vector2,
	v: Vector2,
	p_t: Vector2,
	v_t: Vector2,
	a: Vector2,
	projectile_speed: float,
	tolerance: float = 1.0,
	max_iterations: int = 10
) -> Vector2:
	var delta_p := p_t - p
	if projectile_speed == 0.0:
		return p_t - p
	var delta_v := v_t - v
	var d := delta_p.length()
	if d < 1e-6:
		return Vector2.ZERO  # Already on target
	
	var dir_to_target = delta_p / d
	
	# Closing speed = projectile speed - target velocity along LOS
	var closing_speed = projectile_speed - delta_v.dot(dir_to_target)
	
	# Handle negative/zero closing speed (target moving away faster)
	var t_guess = d / max(closing_speed, projectile_speed * 0.1)
	
	# 2. Newton-Raphson iterations
	var t = t_guess
	var converged = false
	
	for i in range(max_iterations):
		# Target position at time t (with acceleration)
		var target_pos_t = delta_p + delta_v * t + 0.5 * a * t * t
		var current_distance = target_pos_t.length()
		
		# Function root: projectile travel distance = intercept distance
		var f = projectile_speed * t - current_distance
		
		if abs(f) < tolerance:
			converged = true
			break
			
		# Derivative calculation
		var velocity_term = delta_v + a * t
		var df = projectile_speed - target_pos_t.dot(velocity_term) / current_distance
		
		# Prevent division by zero and NaN
		if abs(df) < 1e-6 || current_distance < 1e-6:
			break
		
		# Newton update with time clamping
		t = max(t - f / df, 0.0)
	
	return delta_p + delta_v * t + 0.5 * a * t * t
