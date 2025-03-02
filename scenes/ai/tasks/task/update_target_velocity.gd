@tool
class_name BTUpdateTargetVelocity
extends BTAction

@export var velocity_key: StringName = &"velocity"
@export var target_velocity_key: StringName = &"target_velocity"

func _generate_name() -> String:
	return "Update target vellocity"

func _tick(_delta: float) -> Status:
	if not is_instance_valid(blackboard.get_parent()):
		return Status.FAILURE
	var v: Vector2 = blackboard.get_parent().get_var(velocity_key)
	blackboard.set_var(target_velocity_key, v)
	return SUCCESS
