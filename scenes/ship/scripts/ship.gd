@tool
class_name ShipRigidBody
extends FloatingOriginRigidBody

signal got_hit(value: Vector2)
signal dead(ship: ShipRigidBody)

const SPEED_SLOWING_LIMIT := 0.2

@export var setup_data: ShipResource: set = setup_view
@export var group: String # TODO: Rework with implementation factions/groups system

@export var inputs: ShipInput
@export var gun: Gun

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer

@onready var _collision_polygon = %CollisionPolygon2D
@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant
@onready var battle_assistant: BattleAssistant = %BattleAssistant
@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters
@onready var taking_damage = %TakingDamage
@onready var ui = %UI

@onready var _destroy_effect: DestroyEffectManager = %DestroyEffectManager
@onready var _view: ShipView = %View as ShipView
@onready var _gun_slot: GunSlot = %GunSlot

var absolute_velocity: Vector2: get = _absolute_velocity
var health: Health
var thrust_multiplyer: float

var _max_speed_squared: float
var _impulses := Vector2.ZERO
var _forces := Vector2.ZERO
var _torque := 0.0

func setup_view(resource: ShipResource = null):
	setup_data = resource
	if not is_instance_valid(_view):
		return
	_view.setup_textures(setup_data.textures)
	_collision_polygon.polygon = setup_data.textures.polygon


func _ready():
	setup_view(setup_data)
	_max_speed_squared = pow(setup_data.max_speed, 2)
	if Engine.is_editor_hint(): return
	thrusters.setup(setup_data.textures.thrusters, setup_data.maneuver_thrust)
	engines.setup(setup_data.textures.engines, setup_data.main_thrust, setup_data.max_speed)
	flight_assistant.setup()
	flight_assistant.follow_accuracy = setup_data.FA_accuracy
	flight_assistant.follow_accuracy_damp = setup_data.FA_accuracy_damp
	battle_assistant.aim_accuracy = setup_data.BA_accuracy
	battle_assistant.aim_accuracy_damp = setup_data.BA_accuracy_damp
	
	flight_assistant.autopilot_pointer_view = autopilot_pointer
	battle_assistant.pointer_view = target_prediction_pointer
	if is_instance_valid(gun):
		gun.group = group
		_gun_slot.add_gun(gun)
		gun.shoot_recoil.connect(_on_impulse_local)
		battle_assistant.gun = gun
	connect_inputs(inputs)
	setup_health()
	if is_instance_valid(health):
		taking_damage.health = health
		ui.connect_health(health)
		health.dying.connect(_die)
		_destroy_effect.ship = self
		_destroy_effect.connect_health(health)
		_destroy_effect.destroy.connect(_destroy)

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
	new_inputs.init(self)
	if inputs is PlayerShipInput:
		MainState.player_ship = self
		flight_assistant.avoid_collisions = false
	flight_assistant.connect_inputs(inputs)
	battle_assistant.connect_inputs(inputs)
	if is_instance_valid(gun):
		gun.connect_inputs(inputs)


func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if inputs is PlayerShipInput:
		_update_main_state(delta)
	if is_instance_valid(gun):
		gun.velocity = linear_velocity


func _integrate_forces(state):
	if Engine.is_editor_hint(): return
	if inputs is PlayerShipInput:
		FloatingOrigin.update_from_state(state)
	super._integrate_forces(state)
	_calculate_thrust_multiplyer()
	flight_assistant.process(state)
	_apply_forcces(state)
	_apply_drag(state)


func set_target(target: RigidBody2D):
	flight_assistant.target_body = target
	battle_assistant.set_target(target)

func add_force(force: Vector2):
	_forces += force

func add_torque(torque: float):
	_torque += torque

func _apply_forcces(state: PhysicsDirectBodyState2D):
	state.apply_central_force(_forces * thrust_multiplyer)
	state.apply_central_impulse(_impulses * thrust_multiplyer)
	state.apply_torque(_torque)
	_forces = Vector2.ZERO
	_impulses = Vector2.ZERO
	_torque = 0.0

func _calculate_thrust_multiplyer():
	var v_sq: float = absolute_velocity.length_squared()
	var c_sq: float = _max_speed_squared
	v_sq = min(v_sq, c_sq)
	# Graph: https://www.desmos.com/calculator/vhojpofhoa
	var a_mult: float = 1.0 - v_sq/c_sq + SPEED_SLOWING_LIMIT
	thrust_multiplyer = clampf(a_mult, 0.0, 1.0)

func _apply_drag(state: PhysicsDirectBodyState2D):
	var delta = absolute_velocity.length() - setup_data.max_speed
	if delta > 0:
		state.apply_central_force(delta * mass * -absolute_velocity.normalized())

func _absolute_velocity() -> Vector2:
	return linear_velocity + FloatingOrigin.velocity

func _on_impulse_local(force: Vector2):
	apply_central_impulse(force.rotated(rotation))

func _on_inpulse(force: Vector2):
	apply_central_impulse(force)

func _die():
	flight_assistant.enabled = false
	battle_assistant.enabled = false
	gun.enabled = false
	dead.emit(self)

func _destroy():
	queue_free()

# TODO: Refactor
# Data to main state (UI connection)
var _previous_v := Vector2.ZERO

func _update_main_state(delta):
	var v = absolute_velocity
	MainState.ship_position = position + FloatingOrigin.origin
	MainState.ship_speed = v.length()
	MainState.ship_acceleration = (v - _previous_v).length() / delta
	_previous_v = v
