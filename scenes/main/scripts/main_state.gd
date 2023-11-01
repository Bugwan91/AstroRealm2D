extends Node

signal player_ship_updated(ship: ShipRigidBody)
signal player_target_updated(ship: ShipRigidBody)

@onready var world_node: Node2D = get_node("/root/Main")

var ship_position := Vector2.ZERO
var ship_speed := 0
var ship_acceleration := 0
var fa_tracking := false
var fa_tracking_distance := 0.0
var fa_autopilot := false
var fa_autopilot_speed := 500.0

var debug := {}

var player_ship: ShipRigidBody: set = _update_player_ship
var player_target: ShipRigidBody: set = _update_player_target


func add_debug_info(key: String, value):
	debug[key] = str(value)

func _update_player_ship(ship: ShipRigidBody):
	player_ship = ship
	player_ship_updated.emit(player_ship)

func _update_player_target(ship: ShipRigidBody):
	if ship == player_ship: return
	player_target = ship
	player_target_updated.emit(player_target)
