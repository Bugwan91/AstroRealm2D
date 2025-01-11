extends Node

signal main_scene_ready
signal player_ship_updated(ship: Spaceship)
signal player_dead
signal radar_updated(radar: Radar)

const MAX_SPEED: float = 100000.0

var main_scene: MainScene:
	set(value):
		main_scene = value
		main_scene_ready.emit()

var world_grid := WorldGrid.new()
var camera_controller: CameraController
var radar_manager := RadarManager.new()

var ship_designer: ShipDesignerUI

var player_ship: Spaceship: set = _update_player_ship

### TODO # REMOVE ### REFACTOR ###
var fa_tracking := false
var fa_tracking_distance := 0.0
var fa_autopilot := false
var fa_autopilot_speed := 500.0
### TODO # REMOVE ### REFACTOR ###

# TODO: move player related code into separate PlayerManager class
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
