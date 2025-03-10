class_name WeaponSlot
extends Node2D

signal recoil(value: Vector2)
signal heat_generated(value: float)

@onready var pointer: AssistantPointer = %Pointer

var enabled := true:
	set(value):
		enabled = value
		_update_fire()
var points: Array[Vector2]
var center: Vector2
var weapon_resource: WeaponRes
var origin: Spaceship
var target: RigidBody
var aim_point: Vector2
var is_firing: bool:
	get: return enabled and _fire_input

var _fire_input := false

var temperature: float:
	get:
		var t := 0.0
		for w in _weapons:
			t += w._heat.temperature
		return t / _weapons.size()

var _weapons: Array[Gun]
var _container: Node2D

func _ready() -> void:
	origin = owner
	_container = Node2D.new()
	add_child(_container)
	pointer.hide()

func _process(_delta: float) -> void:
	if is_instance_valid(target) and is_instance_valid(pointer):
		aim_point = get_intersection()
		if origin.is_player():
			var dist := aim_point.length()
			pointer.update(aim_point, origin.extrapolator.canvas_position)
			if dist < weapon_resource.effective_range + weapon_resource.extra_range * 0.5:
				pointer.set_active()
			else:
				pointer.set_inactive()
	#TODO: maybe I should handle fire here
	else:
		aim_point = Vector2.ZERO

func setup(weapon_points: Array[PointResource]) -> void:
	points = []
	var total_pos := Vector2.ZERO
	for point in weapon_points:
		points.append(point.position)
		total_pos += point.position
	center = total_pos / weapon_points.size()

func set_weapon(_weapon_resource: WeaponRes) -> void:
	_clear()
	weapon_resource = _weapon_resource
	for point in points:
		var weapon := weapon_resource.create()
		weapon.set_origin(origin)
		weapon.position = point
		_weapons.append(weapon)
		weapon.shoot_recoil.connect(func(value: Vector2) -> void:
			recoil.emit(value))
		weapon.tranfser_heat.connect(func(value: float) -> void:
			heat_generated.emit(value))
		add_child(weapon)

func _clear() -> void:
	weapon_resource = null
	for weapon in _weapons:
		weapon.queue_free()
	_weapons.clear()

func connect_fire_input(input: Signal) -> void:
		input.connect(on_fire)

func connect_target_input(input: Signal) -> void:
	input.connect(on_target_changed)

func on_fire(value: bool) -> void:
	_fire_input = value
	#TODO: handle salvo
	_update_fire()

func _update_fire() -> void:
	for weapon in _weapons:
		weapon.fire(is_firing)

func on_target_changed(_target: RadarItem) -> void:
	if is_instance_valid(_target) and _target.parent is RigidBody:
		target = _target.parent
	else:
		target = null
		pointer.hide()

func get_intersection() -> Vector2:
	return InterceptionCalculator.interception(
		origin.extrapolator.smooth_position,
		origin.linear_velocity,
		target.extrapolator.smooth_position,
		target.linear_velocity,
		(target as ActiveRigidBody).acceleration if target is ActiveRigidBody else Vector2.ZERO,
		weapon_resource.projectile_speed
	)
