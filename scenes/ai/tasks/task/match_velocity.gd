@tool
class_name BTmatchVeclocity
extends BTAction

@export var velocity_key: StringName = &"linear_velocity"
@export var target_velocity_key: StringName = &"linear_velocity"
@export var strafe_key: StringName = &"strafe"
@export var threshold := 100.0
@export_range(0, 1) var smooth := 0.5

func _generate_name() -> String:
	return "Match velocity with target"

func _setup() -> void:
	pass

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(delta: float) -> Status:
	if not (is_instance_valid(blackboard.get_parent())\
	and blackboard.get_parent().has_var(target_velocity_key)):
		return Status.FAILURE
	var target_velocity: Vector2 = blackboard.get_parent().get_var(target_velocity_key)
	var velocity: Vector2 = blackboard.get_var(velocity_key)
	var strafe: float = blackboard.get_var(strafe_key)
	var dv := target_velocity - velocity
	var dv_len := dv.length()
	if dv_len > threshold:
		var dv_n := dv / dv_len
		var a := delta * strafe
		if a == 0:
			return Status.RUNNING
		var f := (dv_len / a) * smooth
		(agent as AIShipInput).move(f * dv_n)
	return Status.RUNNING
