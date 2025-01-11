class_name RigidBody
extends RigidBody2D

const GRID_UPDATE_DELTA := 0.2
const GRID_TIME_SHIFT := 0.2

@export var include_on_grid := true

var tick_acceleration: Vector2

var _last_velocity: Vector2
var _last_grid_update_delta := 0.0
var _debug_color: Color = Color.from_hsv(randf(), 1.0, 0.5)

var speed: float:
	get:
		return linear_velocity.length()

## Always call in the end of overriding method
func _physics_process(delta: float):
	tick_acceleration = (linear_velocity - _last_velocity)
	_last_velocity = linear_velocity
	if include_on_grid: _update_on_grid(delta)

func delta_v(target_v: Vector2) -> Vector2:
	return target_v - linear_velocity

func _update_on_grid(delta: float):
	_last_grid_update_delta += delta
	if _last_grid_update_delta > GRID_UPDATE_DELTA:
		MainState.world_grid.add_or_update(self, linear_velocity * GRID_TIME_SHIFT)
		_last_grid_update_delta = 0.0
