class_name AISDummyhipInput
extends ShipInput

@export var points: Array[Vector2]

@onready var ship: ShipRigidBody
@onready var timer = $Timer

var current_point: int = 0

func init(_ship: ShipRigidBody):
	ship = _ship
	ship.flight_assistant.is_autopilot = true
	ship.flight_assistant.is_autopilot_stop = false
	ship.flight_assistant._autopilot_target_position = points[0]
	timer.timeout.connect(_next_point)
	timer.start()

func _next_point():
	current_point += 1
	current_point = current_point if current_point < points.size() else 0
	ship.flight_assistant._autopilot_target_position = points[current_point]
