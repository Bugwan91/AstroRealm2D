@tool
class_name BTDodge
extends BTAction

@export var dodging_key: StringName = &"dodging"

var _dodge_started := false

func _generate_name() -> String:
	return "Dodge"

func _tick(delta: float) -> Status:
	var is_dodging: bool = blackboard.get_var(dodging_key)
	if is_dodging:
		return RUNNING
	elif _dodge_started:
		_dodge_started = false
		return SUCCESS
	(agent as AIShipInput).dodge()
	_dodge_started = true
	return RUNNING
