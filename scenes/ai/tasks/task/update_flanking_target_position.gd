@tool
class_name BTUpdateFlankingTargetPosition
extends BTAction

@export var position_key: StringName = &"position"
@export var target_position_key: StringName = &"target_position"
@export var weapon_range_key: StringName = &"weapon_range"
@export var transform_key: StringName = &"transform"
@export_range(0, 1) var extra_close: float = 1.0
@export_range(0, PI) var flank_angle: float = 2.0

func _generate_name() -> String:
	return "Flank target"

func _tick(delta: float) -> Status:
	var parent := blackboard.get_parent()
	if not is_instance_valid(parent):
		return FAILURE
	var position: Vector2 = blackboard.get_var(position_key)
	var target_transform: Transform2D = parent.get_var(transform_key)
	var range: float = blackboard.get_var(weapon_range_key)
	var target_position := target_transform.origin
	var target_forward := target_transform.x
	var dir_from_target := position - target_position
	var angle_sign := signf(target_forward.angle_to(dir_from_target))
	var flank_dir := target_forward.rotated(flank_angle * angle_sign)
	var flank_point := flank_dir * range * extra_close + target_position
	blackboard.set_var(target_position_key, flank_point)
	return SUCCESS
