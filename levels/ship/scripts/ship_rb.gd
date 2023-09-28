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
	#DebugDraw2d.line(global_position, global_position + 0.2 * linear_velocity, Color.GREEN, 2)
	_reset = Input.is_action_pressed("Reset")

func _physics_process(delta):
	if Input.is_action_just_pressed("burst_left"):
		apply_central_impulse(Vector2(0, -40).rotated(rotation))
	if Input.is_action_just_pressed("burst_right"):
		apply_central_impulse(Vector2(0, 40).rotated(rotation))
	_apply_engine_force()
	_apply_thrusters_forces()
	_apply_drag()

func _integrate_forces(state):
	_reset_ship(state)

func _reset_ship(state: PhysicsDirectBodyState2D):
	if _reset:
		state.transform = Transform2D()
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0
		_reset = false

func _apply_thrusters_forces():
	for force: Force in _thrusters.forces:
		if not force.ignore():
			apply_force(force.force.rotated(rotation), force.position.rotated(rotation))

func _apply_engine_force():
	apply_central_force(Vector2(engine.force._scalar, 0).rotated(rotation))

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
