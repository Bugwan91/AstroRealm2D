class_name WeaponView
extends BaseView

@export_range(0, 100) var emission_reduction := 8.0

var _current_emission := 0.0:
	set(value):
		_current_emission = value if value > 0.0 else 0.0
		set_emission(_current_emission)

func emit_max():
	_current_emission = 1.0

func _process(delta):
	if _current_emission > 0.0:
		_current_emission -= delta * emission_reduction
