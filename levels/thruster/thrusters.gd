extends Node2D
class_name Thrusters

enum { FORWARD, BACK, RIGHT, LEFT, TURN_LEFT, TURN_RIGHT }
var _thrusters = { FORWARD: [], BACK: [], RIGHT: [], LEFT: [], TURN_LEFT: [], TURN_RIGHT: [] }
#var _power_map = { FORWARD: 0, BACK: 0, RIGHT: 0, LEFT: 0, TURN_LEFT: 0, TURN_RIGHT: 0 }
var _action_map = {
	FORWARD: ManeuverThruster.TYPE.STRAFE,
	BACK: ManeuverThruster.TYPE.STRAFE,
	LEFT: ManeuverThruster.TYPE.STRAFE,
	RIGHT: ManeuverThruster.TYPE.STRAFE,
	TURN_LEFT: ManeuverThruster.TYPE.ROTATE,
	TURN_RIGHT: ManeuverThruster.TYPE.ROTATE
}
const TORQUE_IGNORE_ZONE = 0.01
const DEADZONE = 0.001

var forces: Array[Force]

func setup(thrust: float):
	_thrusters = { FORWARD: [], BACK: [], RIGHT: [], LEFT: [], TURN_LEFT: [], TURN_RIGHT: [] }
	var thrusters = get_children() as Array[ManeuverThruster]
	for thruster in thrusters:
		thruster.setup(thrust)
		forces.append(thruster.force)
		_setup_rotation(thruster)
		_setup_strafe(thruster)
	calibrate()

func _setup_rotation(thruster: ManeuverThruster):
	if thruster.torque > TORQUE_IGNORE_ZONE:
		_thrusters[TURN_RIGHT].append(thruster)
	elif thruster.torque < -TORQUE_IGNORE_ZONE:
		_thrusters[TURN_LEFT].append(thruster)

func _setup_strafe(thruster: ManeuverThruster):
	var direction = thruster.transform.x
	if direction.x > DEADZONE:
		_thrusters[FORWARD].append(thruster)
	elif direction.x < -DEADZONE:
		_thrusters[BACK].append(thruster)
	elif direction.y > DEADZONE:
		_thrusters[RIGHT].append(thruster)
	elif direction.y < -DEADZONE:
		_thrusters[LEFT].append(thruster)

func calibrate():
	calibrate_strafe()
	calibrate_rotation()

func calibrate_strafe():
	for action in _action_map:
		if _action_map[action] == ManeuverThruster.TYPE.STRAFE:
			_calibrate_strafe(action)

func _calibrate_strafe(type):
	var torque_pos := 0.0
	var torque_neg := 0.0
	for thruster: ManeuverThruster in _thrusters[type]:
		if thruster.torque > TORQUE_IGNORE_ZONE:
			torque_pos += abs(thruster.torque)
		elif thruster.torque < -TORQUE_IGNORE_ZONE:
			torque_neg += abs(thruster.torque)
	if abs(torque_pos - torque_neg) < TORQUE_IGNORE_ZONE:
		return
		
	for thruster: ManeuverThruster in _thrusters[type]:
		var value = 1 - min(torque_pos, torque_neg) / max(torque_pos, torque_neg)
		printt("diff: ", value)

func calibrate_rotation():
	for action in _action_map:
		if _action_map[action] == ManeuverThruster.TYPE.ROTATE:
			_calibrate_rotation(action)

func _calibrate_rotation(type):
	for thruster: ManeuverThruster in _thrusters[type]:
		pass

func apply(type, value: float):
	for thruster in _thrusters[type] as Array[ManeuverThruster]:
		thruster.apply_throttle(_action_map[type], value)
