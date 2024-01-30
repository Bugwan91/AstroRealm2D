class_name MainScene
extends Node2D

@export var gun_scene: PackedScene = preload("res://scenes/gun/gun.tscn")
@export var radar_scene: PackedScene = preload("res://scenes/ship/radar.tscn")
@export var ship_data: ShipResource
@export var ship_blueprint: ShipBlueprint
@onready var player_ship_baker: ShipBlueprintBaker = %PlayerShipBaker

@onready var input_reader = %InputReader
@onready var autopilot_pointer = %AutopilotPointer

var ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")

func _ready():
	MainState.main_scene = self

func spawn_player_ship(position: Vector2 = Vector2.ZERO):
	var ship: ShipRigidBody = ship_scene.instantiate() as ShipRigidBody
	ship.group = "player"
	ship.is_player = true
	ship.setup_data = await _create_ship_configuration()
	ship.position = -FloatingOrigin.origin
	ship.inputs = input_reader
	var health := Health.new()
	health.max_health = 10000.0
	health.health = health.max_health
	ship.setup_health(health)
	var gun: Gun = gun_scene.instantiate() as Gun
	gun.bullet_color = Color.GREEN
	gun.overheat = 0.0
	gun.fire_rate = 10.0
	ship.gun = gun
	var radar: Radar = radar_scene.instantiate() as Radar
	ship.add_child(radar)
	ship.autopilot_pointer = autopilot_pointer
	var audio_listener = AudioListener2D.new()
	ship.add_child(audio_listener)
	audio_listener.make_current()
	add_child(ship)
	radar.radius = 10000.0

func _create_ship_configuration() -> ShipResource:
	player_ship_baker.blueprint = ship_blueprint
	player_ship_baker.design = await player_ship_baker.bake()
	ship_data.textures = player_ship_baker.design
	return ship_data
