class_name ShipRigidBody
extends RigidBody2D

@export var _texture: Texture2D
@export var inputs: ShipInput
@export var gun: Gun
@export_range(0, 10000) var _max_speed := 2000.0
@export_range(0, 1000) var _main_thrust := 500.0
@export_range(0, 500) var _maneuver_thrust := 200.0

@export_range(0, 1) var _FA_accuracy := 1.0
@export_range(0, 10) var _FA_accuracy_damp := 0.1
@export_range(0, 1) var _BA_accuracy := 1.0
@export_range(0, 10) var _BA_accuracy_damp := 0.1

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer
@export var shoot_marker: AssistantPointer

@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant
@onready var battle_assistant: BattleAssistant = %BattleAssistant
@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters


@onready var _view = %View
@onready var _gun_slot = %GunSlot

var real_velocity: Vector2: get = _real_velocity

var _forces := Vector2.ZERO
var _torque := 0.0

func _ready():
	if inputs is PlayerShipInput:
		FloatingOrigin.target = self
		MainState.player_ship = self
	thrusters.setup(_maneuver_thrust)
	engines.setup(_main_thrust, _max_speed)
	flight_assistant.setup()
	flight_assistant.follow_accuracy = _FA_accuracy
	flight_assistant.follow_accuracy_damp = _FA_accuracy_damp
	flight_assistant.autopilot_pointer_view = autopilot_pointer
	battle_assistant.aim_accuracy = _BA_accuracy
	battle_assistant.aim_accuracy_damp = _BA_accuracy_damp
	battle_assistant.pointer_view = target_prediction_pointer
	_view.texture = _texture
	gun.position = _gun_slot.position
	#_gun_slot.add_child(gun)
	#gun.position = Vector2.ZERO
	gun.marker = shoot_marker
	gun.shoot_recoil.connect(_on_shoot_recoil)
	battle_assistant.gun = gun
	if is_instance_valid(inputs):
		flight_assistant.connect_inputs(inputs)
		battle_assistant.connect_inputs(inputs)
		gun.connect_inputs(inputs)


func _process(delta):
	if inputs is PlayerShipInput:
		MainState.add_debug_info("Origin delta", position)
		MainState.add_debug_info("Origin vel delta", linear_velocity)


func _physics_process(delta):
	_update_main_state(delta)
	gun.velocity = real_velocity


func _integrate_forces(state):
	var full_velocity: Vector2 = state.linear_velocity + FloatingOrigin.velocity
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
var _previous_v := Vector2.ZERO

func _update_main_state(delta):
	var v = real_velocity
	MainState.ship_position = position + FloatingOrigin.origin
	MainState.ship_speed = v.length()
	MainState.ship_acceleration = (v - _previous_v).length() / delta
	_previous_v = v
