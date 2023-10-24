class_name ShipRigidBody
extends RigidBody2D

@export var _texture: Texture2D
@export var inputs: ShipInput
@export var gun_scene: PackedScene
@export_range(0, 10000) var max_speed := 250.0
@export_range(0, 1000) var _main_thrust := 500.0
@export_range(0, 500) var _maneuver_thrust := 200.0

@export_range(0, 1) var _FA_accuracy := 1.0
@export_range(0, 10) var _FA_accuracy_damp := 0.1
@export_range(0, 1) var _BA_accuracy := 1.0
@export_range(0, 10) var _BA_accuracy_damp := 0.1
@export var flight_assistant: ShipFlightAssistant
@export var autopilot_pointer: AssistantPointer
@export var battle_assistant: BattleAssistant
@export var target_prediction_pointer: AssistantPointer

@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters


@onready var _view = %View
@onready var _gun_slot = %GunSlot

var gun: Gun
var real_velocity: Vector2: get = _real_velocity

var _forces := Vector2.ZERO
var _torque := 0.0

func _ready():
	if inputs is PlayerShipInput:
		FloatingOrigin.target = self
		MainState.player_ship = self
	thrusters.setup(_maneuver_thrust)
	engines.setup(_main_thrust, max_speed)
	flight_assistant.setup()
	flight_assistant.follow_accuracy = _FA_accuracy
	flight_assistant.follow_accuracy_damp = _FA_accuracy_damp
	flight_assistant.autopilot_pointer_view = autopilot_pointer
	battle_assistant.aim_accuracy = _BA_accuracy
	battle_assistant.aim_accuracy_damp = _BA_accuracy_damp
	battle_assistant.pointer_view = target_prediction_pointer
	_view.texture = _texture
	gun = gun_scene.instantiate()
	gun.position_extrapolator = extrapolator
	gun.shoot_recoil.connect(_on_shoot_recoil)
	battle_assistant.gun = gun
	_gun_slot.add_child(gun)
	if is_instance_valid(inputs):
		flight_assistant.connect_inputs(inputs)
		battle_assistant.connect_inputs(inputs)
		gun.connect_inputs(inputs)


func _process(delta):
	#DebugDraw2d.line_vector(extrapolator.smooth_position, linear_velocity, Color.LIGHT_SEA_GREEN)
	_update_main_state(delta)
	if inputs is PlayerShipInput:
		MainState.add_debug_info("Origin delta", position)
		MainState.add_debug_info("Origin vel delta", linear_velocity)

func _physics_process(delta):
	gun.velocity = real_velocity

func _integrate_forces(state):
	if inputs is PlayerShipInput:
		FloatingOrigin.update_state(state)
	state.linear_velocity -= FloatingOrigin.velocity_delta
	state.transform.origin -= FloatingOrigin.origin_delta
	flight_assistant.process(state)
	_apply_forcces(state)


func set_target(target: RigidBody2D):
	flight_assistant.target_body = target
	battle_assistant.set_target(target)

func add_force(force: Vector2):
	_forces += force

func add_torque(torque: float):
	_torque += torque

func _apply_forcces(state: PhysicsDirectBodyState2D):
	state.apply_central_force(_forces)
	state.apply_torque(_torque)
	_forces = Vector2.ZERO
	_torque = 0.0

func _real_velocity() -> Vector2:
	return linear_velocity + FloatingOrigin.velocity

func _on_shoot_recoil(force: float):
	apply_central_impulse(-transform.x * force)

# TODO: Refactor
# Data to main state (UI connection)
var _previous_speed = 0
var _time_delta = 0

func _update_main_state(delta):
	var speed = real_velocity.length()
	MainState.ship_position = position + FloatingOrigin.origin
	MainState.ship_speed = speed
	_time_delta += delta
	if _time_delta >= 0.5:
		MainState.ship_acceleration = (speed - _previous_speed) / 0.5
		_time_delta = 0
		_previous_speed = speed
