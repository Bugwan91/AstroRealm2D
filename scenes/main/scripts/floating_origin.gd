extends Node2D

@export var enabled := true

@onready var target: Spaceship = MainState.player_ship

var origin := Vector2.ZERO

var velocity := Vector2.ZERO
var velocity_delta: Vector2

var last_update_time: float
var last_physic_time: float

func _ready():
	process_priority = -1000
	MainState.player_ship_updated.connect(_on_update_player_ship)
	last_update_time = Time.get_ticks_usec() * 0.000001
	last_physic_time = Time.get_ticks_usec() * 0.000001

func absolute_position(node: Node2D) -> Vector2:
	return node.position + origin

func add_velocity(extra_velocity: Vector2):
	velocity_delta = extra_velocity
	velocity += velocity_delta

func update_state(state: PhysicsDirectBodyState2D):
	if not enabled: return
	state.linear_velocity += velocity_delta

func _process(delta):
	if not enabled or not is_instance_valid(target): return
	MyDebug.info("origin", origin)
	MyDebug.info("origin velocity", velocity)
	MyDebug.info("speed", velocity.length())
	_float_objects()

func _float_objects():
	var time := Time.get_ticks_usec() * 0.000001
	origin += velocity * (time - last_update_time)
	for node in MainState.main_scene.get_children():
		if node is Node2D and not node.is_in_group("ignore_floating") and not node is RigidBody2D:
			node.position += velocity * (time - last_update_time)
	last_update_time = time

func _on_update_player_ship(player_ship: Spaceship):
	target = player_ship
	if not target:
		velocity_delta = -velocity
		velocity = Vector2.ZERO
