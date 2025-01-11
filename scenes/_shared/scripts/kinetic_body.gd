class_name KineticBody
extends Node2D

const GRID_UPDATE_DELTA := 0.2
const GRID_TIME_SHIFT := 0.2

@export var linear_velocity := Vector2.ZERO
@export var include_on_grid := false

var _last_grid_update_delta := 0.0

var speed: float:
	get: return linear_velocity.length()

## IMPORTANT: should call it from child
func _physics_process(delta: float):
	position += linear_velocity * delta
	if include_on_grid: _update_on_grid(delta)

func _update_on_grid(delta: float):
	_last_grid_update_delta += delta
	if _last_grid_update_delta > GRID_UPDATE_DELTA:
		MainState.world_grid.add_or_update(self, linear_velocity * GRID_TIME_SHIFT)
		_last_grid_update_delta = 0.0
