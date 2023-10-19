class_name ShipRigidBody
extends RigidBody2D

@export_range(0, 500) var _main_thrust := 200.0
@export_range(0, 100) var _maneuver_thrust := 50.0
@export_range(0, 2000) var max_speed := 1000.0
@export_range(0, 500) var _flight_assistant_error := 0.0

@onready var position_extrapolation: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters
@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant
@onready var battle_assistant: BattleAssistant = %BattleAssistant

@onready var gun = $PositionExtrapolation/Gun as Gun
@onready var _main_state = get_node("/root/MainState")

var inverse_inertia := 0.0

var _reset := false

var extrapolated_position: Vector2 :
	get:
		return position + position_extrapolation.position.rotated(rotation)

func _ready():
	thrusters.setup(_maneuver_thrust)
	engines.setup(_main_thrust, max_speed)
	flight_assistant.setup(_flight_assistant_error)

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
	flight_assistant.target_body = target
	battle_assistant.set_target(target)

func reset_target():
	flight_assistant.target_body = null
	battle_assistant.set_target(null)

func _input(event):
	if event.is_action_pressed("fire"):
		gun.start_fire()
	elif event.is_action_released("fire"):
		gun.stop_fire()

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
