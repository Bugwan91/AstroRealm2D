@tool
class_name ShipRigidBody
extends FloatingOriginRigidBody

signal got_hit(value: Vector2)
signal dead(ship: ShipRigidBody)

@export var setup_data: ShipResource: set = setup_view
@export var group: String # TODO: Rework with implementation factions/groups system

@export var inputs: ShipInput
@export var gun: Gun

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer

@onready var _collision_polygon: CollisionPolygon2D = %CollisionPolygon2D
@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant
@onready var battle_assistant: BattleAssistant = %BattleAssistant
@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters
@onready var taking_damage: TakingDamage = %TakingDamage
@onready var radar_item: RadarItem = %RadarItem

@onready var _destroy_effect: DestroyEffectManager = %DestroyEffectManager
@onready var _view: ShipView = %View as ShipView
@onready var _weapon_slots: WeaponSlots = %WeaponSlots

var is_player: bool = false:
	get:
		return inputs is PlayerShipInput
var health: Health

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
	if Engine.is_editor_hint(): return
	thrusters.setup(setup_data.textures.thrusters, setup_data.maneuver_thrust)
	engines.setup(setup_data.textures.engines, setup_data.main_thrust)
	_weapon_slots.setup(setup_data.textures)
	flight_assistant.setup()
	
	flight_assistant.autopilot_pointer_view = autopilot_pointer
	battle_assistant.pointer_view = target_prediction_pointer
	if is_instance_valid(gun):
		gun.group = group
		_weapon_slots.add_weapon(gun)
		gun.shoot_recoil.connect(_on_impulse_local)
		battle_assistant.gun = gun
	connect_inputs(inputs)
	setup_health()
	if is_instance_valid(health):
		taking_damage.health = health
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
	if is_player:
		MainState.player_ship = self
		flight_assistant.avoid_collisions = false
	flight_assistant.connect_inputs(inputs)
	battle_assistant.connect_inputs(inputs)
	if is_instance_valid(gun):
		gun.connect_inputs(inputs)


func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if is_instance_valid(gun):
		gun.velocity = linear_velocity


func _integrate_forces(state: PhysicsDirectBodyState2D):
	if Engine.is_editor_hint(): return
	if is_player:
		FloatingOrigin.update_from_state(state)
	super._integrate_forces(state)
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
