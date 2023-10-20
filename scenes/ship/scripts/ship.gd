class_name ShipRigidBody
extends RigidBody2D

@export var _texture: Texture2D
@export var inputs: ShipInput
@export var gun_scene: PackedScene
@export_range(0, 500) var _main_thrust := 200.0
@export_range(0, 100) var _maneuver_thrust := 50.0
@export_range(0, 2000) var max_speed := 1000.0
@export_range(0, 500) var _flight_assistant_precision := 0.0
@export var flight_assistant: ShipFlightAssistant
@export var battle_assistant: BattleAssistant

@onready var extrapolator: PositionExtrapolation = %PositionExtrapolation
@onready var thrusters: Thrusters = %Thrusters
@onready var engines: MainThrusters = %MainThrusters


@onready var _view = %View
@onready var _gun_slot = %GunSlot

@onready var _main_state = get_node("/root/MainState")

var inverse_inertia := 0.0
var gun: Gun


func _ready():
	thrusters.setup(_maneuver_thrust)
	engines.setup(_main_thrust, max_speed)
	flight_assistant.setup(_flight_assistant_precision)
	_view.texture = _texture
	gun = gun_scene.instantiate()
	gun.shoot_recoil.connect(_on_shoot_recoil)
	battle_assistant.gun = gun
	_gun_slot.add_child(gun)
	if is_instance_valid(inputs):
		flight_assistant.connect_inputs(inputs)
		battle_assistant.connect_inputs(inputs)
		battle_assistant.is_show_point = inputs is PlayerShipInput
		gun.connect_inputs(inputs)


func _process(delta):
	_update_main_state(delta)
	gun.velocity = linear_velocity


func _integrate_forces(state):
	inverse_inertia = state.inverse_inertia


func set_target(target: RigidBody2D):
	flight_assistant.target_body = target
	battle_assistant.set_target(target)


func _on_shoot_recoil(force: float):
	apply_central_impulse(-transform.x * force)

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
