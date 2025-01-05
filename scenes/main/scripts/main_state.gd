extends Node

signal main_scene_ready
signal player_ship_updated(ship: Spaceship)
signal player_target_updated(target: SelectionItem)
signal player_dead
signal radar_updated(radar: Radar)

const MAX_SPEED: float = 100000.0

var main_scene: MainScene:
	set(value):
		main_scene = value
		main_scene_ready.emit()

var camera_controller: CameraController

var ship_designer: ShipDesignerUI

var player_ship: Spaceship: set = _update_player_ship
var player_target: SelectionItem: set = _update_player_target
var player_radar: Radar: set = _set_radar

### TODO # REMOVE ### REFACTOR ###
var fa_tracking := false
var fa_tracking_distance := 0.0
var fa_autopilot := false
var fa_autopilot_speed := 500.0
### TODO # REMOVE ### REFACTOR ###

func connect_to_player(callback: Callable):
	player_ship_updated.connect(callback)
	callback.call(player_ship)

func _update_player_ship(ship: Spaceship):
	player_ship = ship
	player_ship_updated.emit(player_ship)
	player_ship.dead.connect(_on_player_dead)

func _update_player_target(target: SelectionItem):
	if not is_instance_valid(target):
		player_target = null
		player_target_updated.emit(null)
		return
	if not is_instance_valid(player_ship) or target.item == player_ship: return
	player_target = target
	player_target_updated.emit(player_target)
	if is_instance_valid(player_target):
		pass
		# TODO: fix resetting selection on destroying target
		#player_target.dead.connect(_on_target_dead)

func _on_target_dead(_pass):
	player_target = null

func _on_player_dead(_pass):
	player_target = null
	player_ship_updated.emit(null)
	player_dead.emit()

func _set_radar(value: Radar):
	player_radar = value
	radar_updated.emit(player_radar)
