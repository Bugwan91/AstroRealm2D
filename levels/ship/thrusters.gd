extends Node2D

class_name Thrusters

enum ID {MAIN, FL, FR, RF, RB, BR, BL, LB, LF}
enum Action {MAIN, FORWARD, BACK, RIGHT, LEFT, TURN_LEFT, TURN_RIGHT}

var _thrusters: Array[Thruster] = []
var _strafe_thrusters: Array[float] = []
var _rotation_thrusters: Array[float] = []

func setup(thrust: float, manuever_thrust: float):
	_thrusters.resize(9)
	_strafe_thrusters.resize(9)
	_rotation_thrusters.resize(9)
	_thrusters[ID.MAIN] = $Main.setup(ID.MAIN, thrust)
	_thrusters[ID.FL] = $FL.setup(ID.FL, manuever_thrust)
	_thrusters[ID.FR] = $FR.setup(ID.FR, manuever_thrust)
	_thrusters[ID.RF] = $RF.setup(ID.RF, manuever_thrust)
	_thrusters[ID.RB] = $RB.setup(ID.RB, manuever_thrust)
	_thrusters[ID.BR] = $BR.setup(ID.BR, manuever_thrust)
	_thrusters[ID.BL] = $BL.setup(ID.BL, manuever_thrust)
	_thrusters[ID.LB] = $LB.setup(ID.LB, manuever_thrust)
	_thrusters[ID.LF] = $LF.setup(ID.LF, manuever_thrust)

func apply(action: int, value: float):
	match action:
		Action.MAIN:
			_strafe(ID.MAIN, value)
		Action.FORWARD:
			_strafe(ID.BR, value)
			_strafe(ID.BL, value)
		Action.BACK:
			_strafe(ID.FR, value)
			_strafe(ID.FL, value)
		Action.LEFT:
			_strafe(ID.RF, value)
			_strafe(ID.RB, value)
		Action.RIGHT:
			_strafe(ID.LF, value)
			_strafe(ID.LB, value)
		Action.TURN_LEFT:
			_rotate(ID.FL, value)
			_rotate(ID.RF, value)
			_rotate(ID.BR, value)
			_rotate(ID.LB, value)
		Action.TURN_RIGHT:
			_rotate(ID.FR, value)
			_rotate(ID.RB, value)
			_rotate(ID.BL, value)
			_rotate(ID.LF, value)

func _strafe(id: int, value: float):
	_strafe_thrusters[id] = value
	if _rotation_thrusters[id] == 0:
		_thrusters[id].throttle(value)

func _rotate(id: int, value: float):
	_rotation_thrusters[id] = value
	if _strafe_thrusters[id] == 0:
		_thrusters[id].throttle(value)
