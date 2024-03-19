class_name Spaceship
extends FloatingOriginRigidBody

signal got_hit(impulse: Vector2)
signal dead(ship: Spaceship)

@export var data: ShipData: set = _set_ship_data
@export var group: String # TODO: Rework with implementation factions/groups system

@export var gun_scene: PackedScene

@export var input_reader: ShipInput

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer

@onready var flight_assistant: ShipFlightAssistant = %FlightAssistant
@onready var flight_controller: FlightController = %FlightController

@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var taking_damage: TakingDamage = %TakingDamage
@onready var heat: Heat = %Heat

@onready var _view: ShipView = %View
@onready var _weapon_slots: WeaponSlots = %WeaponSlots
@onready var _radar_item: RadarItem = %RadarItem
@onready var _destroy_effect: DestroyEffectManager = %DestroyEffectManager

var health: Health

var is_player: bool = false:
	get:
		return input_reader is PlayerShipInput

func _ready():
	assert(data != null, "Ship Data is missed")
	_setup_view()
	_setup_flight_controller()
	_setup_health()
	_setup_weapon()
	connect_inputs(input_reader)
	flight_controller.move_world = true

func _setup_flight_controller():
	flight_assistant.setup(self)
	flight_controller.setup(self)
	flight_assistant.autopilot_pointer_view = autopilot_pointer

func _setup_health():
	if not is_instance_valid(health): return
	taking_damage.setup(health, data.design.polygon)
	_destroy_effect.setup(self)
	_destroy_effect.destroy.connect(_destroy)
	health.dying.connect(_die)

func _setup_weapon():
	_weapon_slots.setup(data.design)
	for slot_index in _weapon_slots.slots.size():
		var gun: Gun = gun_scene.instantiate() as Gun
		gun.group = group
		gun.shoot_recoil.connect(_on_weapon_shoot)
		_weapon_slots.add_weapon(gun, slot_index)

func connect_inputs(new_inputs: ShipInput):
	input_reader = new_inputs
	if not is_instance_valid(new_inputs): return
	input_reader.setup(self)
	flight_assistant.connect_inputs(input_reader)
	_connect_player_inputs()
	_connect_weapon_inputs()
	_connect_flight_controller_inputs()

func _connect_player_inputs():
	if not is_player: return
	origin = true
	_radar_item.color = Color(0.2, 0.8, 1.0)
	MainState.player_ship = self
	flight_assistant.collision_detector.enabled = false
	

func _connect_flight_controller_inputs():
	flight_controller.inputs = input_reader.data

func _connect_weapon_inputs():
	_weapon_slots.connect_inputs(input_reader)

func _integrate_forces(state: PhysicsDirectBodyState2D):
	flight_controller.process(state)
	super._integrate_forces(state)
	_update_velocity_for_weapons(state)

func _update_velocity_for_weapons(state: PhysicsDirectBodyState2D):
	_weapon_slots.update_velocity(state.linear_velocity)

func set_target(target: RigidBody2D):
	flight_assistant.target_body = target

func _die():
	flight_assistant.enabled = false
	_weapon_slots.enabled = false
	dead.emit(self)

func _destroy():
	queue_free()

func _setup_view():
	_view.setup_textures(data.design)

func _set_ship_data(new_data: ShipData):
	if new_data == null: return
	data = new_data
	mass = data.flight_model.mass
	inertia = data.flight_model.inertia

func _on_weapon_shoot(_recoil: Vector2):
	heat.add_heat(5.0)
