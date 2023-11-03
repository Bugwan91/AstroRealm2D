class_name MainScene
extends Node2D

@export var ship_scene: PackedScene
@export var gun_scene: PackedScene
@export var radar_scene: PackedScene

@onready var input_reader = %InputReader
@onready var autopilot_pointer = %AutopilotPointer
@onready var target_pointer = %TargetPointer

func _ready():
	MainState.main_scene = self

func spawn_player_ship(position: Vector2 = Vector2.ZERO):
	var ship: ShipRigidBody = ship_scene.instantiate() as ShipRigidBody
	ship.position = -FloatingOrigin.origin
	ship.inputs = input_reader
	ship.main_thrust = 1000.0
	ship.maneuver_thrust = 250.0
	ship.FA_accuracy = 0.9
	var health := Health.new()
	health.max_health = 100.0
	health.health = health.max_health
	ship.setup_health(health)
	var gun: Gun = gun_scene.instantiate() as Gun
	gun.bullet_color = Color.PALE_GREEN
	gun.range = 1500.0
	gun.overheat = 0.0
	ship.gun = gun
	var radar: Radar = radar_scene.instantiate() as Radar
	ship.add_child(radar)
	radar.radius = 1000.0
	ship.autopilot_pointer = autopilot_pointer
	ship.target_prediction_pointer = target_pointer
	add_child(ship)
