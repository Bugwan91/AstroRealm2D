@tool
class_name BTUpdateFirePosition
extends BTAction

@export var position_key: StringName = &"position"
@export var target_position_key: StringName = &"target_position"
@export var weapon_range_key: StringName = &"weapon_range"
@export_range(0, 1) var extra_close: float = 1.0

func _generate_name() -> String:
	return "Update fire position on optimal fire range from target"

func _tick(delta: float) -> Status:
	var parent := blackboard.get_parent()
	if not is_instance_valid(parent):
		return FAILURE
	var p: Vector2 = blackboard.get_var(position_key)
	var p_t: Vector2 = parent.get_var(position_key)
	var d := p_t - p
	var range: float = blackboard.get_var(weapon_range_key)
	var t := d - d.normalized() * range * extra_close
	blackboard.set_var(target_position_key, p + t)
	return SUCCESS
