class_name ShipInputData
extends Resource

signal boost_changed(float)
signal strafe_changed(Vector2)
signal stop_changed(bool)
signal target_changed(Spaceship)
signal target_point_changed(Vector2)
signal is_follow_toggled(bool)
signal follow_distance_changed(float)
signal is_autopilot_toggled(bool)
signal autopilot_target_changed(Vector2)
signal autopilot_speed_changed(float)
signal firing_toggled(bool)
signal auto_aim_toggled(bool)

var boost: float:
	set(value):
		boost = clampf(value, -1.0, 1.0)
		boost_changed.emit(boost)

var strafe: Vector2:
	set(value):
		var len := value.length()
		strafe = value if len < 1.0 else value / len
		strafe_changed.emit(strafe)

var stop: bool:
	set(value):
		if stop == value: return
		stop = value
		stop_changed.emit(stop)

var target_point: Vector2:
	set(value):
		target_point = value
		target_point_changed.emit(target_point)

var target: Spaceship:
	set(value):
		target = value
		MainState.player_target = target
		target_changed.emit(target)

var is_follow: bool:
	set(value):
		if is_follow == value: return
		is_follow = value
		if is_follow and is_autopilot: is_autopilot = false
		is_follow_toggled.emit(is_follow)

var follow_distance: float:
	set(value):
		follow_distance = clampf(value, 0.0, 10000.0)
		follow_distance_changed.emit(follow_distance)

var is_autopilot: bool:
	set(value):
		if is_autopilot == value: return
		is_autopilot = value
		if is_autopilot and is_follow: is_follow = false
		is_autopilot_toggled.emit(is_autopilot)

var autopilot_target: Vector2:
	set(value):
		autopilot_target = value
		autopilot_target_changed.emit(autopilot_target)

var autopilot_speed: float:
	set(value):
		autopilot_speed = clampf(value, 0.0, 10000.0)
		autopilot_speed_changed.emit(autopilot_speed)

var fire: bool:
	set(value):
		if fire == value: return
		fire = value
		firing_toggled.emit(fire)

var auto_aim: bool:
	set(value):
		if auto_aim == value: return
		auto_aim = value
		auto_aim_toggled.emit(auto_aim)
