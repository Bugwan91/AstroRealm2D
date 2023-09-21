extends RigidBody2D

class_name Ship

@export var _main_thrust: float = 100
@export var _maneuver_thrust: float = 50

@onready var _thrusters: Thrusters = $Thrusters
@onready var _main_state = get_node("/root/MainState")

var _forces: Array[Force] = []

var _previous_speed = 0
var _time_delta = 0

func _ready():
	_init_thrusters()

func _process(delta):
	_update_main_state(delta)

func _physics_process(delta):
	for force in _forces:
		if force.force.length() != 0:
			apply_force(force.force, force.position)

func _init_thrusters():
	_thrusters.setup(_main_thrust, _maneuver_thrust)
	_forces.resize(9)
	_forces[Thrusters.ID.MAIN] = Force.new()
	_forces[Thrusters.ID.FL] = Force.new()
	_forces[Thrusters.ID.FR] = Force.new()
	_forces[Thrusters.ID.RF] = Force.new()
	_forces[Thrusters.ID.RB] = Force.new()
	_forces[Thrusters.ID.BR] = Force.new()
	_forces[Thrusters.ID.BL] = Force.new()
	_forces[Thrusters.ID.LB] = Force.new()
	_forces[Thrusters.ID.LF] = Force.new()

func _add_force(id: int, position: Vector2, force: Vector2):
	_forces[id].position = position.rotated(rotation)
	_forces[id].force = force.rotated(rotation)

func _on_main_engine_input(value):
	_thrusters.apply(Thrusters.Action.MAIN, value)

func _on_forward_input(value):
	_thrusters.apply(Thrusters.Action.FORWARD, value)

func _on_back_input(value):
	_thrusters.apply(Thrusters.Action.BACK, value)

func _on_left_input(value):
	_thrusters.apply(Thrusters.Action.LEFT, value)

func _on_right_input(value):
	_thrusters.apply(Thrusters.Action.RIGHT, value)

func _on_turn_left_input(value):
	_thrusters.apply(Thrusters.Action.TURN_LEFT, value)

func _on_turn_right_input(value):
	_thrusters.apply(Thrusters.Action.TURN_RIGHT, value)

func _update_main_state(delta):
	var speed = linear_velocity.length()
	_main_state.ship_position = position
	_main_state.ship_speed = speed
	_time_delta += delta
	if _time_delta >= 0.5:
		_main_state.ship_acceleration = (speed - _previous_speed) / 0.5
		_time_delta = 0
		_previous_speed = speed

class Force:
	var position: Vector2 = Vector2.ZERO
	var force: Vector2 = Vector2.ZERO
