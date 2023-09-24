extends Node
class_name Force

var position: Vector2
var direction: Vector2
var _scalar: float = 0
var force: Vector2 = Vector2.ZERO
const IGNORE_DEADZONE = 0.001

func _init(pos: Vector2, dir: Vector2):
	position = pos
	direction = dir.normalized()

func set_strenght(value: float):
	_scalar = value
	force = direction * value

func ignore() -> bool:
	return _scalar < IGNORE_DEADZONE
