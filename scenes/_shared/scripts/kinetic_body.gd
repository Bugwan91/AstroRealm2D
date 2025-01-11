class_name KineticBody
extends Node2D

@export var linear_velocity := Vector2.ZERO
@export var include_on_grid := false
@export var grid_time_shift := 0.2

var _last_grid_update_delta := 0.0

var speed: float:
	get: return linear_velocity.length()

## IMPORTANT: should call it from child
func _physics_process(delta: float):
	position += linear_velocity * delta
	if include_on_grid: _update_on_grid(delta)

func _update_on_grid(delta: float):
	_last_grid_update_delta += delta
	if _last_grid_update_delta > MainState.world_grid.DELTA:
		MainState.world_grid.add_or_update(self, linear_velocity * grid_time_shift)
		_last_grid_update_delta = 0.0
