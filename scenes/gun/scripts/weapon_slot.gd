class_name WeaponSlot
extends Node2D

signal recoil(value: Vector2)
signal heat_generated(value: float)

var points: Array[Vector2]
var center: Vector2
var weapon_resource: WeaponRes
var enabled := true

var _weapons: Array[Gun]

func _process(delta: float) -> void:
	#TODO: maybe I should handle fire here
	pass

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
		weapon.set_origin(owner)
		weapon.position = point
		_weapons.append(weapon)
		weapon.shoot_recoil.connect(func(value: Vector2):
			recoil.emit(value))
		weapon.tranfser_heat.connect(func(value: float):
			heat_generated.emit(value))
		add_child(weapon)

func _clear():
	weapon_resource = null
	_weapons.clear()
	for child in get_children():
		child.queue_free()

func connect_inputs(input: Signal) -> void:
		input.connect(on_fire)

func on_fire(value):
	#TODO: handle enabled
	#TODO: handle salvo
	for weapon in _weapons:
		weapon.fire(value)
