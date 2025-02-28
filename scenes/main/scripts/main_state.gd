# FIXME: The whole class should be managed better. Find solution for such global bridge/manager!
extends Node

signal world_root_ready

const MAX_SPEED: float = 100000.0

var main_scene: MainScene

var world_root: Node2D:
	set(value):
		world_root = value
		world_root_ready.emit()

var last_delta: float
var camera_controller: CameraController
var camera_shift: Vector2

# TODO: Probably, this should be in better place
signal player_ship_spawned(value: Spaceship)
var player: Spaceship:
	set(value):
		player = value
		player_ship_spawned.emit(player)
