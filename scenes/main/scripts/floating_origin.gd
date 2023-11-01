extends Node2D

const GROUP_NAME = "FloatingOriginShiftable"

@export var enabled := true

@onready var target: ShipRigidBody = MainState.player_ship

var origin := Vector2.ZERO
var origin_delta := Vector2.ZERO
var velocity := Vector2.ZERO
var velocity_delta: Vector2

func _ready():
	MainState.player_ship_updated.connect(_on_update_player_ship)

func update_state(state: PhysicsDirectBodyState2D):
	velocity_delta = state.linear_velocity
	velocity += velocity_delta
	origin_delta = state.transform.origin# + velocity_delta * state.step
	origin += velocity * state.step + origin_delta

func add(node: Node):
	node.add_to_group(GROUP_NAME)

func _process(delta):
	MainState.add_debug_info("origin", origin)
	MainState.add_debug_info("origin velocity", velocity)
	if not is_instance_valid(target): return
	for node in get_tree().get_nodes_in_group(GROUP_NAME):
		node.position -= velocity * delta

func _on_update_player_ship(player_ship: ShipRigidBody):
	target = player_ship
	if not target:
		velocity = Vector2.ZERO
