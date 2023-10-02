extends RigidBody2D

class_name ShipRigidBody

@export var _main_thrust := 200.0
@export var _maneuver_thrust := 50.0
@export var _velocity_limit := 1000.0

@onready var _thrusters: Thrusters = %Thrusters
@onready var _main_state = get_node("/root/MainState")
@onready var engine: Thruster = %MainEngine

var _reset := false

func _ready():
	_thrusters.setup(_maneuver_thrust)
	engine.setup(_main_thrust)

func _process(delta):
	_update_main_state(delta)
	_reset = Input.is_action_pressed("Reset")

func _physics_process(delta):
	_apply_engine_force()
	_apply_thrusters_forces()
	_apply_thrusters_torque()
	_apply_drag()
	
	if Input.is_action_just_pressed("burst_left"):
		apply_central_impulse(Vector2(0, -40).rotated(rotation))
	if Input.is_action_just_pressed("burst_right"):
		apply_central_impulse(Vector2(0, 40).rotated(rotation))

func _integrate_forces(state):
	_reset_ship(state)

func _reset_ship(state: PhysicsDirectBodyState2D):
	if _reset:
		state.transform = Transform2D()
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		_reset = false

func _apply_thrusters_forces():
	apply_central_force(_thrusters.force.rotated(rotation))

func _apply_thrusters_torque():
	apply_torque(_thrusters.torque)

func _apply_engine_force():
	apply_central_force(engine.force.rotated(rotation))

func _apply_drag():
	var delta = linear_velocity.length() - _velocity_limit
	if delta > 0:
		apply_central_force(-delta * linear_velocity.normalized())

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
