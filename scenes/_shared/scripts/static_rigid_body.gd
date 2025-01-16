class_name StaticRigidBody
extends RigidBody

@export_range(0.0, 2.0) var update_interval := 0.5

var _delta := 0.0

var _l_v: Vector2
var _a_v: float

func _ready() -> void:
	super._ready()
	freeze_body()

func freeze_body():
	if freeze: return
	_l_v = linear_velocity
	_a_v = angular_velocity
	## INFO: Profiler shows no effect from disabling collisions
	#set_collisions(!value)
	freeze = true
	set_physics_process(true)

func unfreeze_body():
	if not freeze: return
	linear_velocity = _l_v
	angular_velocity = _a_v
	freeze = false
	set_physics_process(false)

func _physics_process(delta: float) -> void:
	_delta += delta
	if is_zero_approx(update_interval) or _delta > update_interval:
		position += _l_v * _delta
		_delta = 0.0
