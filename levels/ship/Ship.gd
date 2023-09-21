extends RigidBody2D

class_name Ship

@export var _main_thrust: float = 100
@export var _maneuver_thrust: float = 50
@export var _velocity_limit: float = 1000

@onready var _thrusters: Thrusters = $Thrusters
@onready var _main_state = get_node("/root/MainState")

var _thrusters_forces: Array[Force] = []

var _previous_speed = 0
var _time_delta = 0

func _ready():
	_init_thrusters()

func _process(delta):
	_update_main_state(delta)
	#DebugDraw2d.line(global_position, global_position + 0.2 * linear_velocity, Color.GREEN, 2)

func _physics_process(delta):
	if _has_forces():
		_apply_forces(delta)

func _integrate_forces(state):
	_limit_velocity(state)

func _init_thrusters():
	_thrusters.setup(_main_thrust, _maneuver_thrust)
	_thrusters_forces.resize(9)
	_thrusters_forces[Thrusters.ID.MAIN] = Force.new()
	_thrusters_forces[Thrusters.ID.FL] = Force.new()
	_thrusters_forces[Thrusters.ID.FR] = Force.new()
	_thrusters_forces[Thrusters.ID.RF] = Force.new()
	_thrusters_forces[Thrusters.ID.RB] = Force.new()
	_thrusters_forces[Thrusters.ID.BR] = Force.new()
	_thrusters_forces[Thrusters.ID.BL] = Force.new()
	_thrusters_forces[Thrusters.ID.LB] = Force.new()
	_thrusters_forces[Thrusters.ID.LF] = Force.new()

func _has_forces():
	for thruster in _thrusters_forces:
		if thruster.force.length() > 0:
			return true
	return false

func _limit_velocity(state: PhysicsDirectBodyState2D):
	var state_velocity = state.linear_velocity
	if state_velocity.length() > _velocity_limit:
		state.linear_velocity = state_velocity.normalized() * _velocity_limit

func _apply_forces(delta: float):
	for thruster in _thrusters_forces:
		if thruster.force.length() != 0:
			apply_force(thruster.force.rotated(rotation), thruster.position.rotated(rotation))

func _add_force(id: int, position: Vector2, force: Vector2):
	_thrusters_forces[id].position = position
	_thrusters_forces[id].force = force

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
