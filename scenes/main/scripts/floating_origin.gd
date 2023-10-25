extends Node2D

const c := 100000.0

var enabled := true
var target: ShipRigidBody

var origin := Vector2.ZERO
var origin_delta := Vector2.ZERO
var velocity := Vector2.ZERO
var velocity_delta: Vector2

func update_state(state: PhysicsDirectBodyState2D):
	velocity_delta = state.linear_velocity
	velocity += velocity_delta
	origin_delta = state.transform.origin + velocity_delta * state.step
	origin += velocity * state.step

func _process(delta):
	MainState.add_debug_info("origin", origin)
	MainState.add_debug_info("origin velocity", velocity)
	for node in get_tree().get_nodes_in_group("shiftable"):
		node.position -= velocity * delta
	
