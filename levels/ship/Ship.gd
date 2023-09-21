extends RigidBody2D

class_name Ship

@export var _engine_thrust: float
@export var _maneuver_thrust: float

@onready var _thrusters: Thrusters = $Thrusters
@onready var _main_state = get_node("/root/MainState")

var _forces: Array[Force] = []

var _previous_speed = 0
var _time_delta = 0

func _ready():
	_thrusters.setup(_engine_thrust, _maneuver_thrust)
	_init_thruster_forces()

func _process(delta):
	_update_main_state(delta)

func _physics_process(delta):
	for force in _forces:
		#var force = _forces[id] as Force
		if force.force.length() != 0:
			apply_force(force.force, force.position)

func _init_thruster_forces():
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

func _update_main_state(delta):
	var speed = linear_velocity.length()
	_main_state.ship_position = position
	_main_state.ship_speed = speed
	_time_delta += delta
	if _time_delta >= 0.1:
		_main_state.ship_acceleration = (speed - _previous_speed) / 0.1
		_time_delta = 0
		_previous_speed = speed

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

class Force:
	var position: Vector2 = Vector2.ZERO
	var force: Vector2 = Vector2.ZERO
