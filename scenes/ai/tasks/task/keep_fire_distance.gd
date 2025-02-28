@tool
class_name BTKeepFireDistance
extends BTAction

@export var position_key: StringName = &"position"
@export var target_position_key: StringName = &"position"
@export var weapon_range_key: StringName = &"weapon_range"
@export var threshold := 10.0

func _generate_name() -> String:
	return "Keep optimal distance for attack"

func _setup() -> void:
	pass

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _tick(delta: float) -> Status:
	if not blackboard.get_parent().has_var(target_position_key):
		return Status.FAILURE
	var target_position: Vector2 = blackboard.get_parent().get_var(target_position_key)
	var position: Vector2 = blackboard.get_var(position_key)
	var range: float = blackboard.get_var(weapon_range_key)
	var delta_p := target_position - position
	var dist := delta_p.length()
	if abs(dist - range) < threshold:
		return Status.RUNNING # SUCCESS?
	var strafe_dir := delta_p / dist
	strafe_dir *= 1.0 if dist > range else -1.0
	(agent as AIShipInput).move(2.0 * strafe_dir * absf(dist - range) / range)
	return Status.RUNNING
