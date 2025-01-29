class_name MainScene
extends Node2D

@export var gun_scene: PackedScene = preload("res://scenes/gun/gun.tscn")
@export var radar_scene: PackedScene = preload("res://scenes/ship/radar.tscn")
@export var ship_flight_model: ShipFlightModelData
@export var ship_blueprint: ShipBlueprint
@export var input_reader: ShipInput

@onready var player_ship_baker: ShipBlueprintBaker = %PlayerShipBaker
@onready var autopilot_pointer: AssistantPointer = %AutopilotPointer
@onready var world: Node2D = %World
var ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")

func _ready() -> void:
	process_physics_priority = -1001
	MainState.world_root = world
	MainState.main_scene = self
	pause()

func _physics_process(delta: float) -> void:
	MainState.last_delta = delta

func pause(value: bool = true) -> void:
	get_tree().paused = value

func spawn_player_ship(_position: Vector2 = Vector2.ZERO) -> void:
	var ship: Spaceship = ship_scene.instantiate() as Spaceship
	ship.group = "player"
	ship.data = await _create_ship_configuration()
	ship.position = _position
	ship.input_reader = input_reader
	ship.gun_scene = gun_scene
	var radar: Radar = radar_scene.instantiate() as Radar
	radar.radius = 10000.0
	ship.add_child(radar)
	ship.autopilot_pointer = autopilot_pointer
	var audio_listener := AudioListener2D.new()
	ship.add_child(audio_listener)
	audio_listener.make_current()
	WorldGridManager.instance.world_root.add_child(ship)
	# HACK: ideally this should works before _ready() call
	ship.setup_health(1000.0)

func _create_ship_configuration() -> ShipData:
	var ship_data := ShipData.new()
	ship_data.flight_model = ship_flight_model
	ship_data.blueprint = ship_blueprint
	player_ship_baker.blueprint = ship_blueprint
	player_ship_baker.design = await player_ship_baker.bake()
	ship_data.design = player_ship_baker.design
	return ship_data
