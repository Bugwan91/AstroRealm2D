class_name Heat
extends Node

const OVERHEAT_DAMAGE := 50.0; # dmg/sec

@export var capacity: float = 100.0 # heat
@export var cooling: float = 10.0 # heat/sec
@export var transfer_efficiency: = 10.0 # heat/sec
@export var view: BaseView
@export var health: TakingDamage:
	set(value):
		health = value
		print(value)

var _heat := 0.0:
	set(value):
		_heat = value if value > 0.0 else 0.0
		temperature = _heat / capacity

var temperature: float = 0.0:
	set(value):
		temperature = value
		if is_instance_valid(view):
			view.set_temperature(clampf(temperature, 0.0, 1.0))

func transfer(delta: float) -> float:
	var transfer_heat := minf(_heat, transfer_efficiency * temperature * delta)
	_heat -= transfer_heat
	return transfer_heat

func is_max() -> bool:
	return _heat > capacity

func add_heat(heat: float) -> void:
	_heat += heat

func _physics_process(delta: float) -> void:
	if is_zero_approx(_heat): return
	_heat -= delta * _current_cooling()
	if _heat > capacity:
		_apply_overheat_damage(delta)

func _current_cooling() -> float:
	return 0.5 * cooling * (1.0 + clampf(temperature, 0.0, 1.0))

func _apply_overheat_damage(delta: float) -> void:
	if not is_instance_valid(health): return
	var damage := Damage.new();
	damage.amount = OVERHEAT_DAMAGE * delta;
	damage.type = Damage.Type.HEAT;
	health.damage(damage)
