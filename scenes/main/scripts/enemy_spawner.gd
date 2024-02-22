extends Node

@export var agressive := false
@export_range(0, 200) var max_count := 2
@export_range(0.1, 100) var interval := 3.0
@export_range(0, 4000) var distance := 1500.0
@export var gun_scene: PackedScene = preload("res://scenes/gun/gun.tscn")
@export var ship_flight_model: ShipFlightModelData
@export var ship_parts: ShipDesignerParts = preload("res://resources/ship_parts/all_parts.tres")

@onready var _baker: ShipBlueprintBaker = %Baker
@onready var _ship_spawn_timer = %ShipSpawnTimer

var ship_scene: PackedScene = preload("res://scenes/ship/ship.tscn")
var ships: Array[Spaceship]

func _ready():
	await MainState.main_scene_ready
	_ship_spawn_timer.wait_time = interval
	_ship_spawn_timer.timeout.connect(func():
		if ships.size() < max_count:
			spawn_ship()
			MyDebug.info("ships", ships.size())
	)

func spawn_ship():
	var ship: Spaceship = ship_scene.instantiate() as Spaceship
	ship.group = "enemy"
	ship.data = await _create_ship_configuration()
	ship.position = Vector2(randf_range(-20000, 20000), randf_range(-20000, 20000))
	ship.health = _create_health()
	ship.gun = _create_gun()
	ships.append(ship)
	ship.dead.connect(_on_ship_dead)
	owner.add_child(ship)
	ship.connect_inputs(_create_AI())
	if is_instance_valid(MainState.player_ship):
		ship.inputs.update_target_ship(MainState.player_ship)

func _on_ship_dead(ship: Spaceship):
	ships.erase(ship)

func _create_ship_configuration() -> ShipData:
	var ship_configuration = ShipData.new()
	ship_configuration.flight_model = ship_flight_model
	_baker.design = ShipDesignData.new()
	_baker.blueprint = ShipBlueprint.new()
	_baker.blueprint.hull = ship_parts.hulls[randi_range(0, ship_parts.hulls.size() - 1)]
	_baker.blueprint.hull_ext = ship_parts.hulls_ext[randi_range(0, ship_parts.hulls_ext.size() - 1)]\
		if randf() > 0.2 else null
	_baker.blueprint.engine = ship_parts.engines[randi_range(0, ship_parts.engines.size() - 1)]
	_baker.blueprint.style = ship_parts.styles[randi_range(0, ship_parts.styles.size() - 1)]\
		if randf() > 0.2 else null
	_baker.design = await _baker.bake()
	_baker.design.shininess = randf_range(-0.9, 0.9)
	ship_configuration.design = _baker.design
	return ship_configuration

func _create_gun() -> Gun:
	var gun: Gun = gun_scene.instantiate() as Gun
	gun.bullet_color = Color.RED
	gun.fire_rate = 5.0
	return gun

func _create_health() -> Health:
	var health := Health.new()
	health.max_health = 200.0
	health.health = health.max_health
	return health

func _create_AI() -> ShipInput:
	var ship_AI = AIShipInput.new()
	ship_AI.keep_distance = distance
	ship_AI.agressive = agressive
	return ship_AI
