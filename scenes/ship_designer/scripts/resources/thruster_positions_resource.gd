@tool
class_name ThrusterPositionsResource
extends PointResource

enum Direction {
	FRONT_LEFT,
	FRONT_RIGHT,
	RIGHT_FRONT,
	LEFT_FRONT,
	RIGHT_BACK,
	LEFT_BACK,
	BACK_LEFT,
	BACK_RIGHT
}

@export var direction: Direction = Direction.LEFT_FRONT:
	set(value):
		direction = value
		rotation = _get_rotation_for_direction(direction)

func _get_rotation_for_direction(direction: Direction) -> float:
	match direction:
		Direction.FRONT_LEFT, Direction.FRONT_RIGHT: return 90.0
		Direction.RIGHT_FRONT, Direction.RIGHT_BACK: return 180.0
		Direction.LEFT_FRONT, Direction.LEFT_BACK: return 0.0
		Direction.BACK_LEFT, Direction.BACK_RIGHT: return -90.0
		_: return 0.0

func is_match(thruster: ThrusterPositionsResource) -> bool:
	return thruster.direction == direction

