class_name StaticRigidBody
extends RigidBody

const FREEZE_DELTA := 0.5

var _l_v: Vector2
var _a_v: float

var _order: int
var _delta:= 0.0

func _ready() -> void:
	super._ready()
	freeze_body(true)
	_order = randi_range(1, Engine.physics_ticks_per_second * FREEZE_DELTA)
	_delta = _order / Engine.physics_ticks_per_second

func freeze_body(value: bool):
	if freeze == value: return
	freeze = value
	extrapolator.freeze = value
	if is_instance_valid(grid_item):
		grid_item.freeze = value
	set_physics_process(value)
	## INFO: Profiler shows no effect from disabling collisions.
	## Probably it is because freezed bodies dones't collide with other freezed bodies
	#set_collisions(!value)
	if value:
		_l_v = linear_velocity
		_a_v = angular_velocity
	else:
		linear_velocity = _l_v
		angular_velocity = _a_v

func _physics_process(delta: float) -> void:
	_delta += delta
	if _delta > FREEZE_DELTA:
		position += _l_v * _delta
		rotation += _a_v * _delta
		grid_item.update()
		_delta = 0.0
