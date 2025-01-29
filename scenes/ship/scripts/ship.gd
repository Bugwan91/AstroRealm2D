class_name Spaceship
extends ActiveRigidBody

signal dead(ship: Spaceship)
#region Export properties
@export var data: ShipData: set = _set_ship_data
@export var group: String # HACK: Rework with implementation factions/groups system

@export var gun_scene: PackedScene

@export var input_reader: ShipInput

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer
#endregion

#region Onready propeties
@onready var flight_controller: FlightController = %FlightController

@onready var taking_damage: TakingDamage = %TakingDamage
@onready var heat: Heat = %Heat

@onready var _view: ShipView = %View
@onready var _weapon_slots: WeaponSlots = %WeaponSlots
@onready var _radar_item: RadarItem = %RadarItem
#endregion

#region Private properties
var _impulces := Vector2.ZERO
#endregion

#region Initialization
func _ready() -> void:
	assert(data != null, "Ship Data is missed")
	super._ready()
	_setup_view()
	_setup_flight_controller()
	_setup_weapon()
	connect_inputs(input_reader)

func _setup_flight_controller() -> void:
	flight_controller.setup(self)
	flight_controller.dodging.connect(_on_dodge)

func _setup_weapon() -> void:
	_weapon_slots.setup(data.design)
	for slot_index in _weapon_slots.slots.size():
		var gun: Gun = gun_scene.instantiate() as Gun
		gun.group = group
		gun.origin = self
		gun.shoot_recoil.connect(_on_weapon_shoot)
		gun.tranfser_heat.connect(_on_transfered_heat)
		_weapon_slots.add_weapon(gun, slot_index)

func connect_inputs(new_inputs: ShipInput) -> void:
	input_reader = new_inputs
	if not is_instance_valid(new_inputs): return
	input_reader.setup(self)
	_connect_player_inputs()
	_connect_weapon_inputs()
	_connect_flight_controller_inputs()

func _connect_player_inputs() -> void:
	if not _is_player(): return
	_radar_item.config.icon.color = Color(0.2, 0.8, 1.0)
	MainState.player_ship = self
	WorldGridManager.instance.player = self

func _connect_flight_controller_inputs() -> void:
	flight_controller.input_reader = input_reader

func _connect_weapon_inputs() -> void:
	_weapon_slots.connect_inputs(input_reader)

func _setup_view() -> void:
	_view.setup_textures(data.design)

func _set_ship_data(new_data: ShipData) -> void:
	if new_data == null: return
	data = new_data
	mass = data.flight_model.mass
	inertia = data.flight_model.inertia

#endregion

#region Physics
func _physics_process(delta: float) -> void:
	_update_velocity_for_weapons()
	super._physics_process(delta)

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	flight_controller.integrate_forces(state)
	MyDebug.info("spd", speed)
	MyDebug.info("pos", position)
	_apply_impulces(state)

func _update_velocity_for_weapons() -> void:
	_weapon_slots.update_velocity(linear_velocity)
#endregion

#region Events
func set_target(_target: RigidBody2D) -> void:
	pass

func _die() -> void:
	_weapon_slots.enabled = false
	dead.emit(self)

func _destroy() -> void:
	queue_free()

func _on_weapon_shoot(recoil: Vector2) -> void:
	_impulces += recoil

func _on_transfered_heat(transfered_heat: float) -> void:
	heat.add_heat(transfered_heat)
#endregion

func _is_player() -> bool:
	return input_reader is PlayerShipInput

func _apply_impulces(state: PhysicsDirectBodyState2D) -> void:
	if is_zero_approx(_impulces.x) and is_zero_approx(_impulces.y): return
	state.apply_impulse(_impulces)
	_impulces = Vector2.ZERO

func setup_health(value: float) -> void:
	taking_damage.setup_health(value)

func get_max_speed() -> float:
	return data.flight_model.speed

func _on_dodge(value: bool) -> void:
	_weapon_slots.enabled = not value
