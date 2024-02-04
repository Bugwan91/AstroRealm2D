extends Node2D

const GROUP_NAME = "shiftable"

@export var enabled := true

@onready var target: ShipRigidBody = MainState.player_ship

var origin := Vector2.ZERO
var origin_delta := Vector2.ZERO
var velocity := Vector2.ZERO
var velocity_delta: Vector2

var _process_origin_delta: Vector2
var _reset_velocity_delta := false
var _reset_reset := false

func _ready():
	MainState.player_ship_updated.connect(_on_update_player_ship)

func _physics_process(_delta):
	if not enabled: return
	if _reset_reset:
		_reset_reset = false
		_reset_velocity_delta = false
		velocity_delta = Vector2.ZERO

func absolute_position(node: Node2D) -> Vector2:
	return node.position + origin

func update_from_state(state: PhysicsDirectBodyState2D):
	if not enabled: return
	velocity_delta = state.linear_velocity
	velocity += velocity_delta
	origin_delta = state.transform.origin
	_process_origin_delta = origin_delta
	origin += velocity * state.step + origin_delta

func update_state(state: PhysicsDirectBodyState2D):
	if not enabled: return
	state.linear_velocity -= velocity_delta
	state.transform.origin -= origin_delta
	if _reset_velocity_delta:
		_reset_reset = true

func add(node: Node):
	node.add_to_group(GROUP_NAME)

func _process(delta):
	if not enabled: return
	MainState.debug("origin", origin)
	MainState.debug("origin velocity", velocity)
	if not is_instance_valid(target): return
	for node in get_tree().get_nodes_in_group(GROUP_NAME):
		node.position -= velocity * delta + _process_origin_delta
	_process_origin_delta = Vector2.ZERO

func _on_update_player_ship(player_ship: ShipRigidBody):
	target = player_ship
	if not target:
		velocity_delta = -velocity
		velocity = Vector2.ZERO
		_reset_velocity_delta = true
		_reset_reset = true
