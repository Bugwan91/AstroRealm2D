class_name StaticRigidBody
extends RigidBody

var _lv: Vector2
var _av: float

func freeze_body(value: bool) -> void:
	if freeze == value: return
	freeze = value
	if is_instance_valid(extrapolator):
		extrapolator.freeze = value
	_use_velocity_hack()

func _ready() -> void:
	_init_velocity_hack()

func freeze_process(delta: float) -> void:
	position += _lv * delta
	rotation += _av * delta

# HACK: Do no know why, but after unfreezing RB stops moving. Used this hack to fix.
func _init_velocity_hack() -> void:
	_lv = linear_velocity
	_av = angular_velocity

func _use_velocity_hack() -> void:
	if freeze:
		_lv = linear_velocity
		_av = angular_velocity
	else:
		linear_velocity = _lv
		angular_velocity = _av
