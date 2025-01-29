class_name WeaponView
extends BaseView

const EMISSION_THRESHOLD := 0.01

## Part of emission reduction each seccond: 0.5 is 2 sec, 1 is 1 sec, 2 is 0.5 sec
@export_range(0, 50) var emission_reduction := 2.0

var _current_emission := 0.0:
	set(value):
		_current_emission = value if value > 0.0 else 0.0
		set_emission(_current_emission)

func emit_max() -> void:
	_current_emission = max_emission

func _process(delta: float) -> void: 
	if _current_emission > EMISSION_THRESHOLD:
		_current_emission -= max_emission * delta * emission_reduction
	else:
		_current_emission = 0.0
