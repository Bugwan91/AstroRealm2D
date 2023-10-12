class_name ShipRigidBody
extends RigidBody2D

@export var _main_thrust := 200.0
@export var _maneuver_thrust := 50.0
@export var _velocity_limit := 1000.0
@onready var _main_state = get_node("/root/MainState")
@onready var _thrusters: Thrusters = %Thrusters
@onready var _engines: Engines = %Engines
@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant

var _reset := false

var inverse_inertia := 0.0

func _ready():
	_thrusters.setup(_maneuver_thrust)
	_engines.setup(_main_thrust, _velocity_limit)

func _process(delta):
	_update_main_state(delta)
	_reset = Input.is_action_pressed("Reset")
	if Input.is_action_pressed("target_reset"):
		reset_target()

func _integrate_forces(state):
	_reset_ship(state)
	inverse_inertia = state.inverse_inertia

func _reset_ship(state: PhysicsDirectBodyState2D):
	if _reset:
		state.transform = Transform2D()
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		_reset = false

func set_target(target: RigidBody2D):
	flight_assistant.target_changed(target)

func reset_target():
	flight_assistant.target_changed(null)

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
