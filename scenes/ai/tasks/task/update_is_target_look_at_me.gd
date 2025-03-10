@tool
class_name BTUpdateIsTargetLookAtMe
extends BTAction

@export var position_key: StringName = &"position"
@export var transform_key: StringName = &"transform"
@export var target_look_at_me_angle_key: StringName = &"target_look_at_me_angle_key"
@export var is_target_look_at_me_key: StringName = &"is_target_look_at_me"
@export var is_firing_key: StringName = &"is_firing"
@export var is_target_firing_key: StringName = &"is_target_firing"
@export var distance_to_target_key: StringName = &"distance_to_target"

@export var angle_threshold: float = 0.2

func _generate_name() -> String:
	return "Check is target look at me"

func _tick(delta: float) -> Status:
	var parent := blackboard.get_parent()
	if not is_instance_valid(parent):
		return FAILURE
	var position: Vector2 = blackboard.get_var(position_key)
	var target_transform: Transform2D = parent.get_var(transform_key)
	var target_position := target_transform.origin
	var target_forward := target_transform.x
	var dir_from_target := position - target_position
	var angle := absf(target_forward.angle_to(dir_from_target))
	blackboard.set_var(target_look_at_me_angle_key, angle)
	blackboard.set_var(is_target_look_at_me_key, abs(angle) < angle_threshold)
	blackboard.set_var(is_target_firing_key, parent.get_var(is_firing_key))
	blackboard.set_var(distance_to_target_key, dir_from_target.length())
	return SUCCESS
