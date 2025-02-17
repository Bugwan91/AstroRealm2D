class_name Heat
extends Node

const EXTRA_HEAT_MAX := 0.01;
const OVERHEAT_DAMAGE := 50.0; # dmg/sec

@export var capacity: float = 100.0 # heat
@export var cooling: float = 10.0 # heat/sec
@export var transfer_efficiency: = 10.0 # heat/sec
@export var view: BaseView
@export var health: TakingDamage

var _heat := 0.0:
	set(value):
		_heat = clampf(value, 0.0, _heat_max)
		_extra_heat = clampf(_heat - capacity, 0.0, _extra_heat_max)
		temperature = _heat / capacity
var _extra_heat: float
var _heat_max: float
var _extra_heat_max: float

var temperature: float = 0.0:
	set(value):
		temperature = value
		if is_instance_valid(view):
			view.set_temperature(clampf(temperature, 0.0, 1.0))

func transfer(delta: float) -> float:
	var transfer_heat := minf(_heat, transfer_efficiency * temperature * delta)
	_heat -= transfer_heat
	return transfer_heat

func _ready() -> void:
	_extra_heat_max = capacity * EXTRA_HEAT_MAX
	_heat_max = capacity + _extra_heat_max

func is_max() -> bool:
	return _heat > capacity

func add_heat(heat: float) -> void:
	_heat += heat

func _physics_process(delta: float) -> void:
	if is_zero_approx(_heat):
		_heat = 0.0
		return
	_heat -= delta * _get_current_cooling()
	if _extra_heat > 0.0:
		_apply_overheat_damage(delta)

func _get_current_cooling() -> float:
	return cooling * (1.0 + temperature * temperature)

func _apply_overheat_damage(delta: float) -> void:
	if not is_instance_valid(health): return
	var damage := Damage.new();
	damage.amount = OVERHEAT_DAMAGE * delta * _extra_heat;
	damage.type = Damage.Type.HEAT;
	health.damage(damage)
