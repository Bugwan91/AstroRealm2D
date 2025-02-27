class_name Spaceship
extends ActiveRigidBody

#region Export properties
@export var data: ShipData: set = _set_ship_data

@export var input_reader: ShipInput

@export var autopilot_pointer: AssistantPointer
@export var target_prediction_pointer: AssistantPointer
@export var blackboard_plan: BlackboardPlan
#endregion

#region Onready propeties
@onready var flight_controller: FlightController = %FlightController
@onready var taking_damage: TakingDamage = %TakingDamage
@onready var heat: Heat = %Heat
@onready var _view: ShipView = %View
@onready var _main_weapon_slot: WeaponSlot = %MainWeaponSlot
@onready var _radar_item: RadarItem = %RadarItem
@onready var _collision_polygon: CollisionPolygon2D = %CollisionPolygon2D
#endregion

var blackboard: Blackboard

#region Private properties
var _impulces := Vector2.ZERO
#endregion

#region Initialization

func init(config: ShipData):
	pass

func _ready() -> void:
	assert(data != null, "Ship Data is missing")
	assert(data.blueprint != null, "Ship Blueprint is missing")
	if data.design == null:
		data.design = await ShipBlueprintBaker.instance.bake_from_blueprint(data.blueprint)
	super._ready()
	_setup_collider()
	_setup_view()
	_setup_radar_item()
	_setup_flight_controller()
	_setup_weapon()
	_setup_health()
	_setup_heat()
	connect_inputs(input_reader)
	init_blackboard()

func init_blackboard():
	blackboard = blackboard_plan.create_blackboard(self)
	blackboard.bind_var_to_property(&"mass", data.flight_model, &"mass", true)
	blackboard.bind_var_to_property(&"inertia", data.flight_model, &"inertia", true)
	blackboard.bind_var_to_property(&"speed", data.flight_model, &"speed", true)
	blackboard.bind_var_to_property(&"boost", data.flight_model, &"boost", true)
	blackboard.bind_var_to_property(&"strafe", data.flight_model, &"strafe", true)
	blackboard.bind_var_to_property(&"dodge", data.flight_model, &"dodge", true)
	blackboard.bind_var_to_property(&"turn", data.flight_model, &"turn", true)
	blackboard.bind_var_to_property(&"heat_max", heat, &"capacity", true)
	blackboard.bind_var_to_property(&"heat_cooling", heat, &"cooling", true)
	blackboard.bind_var_to_property(&"heat", heat, &"_heat", true)
	blackboard.bind_var_to_property(&"hp_max", taking_damage.health, &"max_health", true)
	blackboard.bind_var_to_property(&"hp", taking_damage.health, &"health", true)
	print(blackboard.get_vars_as_dict())

func _setup_flight_controller() -> void:
	flight_controller.setup(self)
	flight_controller.dodging.connect(_on_dodge)

func _setup_weapon() -> void:
	_main_weapon_slot.setup(data.design.main_weapon_points)
	_main_weapon_slot.set_weapon(data.design.main_weapon)
	_main_weapon_slot.heat_generated.connect(_on_transfered_heat)
	_main_weapon_slot.recoil.connect(_on_weapon_shoot)

func _setup_collider() -> void:
	_collision_polygon.polygon = data.design.polygon

func connect_inputs(new_inputs: ShipInput) -> void:
	input_reader = new_inputs
	if not is_instance_valid(new_inputs): return
	input_reader.setup(self)
	_connect_player_inputs()
	_connect_weapon_inputs()
	_connect_flight_controller_inputs()

func _connect_player_inputs() -> void:
	if not is_player(): return
	_radar_item.config.icon.color = Color(0.2, 0.8, 1.0)
	WorldGridManager.instance.player = self

func _connect_flight_controller_inputs() -> void:
	flight_controller.input_reader = input_reader

func _connect_weapon_inputs() -> void:
	_main_weapon_slot.connect_fire_input(input_reader.data.firing_toggled)
	_main_weapon_slot.connect_target_input(input_reader.data.target_changed)

func _setup_view() -> void:
	_view.setup_textures(data.design)
	_view.scale = Vector2.ONE * data.design.view_scale

func _setup_health() -> void:
	taking_damage.setup_polygon(data.blueprint.health, data.design.polygon)
	#taking_damage.setup_health(data.blueprint.health)

func _setup_heat() -> void:
	heat.init(data.blueprint.hull.heat_capacity, data.blueprint.hull.heat_radiation)

func _setup_radar_item() -> void:
	_radar_item.configure(data.radar_item)
	_radar_item.selectable = not is_player()

func _set_ship_data(new_data: ShipData) -> void:
	if new_data == null: return
	data = new_data
	mass = data.flight_model.mass
	inertia = data.flight_model.inertia

#endregion

#region Physics
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	flight_controller.integrate_forces(state)
	MyDebug.info("spd", speed)
	MyDebug.info("pos", position)
	_apply_impulces(state)
#endregion

#region Events
func set_target(_target: RigidBody2D) -> void:
	pass

func _on_weapon_shoot(recoil: Vector2) -> void:
	_impulces += recoil

func _on_transfered_heat(transfered_heat: float) -> void:
	heat.add_heat(transfered_heat)
#endregion

func _apply_impulces(state: PhysicsDirectBodyState2D) -> void:
	if is_zero_approx(_impulces.x) and is_zero_approx(_impulces.y): return
	state.apply_impulse(_impulces)
	_impulces = Vector2.ZERO

func is_player() -> bool:
	return input_reader is PlayerShipInput

func get_max_speed() -> float:
	return data.flight_model.speed

func _on_dodge(value: bool) -> void:
	_main_weapon_slot.enabled = not value
