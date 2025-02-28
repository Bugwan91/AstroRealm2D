class_name ShipInputData
extends Resource

signal boost_changed(value: float)
signal strafe_changed(value: Vector2)
signal dodge_changed(value: bool)
signal dodging_updated(value: bool)
signal stop_changed(value: bool)
signal target_changed(value: RadarItem)
signal target_point_changed(value: Vector2)
signal is_follow_toggled(value: bool)
signal follow_distance_changed(value: float)
signal is_autopilot_toggled(value: bool)
signal autopilot_target_changed(value: Vector2)
signal autopilot_speed_changed(value: float)
signal firing_toggled(value: bool)
signal auto_aim_toggled(value: bool)

var use_absolute := true
var boost: float:
	set(value):
		boost = clampf(value, -1.0, 1.0)
		boost_changed.emit(boost)

var strafe: Vector2:
	set(value):
		var _len := value.length()
		strafe = value if _len < 1.0 else value / _len
		strafe_changed.emit(strafe)

var dodge: bool:
	set(value):
		if dodge == value: return
		dodge = value
		if dodge:
			dodging = true
		dodge_changed.emit(dodge)

var dodging: bool:
	set(value):
		if dodging == value: return
		dodging = value
		dodging_updated.emit(dodging)

var stop: bool:
	set(value):
		if stop == value: return
		stop = value
		stop_changed.emit(stop)

var target_point: Vector2:
	set(value):
		target_point = value
		target_point_changed.emit(target_point)

var target: RadarItem:
	set(value):
		target = value
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
