class_name PlayerManager
extends Node

signal ship_spawned(value: Spaceship)
signal ship_destroyed()

@export var ship_flight_model: ShipFlightModelData
@export var ship_blueprint: ShipBlueprint

var _ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")
var _gun_scene: PackedScene = preload("res://scenes/gun/gun.tscn")
var _radar_scene: PackedScene = preload("res://scenes/ship/radar.tscn")

var ship: Spaceship: set = _set_ship
var position: Vector2:
	get:
		return ship.position if is_alive() else Vector2.ZERO

static var instance: PlayerManager

@onready var _ship_baker: ShipBlueprintBaker = %PlayerShipBaker

var _input_reader: ShipInput

func _ready() -> void:
	PlayerManager.instance = self
	_input_reader = PlayerShipInput.new()
	add_child(_input_reader)

func is_alive() -> bool:
	return is_instance_valid(ship)

func respawn_player_ship(_position: Vector2 = Vector2.ZERO) -> void:
	if _position.is_zero_approx():
		_position = position
	if is_alive():
		ship.queue_free()
	var new_ship: Spaceship = _ship_scene.instantiate() as Spaceship
	new_ship.group = "player"
	new_ship.data = await _create_ship_configuration()
	new_ship.position = _position
	new_ship.input_reader = _input_reader
	new_ship.gun_scene = _gun_scene
	var radar: Radar = _radar_scene.instantiate() as Radar
	radar.radius = 10000.0
	new_ship.add_child(radar)
	#ship.autopilot_pointer = autopilot_pointer
	var audio_listener := AudioListener2D.new()
	new_ship.add_child(audio_listener)
	audio_listener.make_current()
	WorldGridManager.instance.world_root.add_child(new_ship)
	# HACK: ideally this should works before _ready() call
	new_ship.setup_health(1000.0)
	ship = new_ship
	ship.tree_exiting.connect(_on_ship_destroyed)

func destroy_ship() -> void:
	ship.queue_free()

func _set_ship(value: Spaceship) -> void:
	ship = value
	if is_instance_valid(ship):
		ship_spawned.emit(ship)
	else:
		ship_destroyed.emit()

func _create_ship_configuration() -> ShipData:
	var ship_data := ShipData.new()
	ship_data.flight_model = ship_flight_model
	ship_data.blueprint = ship_blueprint
	_ship_baker.blueprint = ship_blueprint
	_ship_baker.design = await _ship_baker.bake()
	ship_data.design = _ship_baker.design
	return ship_data

func _on_ship_destroyed() -> void:
	ship = null
