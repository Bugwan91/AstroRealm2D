class_name ShipControlData
extends Resource

const THRESHOLD := 0.001

var boost: float
var strafe: Vector2
var direction: Vector2

func is_boost_zero() -> bool:
	return boost > THRESHOLD

func is_strafe_zero() -> bool:
	return abs(strafe) > THRESHOLD

func is_direction_zero() -> bool:
	return direction.is_zero_approx()
