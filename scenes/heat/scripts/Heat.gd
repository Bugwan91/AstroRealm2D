class_name Heat
extends Node

@export var capacity: float = 100.0
@export var cooling: float = 10.0
@export var view: BaseView

var _heat := 0.0:
	set(value):
		_heat = value if value > 0.0 else 0.0
		temperature = _heat / capacity

var temperature: float = 0.0:
	set(value):
		temperature = value
		if is_instance_valid(view):
			view.set_temperature(clampf(temperature, 0.0, 1.0))

func is_max() -> bool:
	return _heat > capacity

func add_heat(heat: float):
	_heat += heat

func _physics_process(delta):
	_heat -= delta * _current_cooling()

func _current_cooling() -> float:
	return 0.5 * cooling * (1.0 + clampf(temperature, 0.0, 1.0))
