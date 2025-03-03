@tool
class_name BTUpdateTargetVelocity
extends BTAction

@export var velocity_key: StringName = &"velocity"
@export var acceleration_key: StringName = &"acceleration"
@export var target_velocity_key: StringName = &"target_velocity"
@export var target_velocity_new_key: StringName = &"target_velocity_new"
@export var target_acceleration_key: StringName = &"target_acceleration"
@export var target_acceleration_new_key: StringName = &"target_acceleration_new"

func _generate_name() -> String:
	return "Update target velocity"

func _tick(delta: float) -> Status:
	var parent := blackboard.get_parent()
	if not is_instance_valid(parent):
		return FAILURE
	var v: Vector2 = parent.get_var(velocity_key, Vector2.ZERO, false)
	if blackboard.has_var(target_velocity_key):
		blackboard.set_var(
			target_velocity_key,
			blackboard.get_var(target_velocity_new_key, Vector2.ZERO, false))
	else:
		blackboard.set_var(target_velocity_key, v)
	blackboard.set_var(target_velocity_new_key, v)
	var a: Vector2 = parent.get_var(acceleration_key, Vector2.ZERO, false)
	if blackboard.has_var(target_acceleration_key):
		blackboard.set_var(
			target_acceleration_key,
			blackboard.get_var(target_acceleration_new_key, Vector2.ZERO, false)
		)
	else:
		blackboard.set_var(target_acceleration_key, v)
	blackboard.set_var(target_acceleration_new_key, a)
	return SUCCESS
