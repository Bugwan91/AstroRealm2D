class_name MainScene
extends Node2D

@export var ship_scene: PackedScene
@export var gun_scene: PackedScene
@export var radar_scene: PackedScene
@export var ship_data: ShipResource

@onready var input_reader = %InputReader
@onready var autopilot_pointer = %AutopilotPointer
@onready var target_pointer = %TargetPointer

func _ready():
	MainState.main_scene = self

func spawn_player_ship(position: Vector2 = Vector2.ZERO):
	var ship: ShipRigidBody = ship_scene.instantiate() as ShipRigidBody
	ship.setup_data = ship_data
	ship.position = -FloatingOrigin.origin
	ship.inputs = input_reader
	var health := Health.new()
	health.health = health.max_health
	ship.setup_health(health)
	var gun: Gun = gun_scene.instantiate() as Gun
	gun.overheat = 0.0
	ship.gun = gun
	var radar: Radar = radar_scene.instantiate() as Radar
	ship.add_child(radar)
	ship.autopilot_pointer = autopilot_pointer
	ship.target_prediction_pointer = target_pointer
	add_child(ship)
	radar.radius = 20000.0
