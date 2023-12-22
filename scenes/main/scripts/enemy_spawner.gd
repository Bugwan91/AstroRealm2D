extends Node

@export var agressive := false
@export_range(0, 200) var max_count := 2
@export var ship_scene: PackedScene
@export var gun_scene: PackedScene
@export var ship_data: ShipResource

@export_group("Ship parts")
@export var _hulls: Array[HullBakerResource]
@export var _hulls_ext: Array[ViewBakerResource]
@export var _cockpits: Array[ViewBakerResource]
@export var _engines: Array[ViewBakerResource]
@export var _styles: Array[Texture2D]

@onready var _baker: ShipBlueprintBaker = %Baker
@onready var _ship_spawn_timer = %ShipSpawnTimer

var ships: Array[ShipRigidBody]

func _ready():
	await MainState.main_scene_ready
	_ship_spawn_timer.timeout.connect(func():
		if ships.size() < max_count:
			spawn_ship()
	)

func spawn_ship():
	var ship: ShipRigidBody = ship_scene.instantiate() as ShipRigidBody
	ship.group = "enemy"
	ship.setup_data = await _create_ship_configuration()
	ship.position = Vector2(randf_range(-20000, 20000), randf_range(-20000, 20000))
	ship.setup_health(_create_health())
	ship.gun = _create_gun()
	ships.append(ship)
	ship.dead.connect(_on_ship_dead)
	owner.add_child(ship)
	ship.connect_inputs(_create_AI())
	if is_instance_valid(MainState.player_ship):
		ship.inputs.update_target_ship(MainState.player_ship)

func _on_ship_dead(ship: ShipRigidBody):
	ships.erase(ship)

func _create_ship_configuration() -> ShipResource:
	var ship_configuration: ShipResource = ship_data.duplicate()
	_baker.design = ShipTexturesRes.new()
	_baker.blueprint = ShipBlueprint.new()
	_baker.blueprint.hull = _hulls[randi_range(0, _hulls.size() - 1)]
	_baker.blueprint.hull_ext = _hulls_ext[randi_range(0, _hulls_ext.size() - 1)]
	_baker.blueprint.cockpit = _cockpits[randi_range(0, _cockpits.size() - 1)]
	_baker.blueprint.engine = _engines[randi_range(0, _engines.size() - 1)]
	_baker.blueprint.style = _styles[randi_range(0, _styles.size() - 1)]
	_baker.design = await _baker.bake()
	_baker.design.shininess = randf_range(-0.9, 0.9)
	ship_configuration.textures = _baker.design
	return ship_configuration

func _create_gun() -> Gun:
	var gun: Gun = gun_scene.instantiate() as Gun
	gun.bullet_color = Color.RED
	gun.bullet_speed = 3000.0
	gun.fire_rate = 5.0
	return gun

func _create_health() -> Health:
	var health := Health.new()
	health.max_health = 200.0
	health.health = health.max_health
	return health

func _create_AI() -> ShipInput:
	var ship_AI = AIShipInput.new()
	ship_AI.keep_distance = 1000.0
	ship_AI.agressive = agressive
	return ship_AI
