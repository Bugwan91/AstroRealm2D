extends Node
class_name ShipFlightAssistant

var enabled: bool = false

enum Action {STOP, LOOK_TO}

@onready var thrusters: Thrusters = %Thrusters
@onready var main_engine: Thruster = %MainEngine
@onready var input_reader: ShipInputReader = %InputReader

var _input_data: ShipInputData

func _ready():
	_input_data = input_reader.input_data

func _process(_delta):
	if not enabled:
		_direct_control()

func _direct_control():
	main_engine.throttle = _input_data.main
	thrusters.apply(Thrusters.FORWARD, _input_data.forward)
	thrusters.apply(Thrusters.BACK, _input_data.back)
	thrusters.apply(Thrusters.LEFT, _input_data.left)
	thrusters.apply(Thrusters.RIGHT, _input_data.right)
	thrusters.apply(Thrusters.TURN_LEFT, _input_data.turn_left)
	thrusters.apply(Thrusters.TURN_RIGHT, _input_data.turn_right)
