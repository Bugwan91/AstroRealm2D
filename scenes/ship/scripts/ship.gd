class_name ShipRigidBody
extends RigidBody2D

signal got_hit(value: Vector2)
signal dead()

@export var _texture: Texture2D
@export var inputs: ShipInput
@export var gun: Gun
@export_range(0, 10000) var max_speed := 2000.0
@export_range(0, 1000) var main_thrust := 500.0
@export_range(0, 500) var maneuver_thrust := 200.0

@export_range(0, 1) var FA_accuracy := 1.0
@export_range(0, 10) var FA_accuracy_damp := 0.1
@export_range(0, 1) var BA_accuracy := 1.0
@export_range(0, 10) var BA_accuracy_damp := 0.1

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer

@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant
@onready var battle_assistant: BattleAssistant = %BattleAssistant
@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters
@onready var taking_damage = %TakingDamage
@onready var ui = %UI

@onready var destroy_effect: DestroyEffectManager = %DestroyEffectManager
@onready var _view: Sprite2D = %View
@onready var _gun_slot: GunSlot = %GunSlot

var real_velocity: Vector2: get = _real_velocity
var health: Health

var _impulses := Vector2.ZERO
var _forces := Vector2.ZERO
var _torque := 0.0

func _ready():
	if inputs is PlayerShipInput:
		MainState.player_ship = self
	thrusters.setup(maneuver_thrust)
	engines.setup(main_thrust, max_speed)
	flight_assistant.setup()
	flight_assistant.follow_accuracy = FA_accuracy
	flight_assistant.follow_accuracy_damp = FA_accuracy_damp
	flight_assistant.autopilot_pointer_view = autopilot_pointer
	battle_assistant.aim_accuracy = BA_accuracy
	battle_assistant.aim_accuracy_damp = BA_accuracy_damp
	battle_assistant.pointer_view = target_prediction_pointer
	if is_instance_valid(gun):
		_gun_slot.add_gun(gun)
		gun.shoot_recoil.connect(_on_shoot_recoil)
		battle_assistant.gun = gun
	connect_inputs(inputs)
	setup_health()
	if is_instance_valid(health):
		taking_damage.health = health
		ui.connect_health(health)
		health.dying.connect(_die)
		destroy_effect.ship = self
		destroy_effect.connect_health(health)
		destroy_effect.destroy.connect(_destroy)
	if _texture:
		_view.texture.diffuse_texture = _texture

func setup_health(new_health: Health = null):
	if new_health:
		health = new_health
	else:
		var nodes = find_children("*", "Health", false)
		if not nodes.is_empty():
			health = nodes[0]

func connect_inputs(new_inputs: ShipInput):
	inputs = new_inputs
	if not is_instance_valid(new_inputs): return
	if inputs is PlayerShipInput:
		MainState.player_ship = self
	flight_assistant.connect_inputs(inputs)
	battle_assistant.connect_inputs(inputs)
	gun.connect_inputs(inputs)


func _physics_process(delta):
	if inputs is PlayerShipInput:
		_update_main_state(delta)
	if is_instance_valid(gun):
		gun.velocity = real_velocity


func _integrate_forces(state):
	if inputs is PlayerShipInput:
		FloatingOrigin.update_from_state(state)
	FloatingOrigin.update_state(state)
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
	state.apply_central_impulse(_impulses)
	state.apply_torque(_torque)
	_forces = Vector2.ZERO
	_impulses = Vector2.ZERO
	_torque = 0.0

func _real_velocity() -> Vector2:
	return linear_velocity + FloatingOrigin.velocity

func _on_shoot_recoil(force: float):
	apply_central_impulse(-transform.x * force)

func _die():
	flight_assistant.enabled = false
	battle_assistant.enabled = false
	gun.enabled = false
	dead.emit()

func _destroy():
	queue_free()

# TODO: Refactor
# Data to main state (UI connection)
var _previous_v := Vector2.ZERO

func _update_main_state(delta):
	var v = real_velocity
	MainState.ship_position = position + FloatingOrigin.origin
	MainState.ship_speed = v.length()
	MainState.ship_acceleration = (v - _previous_v).length() / delta
	_previous_v = v
