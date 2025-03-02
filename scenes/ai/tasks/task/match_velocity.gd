@tool
class_name BTMatchVeclocity
extends BTAction

@export var velocity_key: StringName = &"velocity"
@export var target_velocity_key: StringName = &"target_velocity"
@export var strafe_key: StringName = &"strafe"
@export var velocity_threshold := 1.0

var _v_threshold_sq: float

func _generate_name() -> String:
	return "Match velocity"

func _enter() -> void:
	_v_threshold_sq = velocity_threshold * velocity_threshold

func _tick(delta: float) -> Status:
	if not blackboard.has_var(target_velocity_key):
		return FAILURE
	var v: Vector2 = blackboard.get_var(velocity_key)
	var v_target: Vector2 = blackboard.get_var(target_velocity_key)
	var d_v := v_target - v
	if d_v.length_squared() < _v_threshold_sq:
		return SUCCESS
	var strafe: float = blackboard.get_var(strafe_key)
	var controls := ControlUnils.match_velocity_control(d_v, strafe * delta)
	(agent as AIShipInput).move(controls)
	return RUNNING
