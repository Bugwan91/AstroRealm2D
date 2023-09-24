extends RigidBody2D

class_name ShipRigidBody

@export var _main_thrust := 200.0
@export var _maneuver_thrust := 50.0
@export var _velocity_limit := 1000.0

@onready var _thrusters: Thrusters = %Thrusters
@onready var _main_state = get_node("/root/MainState")
@onready var engine: Thruster = $Hull/Engine/MainEngine

enum CONTROL {DIRECT, ASSIST}
var _control := CONTROL.DIRECT

var _reset := false

func _ready():
	_thrusters.setup(_maneuver_thrust)
	engine.setup(_main_thrust)

func _process(delta):
	_update_main_state(delta)
	#DebugDraw2d.line(global_position, global_position + 0.2 * linear_velocity, Color.GREEN, 2)
	_reset = Input.is_action_pressed("Reset")

func _input(event):
	if event.is_action_pressed("autopilot"):
		_control = CONTROL.ASSIST if _control == CONTROL.DIRECT else CONTROL.DIRECT

func _physics_process(delta):
	for force: Force in _thrusters.forces:
		if not force.ignore():
			apply_force(force.force.rotated(rotation), force.position.rotated(rotation))
	apply_central_force(Vector2(engine.force._scalar, 0).rotated(rotation))

func _integrate_forces(state):
	if _reset:
		state.transform = Transform2D()
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		_reset = false
	var state_velocity = state.linear_velocity
	if state_velocity.length() > _velocity_limit:
		state.linear_velocity = state_velocity.normalized() * _velocity_limit

# TODO: Refactor
# Data to main state (UI connection)
var _previous_speed = 0
var _time_delta = 0

func _update_main_state(delta):
	var speed = linear_velocity.length()
	_main_state.ship_position = position
	_main_state.ship_speed = speed
	_time_delta += delta
	if _time_delta >= 0.5:
		_main_state.ship_acceleration = (speed - _previous_speed) / 0.5
		_time_delta = 0
		_previous_speed = speed
