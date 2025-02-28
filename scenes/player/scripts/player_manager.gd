class_name PlayerManager
extends Node

signal ship_spawned(value: Spaceship)
signal ship_destroyed()

@export var ship_flight_model: ShipFlightModelData
@export var ship_blueprint: ShipBlueprint

var _radar_scene: PackedScene = preload("res://scenes/ship/radar.tscn")

var ship: Spaceship: set = _set_ship
var position: Vector2:
	get:
		return ship.position if is_alive() else Vector2.ZERO

static var instance: PlayerManager

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
	var ship_data = await _create_ship_configuration()
	var new_ship = ship_data.create()
	new_ship.position = _position
	new_ship.input_reader = _input_reader
	var radar: Radar = _radar_scene.instantiate()
	radar.radius = 10000.0
	new_ship.add_child(radar)
	#ship.autopilot_pointer = autopilot_pointer
	var audio_listener := AudioListener2D.new()
	new_ship.add_child(audio_listener)
	audio_listener.make_current()
	WorldGridManager.instance.world_root.add_child(new_ship)
	ship = new_ship
	ship._setup_health(10000.0)
	ship.tree_exiting.connect(_on_ship_destroyed)
	MainState.player = ship

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
	ship_data.design = await ShipBlueprintBaker.instance.bake_from_blueprint(ship_blueprint)
	ship_data.radar_item = ship_blueprint.radar_item_config
	return ship_data

func _on_ship_destroyed() -> void:
	ship = null
