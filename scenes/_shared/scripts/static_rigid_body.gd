class_name StaticRigidBody
extends RigidBody

@export_range(0.0, 2.0) var update_interval := 0.5

var _delta := 0.0

func _physics_process(delta: float) -> void:
	if freeze:
		_delta += delta
		if is_zero_approx(update_interval) or _delta > update_interval:
			position += linear_velocity * _delta
			_delta = 0.0
