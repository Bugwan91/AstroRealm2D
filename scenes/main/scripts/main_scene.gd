class_name MainScene
extends Node2D

@export var gun_scene: PackedScene = preload("res://scenes/gun/gun.tscn")
@export var radar_scene: PackedScene = preload("res://scenes/ship/radar.tscn")
@export var ship_flight_model: ShipFlightModelData
@export var ship_blueprint: ShipBlueprint
@export var input_reader: ShipInput

@onready var player_ship_baker: ShipBlueprintBaker = %PlayerShipBaker
@onready var autopilot_pointer = %AutopilotPointer

var ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")

func _ready():
	MainState.main_scene = self

func spawn_player_ship(position: Vector2 = Vector2.ZERO):
	var ship: Spaceship = ship_scene.instantiate() as Spaceship
	ship.group = "player"
	ship.is_player = true
	ship.data = await _create_ship_configuration()
	ship.data.design.shininess = 0.5
	ship.position = -FloatingOrigin.origin
	ship.input_reader = input_reader
	var health := Health.new()
	health.max_health = 1000.0
	health.health = health.max_health
	ship.health = health
	#var gun: Gun = gun_scene.instantiate() as Gun
	#gun.bullet_color = Color.GREEN
	#ship.gun = gun
	ship.gun_scene = gun_scene
	var radar: Radar = radar_scene.instantiate() as Radar
	ship.add_child(radar)
	ship.autopilot_pointer = autopilot_pointer
	var audio_listener = AudioListener2D.new()
	ship.add_child(audio_listener)
	audio_listener.make_current()
	add_child(ship)
	radar.radius = 20000.0

func _create_ship_configuration() -> ShipData:
	var ship_data = ShipData.new()
	ship_data.flight_model = ship_flight_model
	ship_data.blueprint = ship_blueprint
	player_ship_baker.blueprint = ship_blueprint
	player_ship_baker.design = await player_ship_baker.bake()
	ship_data.design = player_ship_baker.design
	return ship_data
