# FIXME: The whole class should be managed better. Find solution for such global bridge/manager!
extends Node

signal world_root_ready
signal player_ship_updated(ship: Spaceship)
signal player_dead
signal radar_updated(radar: Radar)

const MAX_SPEED: float = 100000.0

var main_scene: MainScene

var world_root: Node2D:
	set(value):
		world_root = value
		world_root_ready.emit()

var last_delta: float
var camera_controller: CameraController
var camera_shift: Vector2
var radar_manager := RadarManager.new()

var ship_designer: ShipDesignerUI

var player_ship: Spaceship: set = _update_player_ship

### FIXME # REMOVE ### REFACTOR ###
var fa_tracking := false
var fa_tracking_distance := 0.0
var fa_autopilot := false
var fa_autopilot_speed := 500.0
### REMOVE ### REFACTOR ###

# HACK: move player related code into separate PlayerManager class
func connect_to_player(callback: Callable):
	player_ship_updated.connect(callback)
	callback.call(player_ship)

func _update_player_ship(ship: Spaceship):
	player_ship = ship
	player_ship_updated.emit(player_ship)
	player_ship.dead.connect(_on_player_dead)

func _on_player_dead(_pass):
	#selection_item_manager.select()
	player_ship_updated.emit(null)
	player_dead.emit()
