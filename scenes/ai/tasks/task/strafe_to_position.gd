@tool
class_name BTStrafeToPosition
extends BTAction

@export var position_key: StringName = &"position"
@export var velocity_key: StringName = &"velocity"
@export var target_position_key: StringName = &"target_position"
@export var target_velocity_key: StringName = &"target_velocity"
@export var target_acceleration_key: StringName = &"target_acceleration"
@export var strafe_key: StringName = &"strafe"
@export var position_threshold := 100.0
@export var velocity_threshold := 10.0

var _v_threshold_sq: float

func _generate_name() -> String:
	return "Move to point"

func _enter() -> void:
	_v_threshold_sq = velocity_threshold * velocity_threshold

func _tick(delta: float) -> Status:
	if not blackboard.has_var(target_position_key):
		return Status.FAILURE
	var p: Vector2 = blackboard.get_var(position_key)
	var v: Vector2 = blackboard.get_var(velocity_key)
	var p_target: Vector2 = blackboard.get_var(target_position_key)
	var v_target: Vector2 = blackboard.get_var(target_velocity_key, Vector2.ZERO, false)
	var a_target: Vector2 = blackboard.get_var(target_acceleration_key, Vector2.ZERO, false)
	var d_p := p_target - p
	var d_v := v_target - v
	if d_p.length() < position_threshold\
		and d_v.length_squared() < _v_threshold_sq:
		return SUCCESS
	var strafe: float = blackboard.get_var(strafe_key)
	MyDebug.info("strafe", strafe)
	var v_stop := ControlUnils.get_stop_velocity(d_p, d_v, strafe, a_target)
	var controls := ControlUnils.match_velocity_control(v_stop - v, strafe * delta)
	(agent as AIShipInput).move(controls)
	return RUNNING
